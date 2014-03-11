#-----------------------------------------------------------------------------
# Copyright 2014 Tejay Cardon
#--------------------------

action :create do
  if current_resource.exists?
    unless new_resource == current_resource
      doUpdate(response.body)
    end
  else
    doCreate()
  end    
end

action :update do
  unless current_resource.exists?
    raise Exception.new("#{new_resource.hostname} does not exist.")
  end
  
  if new_resource == current_resource
    Chef::Log.debug "#{new_resource.hostname} already in desired state."
  else
    doUpdate(response.body)
  end    
end
 
action :delete do
  if current_resource.exists?
    response = deleteRequest("/hosts/#{new_resource.hostname}")
    if response.code.to_i.between?(200,299)
      new_resource.updated_by_last_action true
    else
      raise Exception.new("Delete of host #{new_resource.hostname} failed with #{response.code} code.  Body: #{response.body}")
    end
  else
    Chef::Log::debug "No Delete needed #{new_resource.hostname} does not exist"
  end 
end

# action :addnodes do  
#   response = postRequest("nodes", json.to_json, new_resource.clusterName)
#   Chef::Log.info "recd response to add nodes #{response.body}"
#   data = JSON.parse(response.body)
#   unless data.length == 0 || data[:items].nil? || data[:items].length == 0
#     [:items].each do |nodedetail|
#       if nodedetail[:info] != "Connected"
# 	    Chef::Log.info "Connection failed to server #{nodedetail[:iporhostname]}"
# 	  end
#     end
#   end
# end

def doCreate
  Chef::Log.info "Adding node #{current_resource.name} to #{node[:intel_manager][:cluster]} cluster"
	config = {}
	config[:hostname] = new_resource.name
	config[:username] = new_resource.username
	config[:passphrase] = "" #TODO does this make sense?
	config[:authzkeyfie] = uploadedKey  #TODO need to implement a method for this
	config[:rackName] = new_resource.rackName

	body = {}
	body[:method] = "useauthzkeyfile"
	body[:nodeinfo] = [config]  
	
  response = postRequest("/nodes", body.to_json)
  if response.code.to_i.between?(200, 299)
    new_resource.updated_by_last_action true
  else
    raise Exception.new("Host creation of #{new_resource.hostname} failed with #{response.code} code.  Body: #{response.body}")
  end
end

#TODO doesn't work yet.  How does IM do rackID?
def doUpdate(startState)
  if (new_resource.rackID.nil? || new_resource.rackID.empty?)
    return
  end
  
  json = "{\"rackId\" : \"#{new_resource.rackID}\"}"
  
  response = putRequest("/hosts/#{new_resource.hostname}", json)
  
  unless response.code.to_i.between?(200,299)
    raise Exception.new("Host update of #{new_resource.hostname} failed with #{response.code} code.  Body: #{response.body}")
  end
  
  unless response.body == startState
    new_resource.updated_by_last_action true
  end
end