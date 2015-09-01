require 'yaml'
require 'net/http'

# Ping Google and Bing web crawlers that the site has changed
class Jekyll::S3Deploy::PingCommand < Jekyll::Command
  class << self
    def init_with_program prog
            prog.command(:ping) do |c|
        c.syntax "ping"
        c.description 'Ping Google and Bing web crawlers'

        c.action do |args, options|
          ping
        end
      end
    end

    def ping
      config = YAML.load File.open '_config.yml'
      sitemap_url = URI.escape "#{config['url']}#{config['baseurl']}/sitemap.xml"

      Jekyll.logger.info "Notifying web crawlers of updated sitemap at #{sitemap_url}"
      Jekyll.logger.info "* Pinging Google sitemap..."
      resp = Net::HTTP.get_response 'www.google.com', "/webmasters/tools/ping?sitemap=#{sitemap_url}"
      Jekyll.logger.error "Error! #{resp.code} : #{resp.message}" if resp.code.to_i != 200
      Jekyll.logger.info '* Pinging Bing sitemap...'
      resp = Net::HTTP.get_response 'www.bing.com',  "/webmaster/ping.aspx?siteMap=#{sitemap_url}"
      Jekyll.logger.error "Error! #{resp.code} : #{resp.message}" if resp.code.to_i != 200
      Jekyll.logger.info 'Done!'
    end
  end
end
