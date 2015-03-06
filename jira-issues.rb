#!/usr/bin/env ruby

require 'pp'
require 'jira'
require 'formatador'
require 'yaml'

def get_config
  conf_file = "config.yaml"
  begin
    config = YAML.load_file(conf_file)
  rescue Errno::ENOENT
    abort "Missing #{conf_file}!"
  end
  if config[:passprog] == true
    config[:pass] = `#{config[:adminpass]}`
  end
  return config
end

config = get_config
username = config[:user]
password = config[:pass]

if (ARGV[0].nil?)
  jql = 'project = PROJA AND resolution IS EMPTY'
else
  jql = ARGV[0..-1].join(' ')
end

options = {
  :username => username,
  :password => password,
  :site     => 'https://jira.example.com/',
  :auth_type => :basic,
  :ssl_verify_mode => 1,
  :context_path => ''
}

client = JIRA::Client.new(options)

project = client.Project.find('PROJA')

issue_table = []
client.Issue.jql(jql).each do |issue|
  assignee = issue.fields['assignee']['displayName'] ? issue.fields['assignee']['displayName'] : 'Unassigned'
  issue_table << issue_hash = {
    :assignee => assignee,
    :issuetype => issue.fields['issuetype']['name'],
    :summary => issue.fields['summary'],
    :ticket => issue.key
  }
end

Formatador.display_compact_table(issue_table, [:ticket, :assignee, :issuetype, :summary])
