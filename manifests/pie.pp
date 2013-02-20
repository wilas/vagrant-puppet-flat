stage { "base": before  => Stage["main"] }
stage { "last": require => Stage["main"] }

class install_repos {
    include install_repos::epel
    include install_repos::puppetlabs
}

class install_repos::epel {

    file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6":
        ensure => file,
        owner  => "root",
        group  => "root",
        mode   => "0444",
        source => "/vagrant/files/RPM-GPG-KEY-EPEL-6",
    }

    yumrepo { 
        "epel":
            enabled    => hiera('enabled_epel',0),
            descr      => 'Extra Packages for Enterprise Linux 6 - $basearch',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
            tag        => 'epel';
        "epel-debuginfo":
            enabled    => hiera('enabled_epel_debuginfo',0),
            descr      => 'Extra Packages for Enterprise Linux 6 - $basearch - Debug',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch',
            tag        => 'epel';
        "epel-source":
            enabled    => hiera('enabled_epel_source',0),
            descr      => 'Extra Packages for Enterprise Linux 6 - $basearch - Source',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch',
            tag        => 'epel';
        "epel-testing":
            enabled    => hiera('enabled_epel_testing',0),
            descr      => 'Extra Packages for Enterprise Linux 6 - Testing - $basearch',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=testing-epel6&arch=$basearch',
            tag        => 'epel';
        "epel-testing-debuginfo":
            enabled    => hiera('enabled_epel_testing_debuginfo',0),
            descr      => 'Extra Packages for Enterprise Linux 6 - Testing - $basearch - Debug',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=testing-debug-epel6&arch=$basearch',
            tag        => 'epel';
        "epel-testing-source":
            enabled    => hiera('enabled_epel_testing_source',0),
            descr      => 'Extra Packages for Enterprise Linux 6 - Testing - $basearch - Source',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=testing-source-epel6&arch=$basearch',
            tag        => 'epel';
    }
    
    Yumrepo <| tag == 'epel' |> { 
        failovermethod => 'priority',
        gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6',
        gpgcheck       => 1,
        require        => File["/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6"],
    }
}

class install_repos::puppetlabs {

    file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs":
        ensure => file,
        owner  => "root",
        group  => "root",
        mode   => "0444",
        source => "/vagrant/files/RPM-GPG-KEY-puppetlabs",
    }

    yumrepo { 
        "puppetlabs-products":
            enabled  => hiera('enabled_puppetlabs_products',0),
            descr    => 'Puppet Labs Products EL 6 - $basearch',
            baseurl  => 'http://yum.puppetlabs.com/el/6/products/$basearch',
            tag      => 'puppet';
        "puppetlabs-deps":
            enabled  => hiera('enabled_puppetlabs_deps',0),
            descr    => 'Puppet Labs Dependencies EL 6 - $basearch',
            baseurl  => 'http://yum.puppetlabs.com/el/6/dependencies/$basearch',
            tag      => 'puppet';
        "puppetlabs-devel":
            enabled  => hiera('enabled_puppetlabs_devel',0),
            descr    => 'Puppet Labs Devel EL 6 - $basearch',
            baseurl  => 'http://yum.puppetlabs.com/el/6/devel/$basearch',
            tag      => 'puppet';
    }
    
    Yumrepo <| tag == 'puppet' |> { 
        gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
        gpgcheck       => 1,
        require        => File["/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs"],
    }
}

class basic_package {

    $basic_pkg = hiera_array('basic_package')
    package { $basic_pkg:
        ensure => installed,
    }

    $basic_erase_pkg = hiera_array('basic_erase_package', undef)
    if $basic_erase_pkg {
        package { $basic_erase_pkg:
            ensure => absent,
        }
    }

    # package from vagrant box creation
    $vagrant_pkg = hiera_array('vagrant_box_package', undef)
    if $vagrant_pkg {
        package { $vagrant_pkg:
            ensure => installed,
        }
    }

