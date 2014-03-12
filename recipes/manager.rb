#------------------------------
# Copyright 2014 Tejay Cardon
#------------------------------

tarball_name = node[:intel_manager][:tarball].split('/').last
unpacked_name = tarball_name.sub('.tar.gz', '')

tempdir = "#{Chef::Config[:file_cache_path]}/intel_manager"
directory tempdir

remote_file "#{tempdir}/#{tarball_name}" do
  source  node[:intel_manager][:tarball]
  not_if { ::File.exist?("/etc/init.d/intel-manager") }
end

execute 'unpack intel install' do
  command  "tar xzf #{tarball_name}"
  cwd      tempdir
  not_if   { ::Directory.exits?("#{tempdir}/#{unpacked_name}") }
  only_if  { ::File.exists?("#{tempdir}/#{tarball_name}") }
end

template 'install configuration' do
  path    "#{tempdir}/#{unpacked_name}/ui-installer/conf"
  source  'install_conf.erb'
  only_if { ::Directory.exits?("#{tempdir}/#{unpacked_name}/ui-installer" }
end

execute 'install intel manager' do
  command  './install.sh'
  cfw      "#{tempdir}/#{unpacked_name}"
  not_if   { ::File.exists?('/etc/init.d/intel-manager') }
  only_if  { ::File.exists?("#{tempdir}/#{unpacked_name}/ui-installer/conf") }
  only_if  { ::File.exists?("#{tempdir}/#{unpacked_name}/install.sh") }
end
  
  