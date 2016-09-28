# Netdata source repository
default['netdata']['source']['git_repository'] = 'https://github.com/firehol/netdata.git'

# Netdata source repository git reference.
# Can be a tag, branch or master.
# Defaults to master.
default['netdata']['source']['git_revision'] = 'master'

########################################################################
# Python plugin configuration
########################################################################
# Enabled/Disable mysql module
# If set to true will also install all necessary dependencies
# Defaults to false
default['netdata']['plugins']['python']['mysql']['enabled'] = false
