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
# Python plugin configuration
########################################################################
# Enabled/Disable mysql module
# If set to true will also install all necessary dependencies
# Defaults to false
default['netdata']['plugins']['python']['mysql']['enabled'] = false

########################################################################
# Nginx plugin configuration
########################################################################
# Netadata Nginx python configuration
# Accepts a hash of job name -> job configuration entries that will be merged with the default configuration.
# Defaults to the original netdata configuration
default['netdata']['plugins']['python']['nginx']['config'] = {
  'localhost' => {
    'name' => 'local',
    'url' => 'http://localhost/stub_status'
  },
  'localipv4' => {
    'name' => 'local',
    'url' => 'http://127.0.0.1/stub_status'
  },
  'localipv6' => {
    'name' => 'local',
    'url' => 'http://::1/stub_status'
  }
}
