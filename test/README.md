PRE_REQs
==========
Vagrant - http://www.vagrantup.com/downloads.html
VirtualBox - https://www.virtualbox.org/wiki/Downloads
Vagrant omnibus plugin - `vagrant plugin install vagrant-omnibus

HOW TO TEST
==========
From the `test` directory, run `vagrant up`

This should:
1. Create a fake chef server on the 'master' node
2. Install Intel-Manager on the 'master' node
3. Install the hadoop master processes on the 'nn' node
4. Install the hadoop slaves on the 'dn' node

*NOTE: The memory requirements to run this test are high (12G).  
You can manually modify the Vagrantfile to reduce them, but this will slow the tests down.*