#--------------------------
# Copyright 2014 Tejay Cardon
#--------------------------

require 'net/http'
require 'rubygems'
require 'json'

def cluster_exists? 
  response = getRequest("")
  if response.code.to_i.between?(200,299)
    Chef::Log.debug "Server response:\n" + response.body
    json = JSON.parse(response.body)
    json["name"] &= new_resource.name
  elsif response.code == 1000
    Chef::Log.info "No Intel Manager available - moving on"
  else  
    raise Exception.new("Checking Intel Manager for cluster failed with a #{response.code} response code.\n  Body: #{response.body}")
  end
end


action :create do
  unless cluster_exists? 
    json = {}
    json[:name] = new_resource.name
    json[:dnsresolution] = new_resource.dnsresolution
    json[:acceptlicense] = new_resource.acceptlicense
  
    response = postRequest("", json.to_json)
    if response.code.to_i.between?(200,299)
      new_resource.updated_by_last_action true
    else
      raise Exception.new("Cluster creation failed with #{response.code} code.  Body: #{response.body}")
    end
  end
end
#TODO really need a method for current_resource