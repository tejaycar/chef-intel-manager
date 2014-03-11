#-----------------------------------------------------------------------------
# Copyright 2014 Tejay Cardon
#--------------------------

action :run do  
  dependenciesMet = new_resource.requires.nil? ? true : checkDependencies
  
  if dependenciesMet
    case new_resource.type
    when :GET
      results = getRequest(new_resource.endpoint)
    when :PUT
      results = putRequest(new_resource.endpoint, new_resource.json)
    when :POST 
      results = postRequest(new_resource.endpoint, new_resource.json)
    when :DELETE
      results = deleteRequest(new_resource.endpoint)
    end
    
    if results.nil? || !results.code.to_i.between?(200, 299)
      raise Exception.new "Intel Manager command [#{new_resource.name}] failed.  Error code is #{results.code} and error body is: #{results.body}"
    elsif new_resource.wait4complete
      wait4completion(result) 
    else
      new_resource.updated_by_last_action true
    end
  else
    puts "(skipped due to unmet dependencies)"
  end
end
  
def checkDependencies
  if new_resource.requires.is_a?(String)
    result = getRequest(new_resource.requires)
    dependenciesMet = result.code.to_i.between?(200,299)
  elsif new_resource.requires.is_a?(Hash)
    unless new_resource.requires[:endpoint] && new_resource.requires[:check].is_a?(Proc)
      raise Exception.new "when passing a hash to the \"requires\" attribute of intel-manager-command, it must have two elements
      1. :endpoint => the string endpoint to request, this request is sent to the \"check\"
      2. :check => a proc object which will be called with the results of a GET request to \":endpoint\""
    end
    result = getRequest(new_resource.requires[:endpoint])
    dependenciesMet = new_resource.requires[:check].call(result)
  else
    raise Exception.new "intel-manager-command attribute \"requires\" must be a String or a Hash.  You had #{new_resource}"
  end
  Chef::Log::debug "Result of dependency check on intel-manager-command[#{new_resource.name}] was: #{result.body}" unless dependenciesMet
  dependenciesMet
end    

def wait4completion(result)
	sessionid = JSON.parse(response.body)["sessionID"]
	finished = false
		begin
			sleeptime = 1
			timeout(new_resource.timeout) do
			until finished do
				sleep sleeptime
				sleeptime *=2 unless sleeptime >= 10
				Chef::Log.info "checking session #{sessionID}"
			
				p = checksession(sessionID, clusterName)

				finished = JSON.parse(p.body)["items"].first["nodeprogress"]["info"] == "_ALLFINISH\n"
				# if finished && results.body[/"success" : (.*),/, 1] == 'true'
# 					new_resource.updated_by_last_action true
# 				elsif finished && new_resource.fail_on_error
# 					raise Exception.new "Cloudera Manager Command #{new_resource.name} failed:  #{results.body}"
# 				end
			end
#       rescue Timeout::Error
# 			results = getRequest("/commands/#{commandID}")
# 			raise Timeout::Error.new "Timed out waiting for namenode format to complete.  CommandID is #{commandID}, and state is: #{result.body}"
# 		end  
  end	
end

#TODO still need to copy over the checksession method from intel's host provider
