#!/usr/bin/env ruby

require 'pp'
require 'jira'
require 'yaml'

def get_config
  conf_file = "config.yaml"
  begin
    config = YAML.load_file(conf_file)
  rescue Errno::ENOENT
    abort "Missing #{conf_file}!"
  end
  if config[:adminpassprog] == true
    config[:adminpass] = `#{config[:adminpass]}`
  end
  return config
end

config = get_config

username = config[:user]
password = config[:pass]

if (ARGV[0].nil?)
  summary = 'Test ticket from ruby script'
else
  summary = ARGV
end

summary = summary.join(' ')

site = 'https://jira.example.com'

options = {
  :username => username,
  :password => password,
  :site     => site,
  :auth_type => :basic,
  :ssl_verify_mode => 1,
  :context_path => ''
}

client = JIRA::Client.new(options)

issue = client.Issue.build
issue.save({
  'fields' => {
    'assignee' => { 'name' => username},
    'summary' => summary,
    'project' => {
      'id' => '17036' # PROJA
    },
    'issuetype' => {
      'id' => '43' # support
    }
  }
})

puts site + '/browse/' + issue.key
