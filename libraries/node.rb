class Chef::Node
    def cloudflare_client
        return @cloudflare_client unless @cloudflare_client.nil?
        Chef::Application.fatal!("You need to define the ['cloudflare']['credentials']['email'] and ['cloudflare']['credentials']['api_key'] node attributes to use the cloudflare cookbook") unless node['cloudflare']['credentials']['api_key'] && node['cloudflare']['credentials']['email']
        @cloudflare_client = CloudFlare.new(node['cloudflare']['credentials']['api_key'], node['cloudflare']['credentials']['email'])
        Chef::Application.fatal!('Invalid CloudFlare credentials!') if node['cloudflare']['check_credentials'] && !@cloudflare_client.credentials_valid?
        @cloudflare_client
    end
end
