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

    # This method deletes DNS records by name
    #
    # @param zone [String]
    # @param name [String]
    def rec_delete_by_name zone, name
        get_records(zone, name).keys.each { |rec_id| rec_delete(zone, rec_id) }
    end

    # This method finds a record by its name, zone, content and type,
    # Returns nil of none was found, the meta hash otherwise
    #
    # @param zone [String]
    # @param name [String]
    # @param content [String]
    # @param type [String]
    def find_single_record zone, name, content, type = 'A'
        get_records(zone, name).values.each do |rec|
            if rec['zone_name'] == zone \
                && rec['display_name'] == name \
                && rec['content'] == content \
                && rec['type'] == type
                return rec
            end
        end
        nil
    end

    # This method deletes a single record
    # Returns true iff a record was deleted
    #
    # @param zone [String]
    # @param name [String]
    # @param content [String]
    # @param type [String]
    def rec_delete_single zone, name, content, type = 'A'
        rec = find_single_record(zone, name, content, type) or return false
        rec_delete(zone, rec['rec_id'])
        true
    end

    # This method returns true iff that zone exists
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

    # Gets all the metadata for records that match
    # the given `zone' and `name'
    # Returns a hash mapping record's IDs to the metadata hashes
    # 
    # @param zone [String]
    # @param name [String]
    def get_records zone, name
        result = {}
        get_all_records_for_zone(zone).each do |rec|
            if rec['display_name'] == name && rec['zone_name'] == zone
                result[rec['rec_id']] = rec
            end
        end
        result
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

    # we need to flush the cache when creating, editing or deleting records
    def rec_new zone, *args
        flush_cache_for_zone zone
        super zone, *args
    end
    def rec_edit zone, *args
        flush_cache_for_zone zone
        super zone, *args
    end
    def rec_delete zone, *args
        flush_cache_for_zone zone
        super zone, *args
    end

    private

    # Returns an array containing all the records for this zone,
    # accounting for pagination
    # Also memoizes the result
    #
    # @param zone [String]
    def get_all_records_for_zone zone
        @records_cache ||= {}
        unless @records_cache[zone]
           # not cached, we need to retrieve it
           @records_cache[zone] = []
           offset = 0
           has_more = true
           while has_more
               response = rec_load_all zone, offset
               has_more = response['response']['recs']['has_more']
               offset += response['response']['recs']['count']
               @records_cache[zone].concat(response['response']['recs']['objs'])
           end
        end
        @records_cache[zone]
    end

    # we memoize zone_load_multi too
    def zone_load_multi
        @zone_load_multi_cache ||= super
    end

    # We need to flush the cache when we make changes that make it obsolete
    #
    # @param zone [String]
    def flush_cache_for_zone zone
        @records_cache ||= {}
        @records_cache.delete zone
    end
end
