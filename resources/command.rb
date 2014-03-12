#----------------------------
# Copyright 2014 Tejay Cardon
#----------------------------

actions :run
default_action :run

attribute :endpoint,	     :kind_of => String, :name_attribute => true
attribute :body,		       :kind_of => [String, Hash]
attribute :type,           :kind_of => Symbol, :default => :POST, :equal_to => [:POST, :GET, :DELETE, :PUT]
attribute :wait4complete,  :kind_of => [TrueClass, FalseClass], :default => true
attribute :timeout,        :kind_of => Integer, :default => 300 #5 minutes
attribute :fail_on_error,  :kind_of => [TrueClass, FalseClass], :default => true #if true a failed command will raise an exception, if false it will result in the resource returning as not updated
attribute :requires,       :kind_of => [String, Hash], :default => nil
attribute :cluster,        :kind_of => String, :default => ""