    # gem package
    $gem_pkg = hiera_array('gem_package', undef)
    if $gem_pkg {
        package { $gem_pkg:
            ensure   => installed,
            provider => "gem",
            require  => Package["rubygems"],
        }
    }
}

class user {

    define user_attune( $username, $meta_attune="user" ){
        
        # Resource's name/title in puppet must be unique, so filename is hidden in resource name.
        # (e.g: users: emu and elk want define own .bashrc, resource name can't be .bashrc, but can be emu-.bashrc and elk-.bashrc)
        $filename = split($name,"${username}-")
        # notice ("Mirror, mirror, tell me true: filename is ${filename}")
        
        file { "/home/${username}/${filename}":
            source  => "/vagrant/files/user/${meta_attune}-${filename}",
            owner   => $username,
            group   => $username,
            recurse => true,
        }
    }

    define plain_user ( $uid, $ensure = "present", $attune = false, $meta_attune="user" ){
    
        # Absent not delete user home_dir: http://projects.puppetlabs.com/issues/9294
        user { $name:
            ensure     => $ensure,
            home       => "/home/${name}",
            managehome => true,
            uid        => $uid,
        }
      
        group { $name:
            ensure  => $ensure,
            gid     => $uid,
            require => User[$name]
        }

        # Users are able to change their own passwords and puppet doesn't overwrite changes
        if $ensure == "present" {
            exec { "/vagrant/tools/setpassword.sh $name":
                path    => "/bin:/usr/bin",
                require => User[$name],
                unless  => "grep $name /etc/shadow | cut -f 2 -d : | grep -v '!'",
            }
        }

        if $ensure == "present" and $attune {
            # make $name of user_attune unique
            # notice ("Mirror, mirror, tell me true: attune is ${attune}")
            $attunefix = regsubst($attune,'([.]+)',"${name}-\0",'G')
            # notice ("Mirror, mirror, tell me true: attunefix is ${attunefix}")
            user_attune { $attunefix:
                username    => $name,
                meta_attune => $meta_attune,
                require     => User[$name],
            }
        }

    }

    define ssh_user ($uid, $key, $ensure = "present", $attune = false, $meta_attune="user"){

        plain_user { $name:
            uid         => $uid,
            ensure      => $ensure,
            attune      => $attune,
            meta_attune => $meta_attune,
        }
        
        if $ensure == "present" {
            ssh_authorized_key { "${name}_key":
                key    => $key,
                type   => "ssh-rsa",
                user   => $name,
            }
        }
    }
}

class user::root {
    
    define root_attune { 
        file { $name:
            ensure  => present,
            source  => "/vagrant/files${name}",
            owner   => "root",
            group   => "root",
            recurse => true,
        }
    }

    ssh_authorized_key { "root_key":
        key    => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzklfofBRMF0doSKawOD0NQaq2z5VJUnsE3KNvEOln+l2BwHM2k2IdEXIfgR+BGUy+wz2wbDSiHVSEoqxX9tfnZSYxdI3IH8goNkkjdKy16r/cm/QEn5sSXgu0RowegTIKplFYU1CWNPlCViGXoUVatwEC2Byo9tz7/kMebQetAoeEMkRH0t/3pkgWqNHy8PDYUASp8PUnKUFcWhUyEokzfPxFllDBjdcMKpx6Iwk/iX/3LNmkXZvSQ6fbNj4a4oCKyx8BJBosUX/bopa0rhCZ6NGP0FHZsLZ9STO8fM5O921kMn7cDxe1MQwDTzvTl9ZJIfCzgZoySqHQ82JzR4nSQ==",
        type   => "ssh-rsa",
        user   => "root",
    }

    root_attune { [ "/root/.vimrc", "/root/.bashrc", "/root/.vim", "/root/.tmux.conf", ]: }
}

# Class manage virtual users (plain_user and ssh_user)
class user::virtual {

