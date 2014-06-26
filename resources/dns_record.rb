actions :create, :delete
default_action :create

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :record_name, :kind_of => [String, FalseClass], :default => false
attribute :zone, :kind_of => String, :required => true
attribute :content, :kind_of => [String, FalseClass], :default => false
attribute :type, :kind_of => String, :equal_to => ['A', 'CNAME'], :default => 'A'
attribute :ttl, :kind_of => Fixnum, :default => 1
attribute :orange_cloud, :kind_of => [TrueClass, FalseClass], :default => false
attribute :exclusive, :kind_of => [TrueClass, FalseClass], :default => false

def exists?
    if node['cloudflare']['check_with_DNS']
        Chef::Log.info "Trying to check DNS record #{name} with DNS server"
        Chef::Application.fatal!("You need to specify a DNS server in the ['cloudflare']['DNS_server'] attribute to use the ['cloudflare']['check_with_DNS'] option") unless node['cloudflare']['DNS_server']
        resolver = ::Resolv::DNS.open({:nameserver=>[node['cloudflare']['DNS_server']]})
        case type
        when 'A'
            resolver.getresource(complete_url, Resolv::DNS::Resource::IN::A).address
        when 'CNAME'
            resolver.getresource(complete_url, Resolv::DNS::Resource::IN::CNAME).name
        end.to_s == content and return true rescue [Resolv::ResolvError, Resolv::ResolvTimeout]
        # if we didn't what we expected, we still ask cloudflare
        Chef::Log.info "DNS record #{name} wasn't found on DNS server #{node['cloudflare']['DNS_server']}"
    end

    cf_record = get_same_name_record_with_content or return false

    is_orange_cloud_on = (cf_record['service_mode'] == 1)

    is_orange_cloud_on == orange_cloud && cf_record['zone_name'] == zone && cf_record['display_name'] == record_name && cf_record['content'] == content && cf_record['type'] == type && cf_record['ttl'] == ttl.to_s
end

def name_exists?
    !!get_same_name_record
end

def exclusive?
    exclusive
end

def create
    node.cloudflare_client.rec_new zone, type, record_name, content, ttl, orange_cloud
end

def delete_all_with_name
    node.cloudflare_client.rec_delete_by_name zone, record_name
end

def delete
    node.cloudflare_client.rec_delete_with_content zone, record_name, content
end

alias_method :old_record_name, :record_name
def record_name *args
    # we default to the resource name if no explicit record_name was given
    @record_name = name if !@record_name
    # the record name can't finish with the zone name, nor a dot
    @record_name = @record_name.chomp zone
    @record_name.chomp! '.'
    old_record_name *args
end

alias_method :old_content, :content
def content *args
    # we default to the node's ipaddress if no content was explicitely given
    @content = node.ipaddress if !@content
    old_content *args
end

private

def complete_url
    "#{record_name}.#{zone}"
end

def get_same_name_record
    Chef::Application.fatal!("Unknown DNS zone #{zone}!") if node['cloudflare']['check_zone'] && !node.cloudflare_client.zone_exists?(zone)
    node.cloudflare_client.get_record zone, record_name
end

def get_same_name_record_with_content
    Chef::Application.fatal!("Unknown DNS zone #{zone}!") if node['cloudflare']['check_zone'] && !node.cloudflare_client.zone_exists?(zone)
    node.cloudflare_client.get_record_with_content zone, record_name, content
end
