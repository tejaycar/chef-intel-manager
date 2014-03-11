#-----------------------------------------------------------------------------
# Copyright 2014 Tejay Cardon
#--------------------------

actions :create, :delete, :update, :create_if_missing
default_action :create

attribute :username,   :kind_of => String, :name_attribute => true
attribute :cluster,    :kind_of => String, :default => node[:intel_manager][:cluster]
attribute :admin,      :kind_of => [TrueClass, FalseClass], :default => false
attribute :password,   :kind_of => String, :required => true

