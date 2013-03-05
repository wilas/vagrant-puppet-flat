# Description

Single file puppet manifest. Modular version: [vagrant-puppet-modules](https://github.com/wilas/vagrant-puppet-modules)

## VM description

 - OS: Scientific linux 6
 - simple vm: pie.farm

## Learned lessons

 - prepare own vagrant box: scientific linux 6 x86_64 (now [veewee-boxarium](https://github.com/wilas/veewee-boxarium))
 - simple Vagrantfile with puppet provisioning, share folder
 - use stage in puppet manifest
 - manage yum repos (tags, resource collecions )
 - install some packages
 - manage users (virtual resources)
 - manage ssh key authentication
 - use hiera

## Howto

 - create SL6 box using [veewee-boxarium](https://github.com/wilas/veewee-boxarium)
 - copy ssh_keys from [ssh-gerwazy](https://github.com/wilas/ssh-gerwazy)

```
    vagrant up
    ssh root@localhost -p 2222
    ssh emu@localhost -p 2222
    ssh elk@localhost -p 2222
    vagrant destroy
```


## Bibliography

### Puppet

 - !!! learning puppet: http://docs.puppetlabs.com/learning/index.html
 - !!! puppet cookbook: http://puppetcookbook.com/
 - !!! puppet resource type: http://docs.puppetlabs.com/references/3.1.latest/type.html
 - puppet styl guide: http://docs.puppetlabs.com/guides/style_guide.html
 - puppet language guide: http://docs.puppetlabs.com/puppet/3/reference/lang_summary.html
 - puppet custom types: http://docs.puppetlabs.com/guides/custom_types.html
 - puppet best practice: http://projects.puppetlabs.com/projects/puppet/wiki/Puppet_Best_Practice2
 - puppet open-source: http://puppetlabs.com/puppet/puppet-open-source/
 - puppet forge: http://forge.puppetlabs.com/
 - puppet lang. scope: http://docs.puppetlabs.com/puppet/3/reference/lang_scope.html
 - puppet hiera: http://docs.puppetlabs.com/hiera/1/index.html
 - puppet hiera: https://puppetlabs.com/blog/first-look-installing-and-using-hiera/
 - puppet3: http://docs.puppetlabs.com/puppet/3/reference/index.html
 - good practice (#PUPPETHEADER): http://www.slideshare.net/PuppetLabs/creating-a-mature-puppet-system-16815622
 - what not to do: http://www.slideshare.net/PuppetLabs/whatnottodo
 - community: http://docs.puppetlabs.com/community/community_guidelines.html
 - use puppet modules: https://github.com/wilas/vagrant-puppet-modules
 - use puppet hiera: https://github.com/wilas/vagrant-puppet-hiera
 - !! more links: http://blog.andreas-haerter.com/2012/02/05/how-to-start-puppet-system-config-links-resources-tutorials


### Puppet IDE

 - !!! vim + puppet: https://github.com/puppetlabs/puppet/tree/master/ext/vim
 - !!! geppetto + eclipse: http://puppetlabs.com/blog/geppetto-a-puppet-ide/
 - geppetto project: http://cloudsmith.github.com/geppetto/index.html

### Vagrant

 - vagrant basic: http://vagrantup.com/v1/docs/getting-started/index.html
 - vagrant environments: http://nefariousdesigns.co.uk/vagrant-virtualised-dev-environments.html
 - howto create vagrant box: http://blog.vandenbrand.org/2012/02/21/creating-a-centos-6-2-base-box-for-vagrant/
 - howto create vagrant box: http://pyfunc.blogspot.co.uk/2011/11/creating-base-box-from-scratch-for.html
 - why vagrant: http://www.ichilton.co.uk/blog/virtualization/my-phpne-talk-on-vagrant-496.html

## Copyright and license

Copyright 2012, Kamil Wilas (wilas.pl)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this work except in compliance with the License.
You may obtain a copy of the License in the LICENSE file, or at:

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

