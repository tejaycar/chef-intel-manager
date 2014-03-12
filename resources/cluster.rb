# Copyright 2014 Tejay Cardon

actions :create#, :delete, :update, :start, :stop, :restart
default_action :create

attribute :cluster,          :kind_of => String, :name_attribute => true
#attribute :config,          :kind_of => [ String, Hash ]
attribute :dnsresolution,    :kind_of => String, :default => 'true' #TODO
attribute :acceptlicense,    :kind_of => String, :default => 'true' #TODO