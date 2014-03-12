#-------------------
# Copyright 2014 Tejay Cardon
#-------------------

require 'net/http'
require 'rubygems'
require 'json'
require "uri"

def build_uri(path = "", cluster = "")
  manager = search(:node, "provides_intel_manager#{node[:intel_manager][:cluster]}:true")
  if manager && manager.ipaddress
    uri = "https://#{manager['ipaddress']}:#{manager[:intel_manager][:port]}/restapi/intelcloud/api/v2/cluster"
    uri += '/#{cluster}' if cluster
    uri += path
  else
    nil
  end
end

def toConfigList(source)
  output = ''
  unless (source.nil? || source.is_a?(Hash))
    raise Exception.new("Illegal data type (#{source.class}) in configuration - #{source.to_s}")
  end

  if (source.nil? || source.length == 0)
    return {:items => []}
  end

  json = {}
  json[:items] = []
  source.each do |name, value|
    json[:items] << {:name => name, :value => value.is_a?(String) ? value : JSON.generate(value)}
  end
  return json
end

def get_response(uri_string, request)
{
  request.basic_auth("admin","admin")
  uri = URI.parse(uri_string)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  return http.request(request)
}


def GET_request(path, cluster)
  uri_string = build_uri(path, cluster)
  if uri_string.nil?
    return imNotAvailable
  end

  request = Net::HTTP::Get.new(uri_string)

  Chef::Log.debug "sending get #{uri_string}"

  response = getResponse(uri_string, request)
end

def POST_request(path, cluster, message=nil)
  uri_string = build_uri(path, cluster)
  if uri_string.nil?
    return imNotAvailable
  end

  request = Net::HTTP::Post.new(uri_string)

  unless message.nil?
		request.body = message
		request['Content-Type'] = "application/json"
  end

  Chef::Log.debug "sending post #{uri_string}, body= #{message}"

  response = get_response(uri_string, request)
end

def POST_form(path, cluster, fileName)
  uri_string = build_uri(path, cluster)
  if uri_string.nil?
    return imNotAvailable
  end

#  request = Net::HTTP::Post.new(uri_string + path)
#  setAuth(request)
#  boundary = "boundary"
#  post_body = []
#  post_body << "--#{boundary}\r\n"
#  post_body << "Content-Disposition: form-data; name=\"datafile\"; filename=\"#{File.basename(fileName)}\"rn"
#  post_body << "Content-Type: text/plainrn"
#  post_body << "rn"
#  post_body << File.read(fileName)
#  post_body << "\r\n--#{boundary}--\r\n"
#  request.body = post_body.join
#  request.set_form_data({"file" => File.read(fileName)})
#  request['Content-Type'] = "multipart/form-data, boundary=#{boundary}"

  bash_command = "curl -k -u admin:admin -F \"file=@#{fileName}\" #{uri_string}"

  Chef::Log.info "sending post using command"
  Chef::Log.info "#{bash_command}"
  command_result = `#{bash_command}`

#  response = get_response(uri_string, request)
end

def PUT_request(path, cluster, message)
  uri_string = buid_uri(path, cluster)
  if uri_string.nil?
    return imNotAvailable
  end

  request = Net::HTTP::Put.new(uri_string)
  unless message.nil?
		request.body = message
		request['Content-Type'] = "application/json"
  end

  Chef::Log.debug "sending put #{uri_string}, body= #{message}"

  response = get_response(uri_string, request)
end

def deleteRequest(path, cluster)
  uri_string = build_uri(path, cluster)
  if uri_string.nil?
    return imNotAvailable
  end

  request = Net::HTTP::Delete.new(uri_string + path)

  Chef::Log.debug "sending delete #{uri_string}, body= #{message}"

  response = get_response(uri_string, request)
end

def manager_not_available()
  mockResponse = "Intel Manager not found"
  def mockResponse.code
    "1000"
  end
  def mockResponse.body
    self.to_s
  end
  mockResponse
end

