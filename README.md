intel_manager Cookbook
=============================
This cookbook is used to install intel-Manger and Intel hadoop components and to configure the hadoop components via intel Manager's REST API.

Requirements
------------
* Yum must be configured to reach Intel's Manager RPMS.  

Attributes
----------
#### General settings
* `node[:intel][:cluster]` - The name of your Intel cluster *defaults to `node[:cluster]` if present*
* `node[:intel][:server][:port]` - port for the Intel Manager API and UI

#### Security Settings
If no databag is provided then the default admin:admin user will be the only user available.  If a `master` 
item is provided in the databag, then the default admin user will be removed from the cluster.  
Otherwise, the default admin user will remain.
* `node[:intel][:server][:user_databag]` - Name of the databag to pull intel manager users from  *see format below*
* `node[:intel][:server][:user_databag_key_file]` - URI from which to get the decription key for the intel manager user databag

#### Databags
The `user_databag` holds all users that should be created for the intel manager server.  The databag should hold two items.  
The first is `master` and contains the primary admin account.
The other is `users` and holds all other users.
follow this format:
`master.json`
```
{
  "id": "master",
  "username": "admin",
  "password": "secret"
}
```

`users.json`
```
{
  "id": "users"
  "list": [
    {
      "username": "jimmy",
      "password": "secret",
      "admin": true
    },
    {
      "username: "clair",
      "password": "secret",
      "admin": false
    }
  ]
}
```

To create the encrypted databag you follow the instuctions here:
http://docs.opscode.com/essentials_data_bags.html

      

Usage
-----
#### intel-manager::server
Installs the intel manager server and configures any users from the databag (if set).

Just include `intel-manager::server` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[intel-manager::server]"
  ]
}
```

#### intel-manager::agent
Installs the intel manager agent daemons.

Just include `intel-manager::agent` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[intel-manager::agent]"
  ]
}
```