#-----------------------------------------------------------------------------
# Copyright 2014 Tejay Cardon
#--------------------------

require 'rubygems'
require 'json'

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
    raise Exception.new("#{new_resource.servicename} does not exist.")
  end
  
  if new_resource == current_resource
    Chef::Log.debug "#{new_resource.servicename} already in desired state."
  else
    doUpdate(response.body)
  end 
end

#TODO this is wrong.  How do we delete with Intel manager?
action :delete do
  action :delete do
  if current_resource.exists?
    response = DELETE_request("/hosts/#{new_resource.servicename}")
    if response.code.to_i.between?(200,299)
      new_resource.updated_by_last_action true
    else
      raise Exception.new("Delete of service #{new_resource.servicename} failed with #{response.code} code.  Body: #{response.body}")
    end
  else
    Chef::Log::debug "No Delete needed, service #{new_resource.servicename} does not exist"
  end 
end

# action :start do
#   verifyAttributes
#   response = getState
#   if response.code.to_i == 1000
#     Chef::Log::info "No cloudera-manager server available yet, skipping resource"
#   elsif response.code.to_i.between?(200, 299)
#     state = JSON.parse(response.body)['serviceState']
#     if state == "STOPPED" || state == "STOPPING"
#       Chef::Log::info "#{new_resource.servicename} on #{new_resource.cluster} in state #{state}.  Attempting to stop it"
#       waitUntilReady
#       response = postRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.servicename}/commands/start")
#       wait4Command2Complete(response, "start")
#     else
#      Chef::Log::info "#{new_resource.servicename} on #{new_resource.cluster} in state #{state}.  Cannot start. Skipping resource"
#     end
#   else
#     Chef::Log::info "Can't start #{new_resource.servicename} since it doesn't exist.  Error was #{response} #{response.body}"
#   end   
# end
# 
# action :stop do
#   verifyAttributes
#   response = getState
#   if response.code.to_i == 1000
#     Chef::Log::info "No cloudera-manager server available yet, skipping resource"
#   elsif response.code.to_i.between?(200, 299)  
#     state = JSON.parse(response.body)['serviceState']
#     if state == "STARTED" || state == "STARTING"
#       waitUntilReady
#       Chef::Log::info "#{new_resource.servicename} on #{new_resource.cluster} in state #{state}.  Attempting to stop it"
#       response = postRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.servicename}/commands/stop")
#       wait4Command2Complete(response, "stop")
#     else
#       Chef::Log::info "#{new_resource.servicename} on #{new_resource.cluster} in state #{state}.  Cannot stop. Skipping resource"
#     end
#   else
#     Chef::Log::info "Can't stop #{new_resource.servicename} since it doesn't exist"  
#   end
# end
# 
# action :restart do
#   verifyAttributes
#   response = getState
#   if response.code.to_i == 1000
#     Chef::Log::info "No cloudera-manager server available yet, skipping resource"
#   elsif response.code.to_i.between?(200, 299)
#     state = JSON.parse(response.body)['serviceState']
#     if state == "NA" || state == "UNKNOWN"
#       Chef::Log::info "#{new_resource.servicename} on #{new_resource.cluster} in state #{state}.  Cannot restart. Skipping resource"
#     else
#       waitUntilReady
#       Chef::Log::info "#{new_resource.servicename} on #{new_resource.cluster} in state #{state}.  Attempting to restart it"
#       if state == "STOPPED"
#         response = postRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.servicename}/commands/start")
#       else
#         response = postRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.servicename}/commands/restart")
#       end
#       wait4Command2Complete(response, "restart")
#     end
#   else
#     Chef::Log::info "Can't restart #{new_resource.servicename} since it doesn't exist"
#   end     
# end

def doCreate  
  body = {}
  body[:serviceName] = new_resource.name
  body[:type] = new_resource.type
  #TODO need to add configuration here
    
  response = POST_request("/services", json)
  if response.code.to_i.between?(200, 299)
    new_resource.updated_by_last_action true
  else
    raise Exception.new("Service creation of #{new_resource.servicename} failed with #{response.code} code.  Body: #{response.body}")
  end
end

# def doUpdate(startState)
# 	if ((new_resource.config.nil? || new_resource.config.empty?) && (new_resource.roleConfig.nil? || new_resource.roleConfig.empty?))
# 		Chef::Log::info "no configs to update with config = #{new_resource.config} and roleConfig = #{new_resource.roleConfig}"
# 		return
# 	end
# 
# 	json = toRoleConfig(new_resource.roleConfig).merge!(toConfigList(new_resource.config.nil? ? nil : new_resource.config))
# 	json = JSON.generate(json)
# 
# 	response = putRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.servicename}/config", json)
# 
# 	unless response.code.to_i.between?(200,299)
# 		raise Exception.new("Service update of #{new_resource.servicename} failed with #{response.code} code.  Body: #{response.body}")
# 	end
# 
# 	unless response.body == startState
# 		new_resource.updated_by_last_action true
# 	end
# end

def getState
  Chef::Log::debug "Checking the current state of #{new_resource.servicename} on #{new_resource.cluster}"
  response = getRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.servicename}")
  Chef::Log::debug "current state of #{new_resource.servicename} on #{new_resource.cluster} is #{response.body}"
  response
end

def waitUntilReady
  commands = []
  begin
    sleeptime = 1
    timeout(new_resource.timeout) do
      begin
        response = getRequest("/clusters/#{new_resource.cluster}/services/#{new_resource.servicename}/commands")
        commands = JSON.parse(response.body)['items']
        sleep 5
      end until commands.length == 0
    end
  rescue Timeout::Error
    raise Timeout::Error.new "Timed out waiting for commands to complete on #{new_resource.servicename} on #{new_resource.cluster}"
  end
end
  
def wait4Command2Complete(response, action)
  commandID = response.body[/"id" : (.*),/, 1]
  finished = false
  begin
    sleeptime = 1
    timeout(new_resource.timeout) do
      until finished
        sleep  sleeptime
        sleeptime *= 2
        results = getRequest("/commands/#{commandID}")
        finished = (results.body[/"active" : (.*),/, 1] == 'false')
        if finished && results.body[/"success" : (.*),/, 1] == 'true'
          new_resource.updated_by_last_action true
        elsif finished && new_resource.fail_on_error
          raise Exception.new "Cloudera Manager Service #{new_resource.servicename} #{action} failed:  #{results.body}"
        end
      end
    end
  rescue Timeout::Error
    raise Timeout::Error.new "Timed out waiting for namenode format to complete.  CommandID is #{commandID}"
  end
end  