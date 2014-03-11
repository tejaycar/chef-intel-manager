#----------------------------
# Copyright 2014 Tejay Cardon
#----------------------------

def prereqs
  response = getRequest("/hosts/#{new_resource.host}")
  haveHost = response.code.to_i.between?(200,299)
  unless haveHost
    Chef::Log::info "Can't execute on this resource until host #{new_resource.host} is available"
    return false
  end

  haveService = getRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.service}").code.to_i.between?(200,299)
  unless haveService
    Chef::Log::info "Can't execute on this resource until service #{new_resource.service} is available"
    return false
  end 
  
  return true
end

action :create do
  if prereqs
    if current_resource.exists?
      unless current_resource == new_resource
        doUpdate(response.body)
      end
    else
      doCreate()
    end
  end
end

action :create_if_missing do
  unless current_resource.exists?
    doCreate() if prereqs
  end
end

action :update do
  if prereqs
    if current_resource.exists?
      if current_resource == new_resource
        Chef::Log.debug "#{current_resource.name} is already in the desired state"
      else
        doUpdate(response.body)
      end
    else
      raise Exception.new("#{new_resource.rolename} does not exist.")
    end
  end
end

def doCreate
  body = {}
  body[:rolename] = new_resource.type
  body[:hostname] = new_resource.host
  #TODO need config stuff here too, right??
  
  response = POST_request("/services/${service}/roles", body.to_json)
  if response.code.to_i.between?(200, 299)
    new_resource.updated_by_last_action true
  else
    raise Exception.new("Role creation of #{new_resource.rolename} failed with #{response.code} code.  Body: #{response.body}")
  end
end

def doUpdate(startState)# 
#   if (new_resource.config.nil? || new_resource.config.empty?)
#     return
#   end
#   
#   json = "{\n" + toConfigList(new_resource.config.values) + "}"
#   
#   response = putRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.rolename}/config", json)
#   
#   unless response.code.to_i.between?(200,299)
#     raise Exception.new("Service update of #{new_resource.rolename} failed with #{response.code} code.  Body: #{response.body}")
#   end
#   
#   unless response.body == startState
#     new_resource.updated_by_last_action true
#   end
# end
#  
# action :delete do
#   verifyAttributes
#   response = getRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.service}/roles/#{new_resource.rolename}/config")
#   if response.code.to_i == 1000
#     Chef::Log::info "No cloudera-manager server available yet, skipping resource"
#   elsif response.code.to_i.between?(200, 299)
#     response = deleteRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.service}/roles/#{new_resource.rolename}")
#     if response.code.to_i.between?(200,299)
#       new_resource.updated_by_last_action true
#     else
#       raise Exception.new("Delete of role #{new_resource.rolename} failed with #{response.code} code.  Body: #{response.body}")
#     end
#   else
#     Chef::Log::info "No Delete needed #{new_resource.rolename} does not exist"
#   end 
# end

