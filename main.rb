#!/usr/bin/env ruby
# frozen_string_literal: true

#https://stackoverflow.com/a/16043385/965722
def load_gem(name, version=nil)
  # needed if your ruby version is less than 1.9
  require 'rubygems'

  begin
    gem name, version
  rescue LoadError
    version = "--version '#{version}'" unless version.nil?
    system("gem install #{name} #{version}")
    Gem.clear_paths
    retry
  end

  require name
end

load_gem 'mail'

# Inputs
server_address = ENV['INPUT_SERVER_ADDRESS']
server_port = ENV['INPUT_SERVER_PORT']
username = ENV['INPUT_USERNAME']
password = ENV['INPUT_PASSWORD']
subject = ENV['INPUT_SUBJECT']
body = ENV['INPUT_BODY']
to = ENV['INPUT_TO']
from = ENV['INPUT_FROM']
content_type = ENV['INPUT_CONTENT_TYPE'] || 'text/plain'

# Body
prefix = 'file://'
body = if body.start_with?(prefix)
         path = body.delete_prefix(prefix)
         File.read(path)
       else
         body
       end

puts "Body: #{body}"
body = body.gsub(/\n/, '<br/>')
puts "Body: #{body}"

# Send
begin
  Mail.defaults do
  delivery_method :smtp, address: server_address, port: server_port, user_name: username, password: password, enable_ssl: true, authentication: 'login'
  end
         
  mail = Mail.new do
    to to
    from from
    subject subject
    
    text_part do
      body body
    end

    html_part do
      content_type 'text/html; charset=UTF-8'
      body body
    end
    
  end

  mail.deliver

rescue StandardError => e
  puts "Error: #{e.message}"
  exit 1
end
