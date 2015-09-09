actions :create, :delete
default_action :create

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :record_name, :kind_of => [String, FalseClass], :default => false
attribute :zone, :kind_of => String, :required => true
attribute :content, :kind_of => String, :default => node.ipaddress
attribute :type, :kind_of => String, :equal_to => ['A', 'CNAME'], :default => 'A'
attribute :ttl, :kind_of => Fixnum, :default => 1
attribute :service_mode, :kind_of => String, :default => '0'
attribute :shared_A_record, :kind_of => [TrueClass, FalseClass], :default => false

# returns true iff the record already exists
# for A records, if `shared_A_record' is set to false, this function will only
# return true if the record exists and is the only one with that name
def exists?
  if node['cloudflare']['check_with_DNS']
    Chef::Log.info "Trying to check DNS record #{name} with DNS server"
    resolver = ::Resolv::DNS.open({:nameserver => [node['cloudflare']['DNS_server']]})
    begin
      case type
      when 'A'
        # we can have multiple A records with the same name
        addresses = resolver.getaddresses complete_url
        addresses.each do |address|
          if address.to_s == content
            return shared_A_record || addresses.length == 1
          end
        end
      when 'CNAME'
        if resolver.getresource(complete_url, Resolv::DNS::Resource::IN::CNAME).name.to_s == content
          return true
        end
      end
    rescue Resolv::ResolvError, Resolv::ResolvTimeout => ex
      Chef::Log.info "DNS Resolv exception when trying to resolve #{name} => #{ex}"
    end
    # if we didn't find what we expected, we still ask cloudflare's API
    Chef::Log.info "DNS record #{name} wasn't found on DNS server #{node['cloudflare']['DNS_server']}"
  end

  # check against Cloudflare's API
  records = get_same_named_records.values
  records.each do |record|
    if record['zone_name'] == zone \
      && record['display_name'] == record_name \
      && record['content'] == content \
      && record['type'] == type \
      && record['ttl'] == ttl.to_s \
      && record['service_mode'] == service_mode
      return shared_A_record || records.length == 1
    end
  end

  Chef::Log.info "DNS record #{name} does not exist yet"
  return false
end

def name_exists?
  get_same_named_records.length != 0
end

def create
  node.cloudflare_client.rec_new zone, type, record_name, content, ttl, nil, nil, nil, nil, nil, nil, nil, service_mode
end

# deletes all the records with that name
def delete_by_name
  node.cloudflare_client.rec_delete_by_name zone, record_name
end

# deletes exactly this record, leaving other records with the same name alone
def delete_single
  node.cloudflare_client.rec_delete_single zone, record_name, content, type
end

alias_method :old_record_name, :record_name
def record_name *args
  # we default to the resource name if no explicit record_name was given
  @record_name = name if !@record_name
  # the record name can't finish with the zone name, nor a dot
  @record_name = @record_name.chomp zone
  @record_name.chomp! '.'
  # and last but not least, DNS records are case-insensitive, and Cloudflare
  # lowercases everything anyway
  @record_name.downcase!
  old_record_name *args
end

# same as for record names, we need lowercase strings
alias_method :old_zone, :zone
def zone *args
  @zone.downcase! if @zone
  old_zone *args
end

def shared_A_record?
  type == 'A' && shared_A_record
end

def complete_url
  "#{record_name}.#{zone}"
end

private

def get_same_named_records
  if node['cloudflare']['check_zone'] && !node.cloudflare_client.zone_exists?(zone)
    Chef::Application.fatal! "Unknown DNS zone #{zone}!"
  end
  node.cloudflare_client.get_records zone, record_name
end