    @user::ssh_user { "elk": 
        uid    => "505",
        key    => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzklfofBRMF0doSKawOD0NQaq2z5VJUnsE3KNvEOln+l2BwHM2k2IdEXIfgR+BGUy+wz2wbDSiHVSEoqxX9tfnZSYxdI3IH8goNkkjdKy16r/cm/QEn5sSXgu0RowegTIKplFYU1CWNPlCViGXoUVatwEC2Byo9tz7/kMebQetAoeEMkRH0t/3pkgWqNHy8PDYUASp8PUnKUFcWhUyEokzfPxFllDBjdcMKpx6Iwk/iX/3LNmkXZvSQ6fbNj4a4oCKyx8BJBosUX/bopa0rhCZ6NGP0FHZsLZ9STO8fM5O921kMn7cDxe1MQwDTzvTl9ZJIfCzgZoySqHQ82JzR4nSQ==",
        attune => [".bashrc", ".vimrc", ".vim"],
    }

    @user::ssh_user { "yak": 
        uid    => "506",
        key    => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzklfofBRMF0doSKawOD0NQaq2z5VJUnsE3KNvEOln+l2BwHM2k2IdEXIfgR+BGUy+wz2wbDSiHVSEoqxX9tfnZSYxdI3IH8goNkkjdKy16r/cm/QEn5sSXgu0RowegTIKplFYU1CWNPlCViGXoUVatwEC2Byo9tz7/kMebQetAoeEMkRH0t/3pkgWqNHy8PDYUASp8PUnKUFcWhUyEokzfPxFllDBjdcMKpx6Iwk/iX/3LNmkXZvSQ6fbNj4a4oCKyx8BJBosUX/bopa0rhCZ6NGP0FHZsLZ9STO8fM5O921kMn7cDxe1MQwDTzvTl9ZJIfCzgZoySqHQ82JzR4nSQ==",
        ensure => absent,
    }

    @user::ssh_user { "emu":
        uid         => "507",
        key         => "AAAAB3NzaC1yc2EAAAABIwAAAQEA30Z4O2kddLLTuhZPT/WlJ29qZ5stFcGG0srP4Ga/GuRtJdXdQBRMchtoK4Jm7HWRSJhaX65QZQDitByko9Hcetq5tdL/VV+gXe2yBhN1wsTCPpefx2fOPkJdv+izCoAdEmSYUlRo9KuuJwsZxPk1eTkf89o0zkukVDwvGN0M16IeJx9x2y/V+JUSAGCMzEG8Vjjw2VQqKrhg12nLnub4vOzaZxi+QAQJEzcI/TyrB/Jtyl3nZ+gFXlJWoWhmwgSK691CqqR1FZ+QyxMIHxS47Q5/vjO7k8Z34K1L95piwtFGRKU6f64dDidzfbAvqdUQCdC6QMZ4A+eqet98XxmXjQ==",
        attune      => [".bashrc"],
        meta_attune => "emu",
    }

    @user::plain_user { "puffin":
        uid     => "508",
        attune  => [".bashrc", ".vimrc", ".vim"],
        ensure => absent,
    }
}

class user::horde_air {
    search User::Virtual

    $air_ssh_usr = hiera_array('air_ssh_users', undef)
    if $air_ssh_usr {
        realize(Ssh_user[$air_ssh_usr])
    }
    $air_plain_usr = hiera_array('air_plain_users', undef)
    if $air_plain_usr {
        realize(Plain_user[$air_plain_usr])
    }
}

class user::horde_earth {
    search User::Virtual

    $earth_ssh_usr = hiera_array('earth_ssh_users', undef)
    if $earth_ssh_usr {
        realize(Ssh_user[$earth_ssh_usr])
    }
    $earth_plain_usr = hiera_array('earth_plain_users', undef)
    if $earth_plain_usr {
        realize(Plain_user[$earth_plain_usr])
    }
}

# Declare class
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base" }
Class["install_repos"] -> Class["basic_package"] -> Class["user::root"]

class { "user::virtual": }
class { "user::horde_air": }
class { "user::horde_earth": }

file { "/tmp/simple.txt":
    ensure => present,
    content => "Test me ...\n",
}

