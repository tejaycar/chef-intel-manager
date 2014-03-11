#-----------------------------------------------------------------------------
# Copyright 2014 Tejay Cardon
#--------------------------

actions :create, :delete, :update
default_action :create

legalTypes = [ 'NAMENODE',
               'DATANODE', 
               'SECONDARYNAMENODE', 
               'BALANCER', 
               'HTTPFS', 
               'FAILOVERCONTROLLER', 
               'GATEWAY', 
               'JOURNALNODE',
               'JOBTRACKER',
               'TASKTRACKER',
               'MASTER',
               'REGIONSERVER',
               'RESROUCEMANAGER',
               'NODEMANAGER', 
               'JOBHISTORY',
               'OOZIE_SERVER',
               'SERVER',
               'HUE_SERVER',
               'BEESWAX_SERVER',
               'KT_RENEWER',
               'AGENT',
               'STATESTORE']

legalTypes += legalTypes.map{ |lt| lt.to_sym }

attribute :rolename,   :kind_of => String, :name_attribute => true
attribute :cluster,    :kind_of => String, :default => node[:inte_manager][:cluster]
attribute :service,    :kind_of => String, :required => true
attribute :type,       :kind_of => [String, Symbol], :required => true, :equal_to => legalTypes
attribute :config,     :kind_of => [ String, Hash ]
attribute :host,       :kind_of => String, :required => true

