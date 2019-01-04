#!/usr/bin/env ruby
require 'sensu-plugin/check/cli'
require 'sensu-plugins-chef-automate/helpers'

class CheckAutomateRunners < Sensu::Plugin::Check::CLI
  option :count,
         long: '--count COUNT',
         short: '-c COUNT',
         description: 'Number of runners that should be available',
         proc: proc { |l| l.to_i },
         required: true

  option :fqdn,
         long: '--fqdn FQDN',
         short: '-f FQDN',
         description: 'FQDN of your automate server',
         required: true

  option :enterprise,
         long: '--enterprise ENTERPRISE',
         short: '-e ENTERPRISE',
         description: 'The name of your automate enterprise',
         required: true

  option :verbose,
         long: '--verbose',
         short: '-v',
         description: 'Enable additional output',
         boolean: true

  option :help,
         short: '-h',
         long: '--help',
         description: 'Show this message',
         on: :tail,
         boolean: true,
         show_options: true,
         exit: 0

  def run
    api = AutomateApi.new(config[:fqdn], config[:enterprise], config[:verbose])
    response = api.request('get', 'runners', {})
    # We could probably just use response.length here as the response is a
    # list of hashes containing runner information, but I do a quick check to
    # make sure there's a hostname attribute on each result to make sure we
    # actually got runners back.
    count = response.select { |r| r['hostname'] }.length
    message "#{count} runners"
    count >= config[:count] ? ok : critical
  end
end
