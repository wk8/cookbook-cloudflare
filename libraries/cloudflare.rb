# still haven't figured out a proper way to extend a gem in a Chef lib... :-/
# this is past ugly...
module CloudFlare
    class Connection
    end
end

# adding a few useful methods to the vanilla Cloudflare library
class CloudflareClient < CloudFlare::Connection

    # custom timeout to avoid timing out
    TIMEOUT = 10

    def rec_new zone, type, record_name, content, ttl, orange_cloud
      super(zone, type, record_name, content, ttl)
      if orange_cloud
        record = get_record_with_content(zone, record_name, content) or return false
        rec_id = record['rec_id']
        rec_edit(zone,  type, rec_id, record_name, content, ttl,
            :service_mode => orange_cloud
          )
      end
    end

    # This method deletes a DNS record by name
    #
    # @param zone [String]
    # @param name [String]
    def rec_delete_by_name zone, name
        get_all_records_for_zone(zone).each do |rec|
            if rec['display_name'] == name && rec['zone_name'] == zone
                rec_delete(zone, rec['rec_id'])
            end
        end
    end

    def rec_delete_with_content zone, name, content
        record = get_record_with_content(zone, name, content) or return false
        rec_id = record['rec_id']
        rec_delete(zone, rec_id)
    end

    # This method returns true if that zone exists
    #
    # @param zone [String]
    def zone_exists? zone
        zone_load_multi['response']['zones']['objs'].each do |z|
            return true if z['zone_name'] == zone
        end rescue NoMethodError
        false
    end

    # This method checks that the credentials are valid
    def credentials_valid?
        zone_load_multi['result'] == 'success' rescue false
    end

    # Gets all the metadata hash for a given record
    #
    # @param zone [String]
    # @param name [String]
    def get_record zone, name
        get_all_records_for_zone(zone).each do |rec|
            return rec if rec['display_name'] == name && rec['zone_name'] == zone
        end rescue NoMethodError
        nil
    end

    # Gets all the metadata hash for a given record
    #
    # @param zone [String]
    # @param name [String]
    # @param content [String]
    def get_record_with_content zone, name, content
        get_all_records_for_zone(zone).each do |rec|
            return rec if rec['display_name'] == name && rec['zone_name'] == zone && rec['content'] == content
        end rescue NoMethodError
        nil
    end

    # The vanilla lib's 'rec_load_all' implementation doesn't account (as of v2.0.1)
    # for the fact that CloudFlare paginates the results...
    # TODO: do a PR on them
    #
    # @param zone [String]
    # @param offset [Integer]
    def rec_load_all zone, offset = 0
        send_req({a: :rec_load_all, z: zone, o: offset})
    end

    private

    # Returns an array containing all the records for this zone,
    # accounting for pagination
    # Also memoizes the result
    #
    # @param zone [String]
    def get_all_records_for_zone zone
        # not cached, we need to retrieve it
        records = []
        offset = 0
        has_more = true
        while has_more
            response = rec_load_all zone, offset
            has_more = response['response']['recs']['has_more']
            offset += response['response']['recs']['count']
            records.concat(response['response']['recs']['objs'])
        end
        records
    end

    # we memoize zone_load_multi too
    def zone_load_multi
        @zone_load_multi_cache ||= super
    end

end
