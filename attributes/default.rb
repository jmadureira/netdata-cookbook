# Netdata user name. Since it is not possible to specify the user during installation do not change this.
# Defaults to netdata.
default['netdata']['user'] = 'netdata'

# Netdata group name. Since it is not possible to specify the group during installation do not change this.
# Defaults to netdata.
default['netdata']['group'] = 'netdata'

# Netdata source repository
default['netdata']['source']['git_repository'] = 'https://github.com/firehol/netdata.git'

# Netdata source repository git reference.
# Can be a tag, branch or master.
# Defaults to master.
default['netdata']['source']['git_revision'] = 'master'

# Local directory where the netdata repo will be cloned
# Defaults to /tmp/netdata but should be replaced because most UNIX system
# periodically clean the /tmp directory
default['netdata']['source']['directory'] = '/tmp/netdata'

########################################################################
# Netdata configuration
########################################################################

# Map with attributes to add to the netdata.conf file.
# Defaults to an empty map which will leave the default conf file unchanged.
default['netdata']['conf'] = {}

########################################################################
# Python plugin configuration
########################################################################
# Enabled/Disable mysql module
# If set to true will also install all necessary dependencies
# Defaults to false
default['netdata']['plugins']['python']['mysql']['enabled'] = false
