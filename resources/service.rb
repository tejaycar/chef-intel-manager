#-----------------------------------------------------------------------------
# Copyright 2014 Tejay Cardon
#--------------------------

actions :create, :delete, :update, :start, :stop, :restart
default_action :create

serviceTypes = ['HDFS', 'MAPREDUCE', 'HBASE', 'OOZIE', 'ZOOKEEPER', 'HUE', 'YARN', 'FLUME']
serviceTypes += serviceTypes.map{|st| st.to_sym}

attribute :servicename,   :kind_of => String, :name_attribute => true
attribute :cluster,       :kind_of => String, :default => node[:intel_manager][:cluster], :required => true
attribute :type,          :kind_of => [String, Symbol], :required => true, :equal_to => serviceTypes
attribute :config,        :kind_of => [ String, Hash ]
attribute :timeout,       :kind_of => Integer, :default => 60000 #100 minutes