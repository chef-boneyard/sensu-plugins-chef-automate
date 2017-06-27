# Library for performing automate API calls
# Usage:
#   Create a json file ~/.automate_sensu_credentials
require 'rest-client'
require 'json'

class AutomateApi
  def initialize(fqdn, enterprise, verbose)
    @automate_fqdn = fqdn
    @automate_enterprise = enterprise
    @base_url = "https://#{@automate_fqdn}/api/v0/e/#{@automate_enterprise}"
    @creds = load_creds
    @verbose = verbose
    RestClient.log = 'stdout' if verbose
    @token = get_token
  end

  def load_creds
    creds_file = "#{ENV['HOME']}/.automate_sensu_credentials"
    JSON.parse(File.read(creds_file))
  end

  def get_new_token
    response = RestClient.post \
      "#{@base_url}/get-token", \
      {username: @creds['username'], password: @creds['password']}.to_json,
      {content_type: :json, accept: :json}
    data = JSON.parse(response)
    data['expiry'] = (Time.now + data['ttl']).iso8601
    data
  end

  def get_token
    token_file = "/var/tmp/.automate_sensu_token"
    grace_period = 3600
    data = JSON.parse(File.read(token_file)) rescue Hash.new
    expiry = Time.iso8601(data['expiry']) rescue Time.now
    if expiry < Time.now + grace_period
      puts "Token expired, getting a new one" if @verbose
      data = get_new_token
      File.write(token_file, data.to_json)
    end
    data['token']
  end

  def request(method, endpoint, data)
    JSON.parse(RestClient::Request.execute(
      method: method,
      url: "#{@base_url}/#{endpoint}",
      payload: data.to_json,
      headers: {
        content_type: :json,
        accept: :json,
        "chef-delivery-token": @token,
        "chef-delivery-user": @creds['username'],
        "chef-delivery-enterprise": @automate_enterprise
      },
    ))
  end
end
