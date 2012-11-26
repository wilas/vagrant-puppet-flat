# Single file puppet manifest and vagrant


## Learned lessons

 - prepare own vagrant box: scientific linux 6.2 x86_64 (now [veewee-SL64-box](https://github.com/wilas/veewee-SL64-box)
 - simple Vagrantfile with puppet provisioning, share folder
 - use stage in puppet manifest
 - manage yum repos (tags, resource collecions )
 - install some packages
 - manage users (virtual resources)
 - manage ssh key authentication

## Howto

    create SL64_box using [veewee-SL64-box](https://github.com/wilas/veewee-SL64-box)
    copy ssh_keys from [ssh-gerwazy](https://github.com/wilas/ssh-gerwazy)
    vagrant up
    ssh root@localhost -p 2222
    vagrant destroy

## Bibliography

### Puppet

 - !!! learning puppet: http://docs.puppetlabs.com/learning/index.html
 - !!! puppet resource type: http://docs.puppetlabs.com/references/2.7.6/type.html
 - puppet styl guide: http://docs.puppetlabs.com/guides/style_guide.html
 - puppet language guide: http://docs.puppetlabs.com/puppet/2.7/reference/lang_summary.html
 - puppet custom types: http://docs.puppetlabs.com/guides/custom_types.html
 - best practice: http://projects.puppetlabs.com/projects/puppet/wiki/Puppet_Best_Practice2
 - !!! puppet cookbook: http://puppetcookbook.com/
 - !!! vim + puppet: https://github.com/puppetlabs/puppet/tree/master/ext/vim
 - !!! geppetto + eclipse: http://puppetlabs.com/blog/geppetto-a-puppet-ide/
 - puppet open-source: http://puppetlabs.com/puppet/puppet-open-source/
 - puppet forge: http://forge.puppetlabs.com/
 - !! more links here: http://blog.andreas-haerter.com/2012/02/05/how-to-start-puppet-system-config-links-resources-tutorials

### Vagrant

 - vagrant basic: http://vagrantup.com/v1/docs/getting-started/index.html
 - vagrant environments: http://nefariousdesigns.co.uk/vagrant-virtualised-dev-environments.html
 - howto create vagrant box: http://blog.vandenbrand.org/2012/02/21/creating-a-centos-6-2-base-box-for-vagrant/
 - howto create vagrant box: http://pyfunc.blogspot.co.uk/2011/11/creating-base-box-from-scratch-for.html
 - why vagrant: http://www.ichilton.co.uk/blog/virtualization/my-phpne-talk-on-vagrant-496.html

## Copyright and license

Copyright 2012, the vagrant-puppet-flat authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this work except in compliance with the License.
You may obtain a copy of the License in the LICENSE file, or at:

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

