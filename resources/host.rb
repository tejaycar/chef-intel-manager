# Copyright 2014 Tejay Cardon

actions :create#, :delete, :update
default_action :create

#TODO can this be a hostname?  OR just IP?
attribute :hostname,       :kind_of => String, :regex => /\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/, :name_attribute => true
attribute :rackName,       :kind_of => String, :default => '/Default'
attribute :username,       :kind_of => String, :required => true
attribute :passphrase,     :kind_of => String  #TODO can we drop this?
attribute :authzkeyfile,   :kind_of => String
attribute :privateKeyPath, :kind_of => String, :default => "~/.ssh/id_rsa"
attribute :cluster,        :kind_of => String, :default => node[:intel_manager][:cluster]


