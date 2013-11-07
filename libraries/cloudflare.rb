# adding a few useful methods to the vanilla Cloudflare class
class CloudFlare

    # custom timeout to avoid timing out
    TIMEOUT = 10

    # This method deletes a DNS record by name
    #
    # @param zone [String]
    # @param name [String]
    def rec_delete_by_name zone, name
        rec_id = get_record(zone, name)['rec_id'] or return false
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
        rec_load_all(zone)['response']['recs']['objs'].each do |rec|
            return rec if rec['display_name'] == name && rec['zone_name'] == zone
        end rescue NoMethodError
        nil
    end

    private

    # Memoizes the results of 'rec_load_all' calls
    # to avoid making too many calls to the API
    #
    # @param zone [String]
    def rec_load_all zone
        @rec_load_all_cache ||= {}
        @rec_load_all_cache[zone] ||= super zone
    end

    # same with zone_load_multi
    def zone_load_multi
        @zone_load_multi_cache ||= super zone_load_multi
    end
end
