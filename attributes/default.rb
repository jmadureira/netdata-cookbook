# All attributes are deprecated, please use the Netdata custom resources

# Netdata source repository
default['netdata']['source']['git_repository'] =
  'https://github.com/firehol/netdata.git'

# Netdata source repository git reference.
default['netdata']['source']['git_revision'] = 'master'

# Local directory where the netdata repo will be cloned
default['netdata']['source']['directory'] = '/tmp/netdata'

# Enabled/Disable mysql module
# If set to true will also install all necessary dependencies
default['netdata']['plugins']['python']['mysql']['enabled'] = false
