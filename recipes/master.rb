#
# Author:: Matt Ray <matt@@chef.io>
# Cookbook:: chrony
# Recipe:: master
# Copyright:: 2011-2018 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

chrony_service_name = value_for_platform_family(
  %w(rhel fedora) => 'chronyd',
  'default' => 'chrony'
)

package 'chrony'

service 'chrony' do
  service_name chrony_service_name
  supports restart: true, status: true, reload: true
  provider Chef::Provider::Service::Systemd
  action %i(start enable)
end

# set the allowed hosts to the subnet
# ip = node.ipaddress.split('.')
# set the allowed hosts to the class B
# node['chrony'][:allow] = ["allow #{ip[0]}.#{ip[1]}"]

# if there are NTP servers, use the first 3 for the initslew
if node['chrony']['servers'].empty?
  clients = search(:node, 'recipes:chrony\:\:client').sort || []
  unless clients.empty?
    node.default['chrony']['initslewstep'] = 'initslewstep 10'
    count = 3
    count = clients.length if clients.length < count
    count.times { |x| node['chrony']['initslewstep'] += " #{clients[x].ipaddress}" }
  end
else
  node.default['chrony']['initslewstep'] = 'initslewstep 10'
  keys = node['chrony']['servers'].keys.sort
  count = 3
  count = keys.length if keys.length < count
  count.times { |x| node.default['chrony']['initslewstep'] += " #{keys[x]}" }
end

template '/etc/chrony/chrony.conf' do
  path platform_family?('rhel') ? '/etc/chrony.conf' : '/etc/chrony/chrony.conf'
  source 'chrony_master.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[chrony]'
end
