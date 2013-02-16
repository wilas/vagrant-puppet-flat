stage { "first": before => Stage["main"] }
stage { "last": require => Stage["main"] }

class install_repos {

    file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6":
        ensure => file,
        owner  => "root",
        group  => "root",
        mode   => "0444",
        source => "/vagrant/files/RPM-GPG-KEY-EPEL-6",
    }

    yumrepo { 
        "epel":
            enabled    => 1,
            descr      => 'Extra Packages for Enterprise Linux 6 - $basearch',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
            tag        => 'epel';
        "epel-debuginfo":
            enabled    => 0,
            descr      => 'Extra Packages for Enterprise Linux 6 - $basearch - Debug',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch',
            tag        => 'epel';
        "epel-source":
            enabled    => 0,
            descr      => 'Extra Packages for Enterprise Linux 6 - $basearch - Source',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch',
            tag        => 'epel';
        "epel-testing":
            enabled    => 0,
            descr      => 'Extra Packages for Enterprise Linux 6 - Testing - $basearch',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=testing-epel6&arch=$basearch',
            tag        => 'epel';
        "epel-testing-debuginfo":
            enabled    => 0,
            descr      => 'Extra Packages for Enterprise Linux 6 - Testing - $basearch - Debug',
            mirrorlist => 'https://mirrors.fedoraproject.org/metalink?repo=testing-debug-epel6&arch=$basearch',
            tag        => 'epel';
        "epel-testing-source":
            enabled    => 0,
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

    yumrepo { 
        "puppetlabs-products":
            enabled  => 1,
            descr    => 'Puppet Labs Products EL 6 - $basearch',
            baseurl  => 'http://yum.puppetlabs.com/el/6/products/$basearch',
            gpgcheck => 0; 
        "puppetlabs-deps":
            enabled  => 1,
            descr    => 'Puppet Labs Dependencies EL 6 - $basearch',
            baseurl  => 'http://yum.puppetlabs.com/el/6/dependencies/$basearch',
            gpgcheck => 0;  
        "puppetlabs-devel":
            enabled  => 0,
            descr    => 'Puppet Labs Devel EL 6 - $basearch',
            baseurl  => 'http://yum.puppetlabs.com/el/6/dependencies/$basearch',
            gpgcheck => 0;
    }
}

class basic_package {

    package { [ "wget",
                "mc",
                "vim-common",
                "git",
                "rubygems"
        ]:
        ensure => installed,
    }

    # help create box package
    package { [ "make",
                 "gcc",
                 "kernel-devel",
                 "curl",
                 "bzip2"
        ]:
        ensure => installed,
    }

    # https://github.com/rodjek/puppet-lint
    # puppet-lint <path to file>
    # or you can add: require 'puppet-lint/tasks/puppet-lint' to your Rakefile
    # and then run: rake lint
    package { "puppet-lint":
        ensure   => installed,
        provider => "gem",
        require  => Package["rubygems"],
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

    root_attune { [ "/root/.vimrc", "/root/.bashrc", "/root/.vim" ]: }
}


# Class manage virtual users (plain_user and ssh_user)
class user::virtual {

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
            # password => '',
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
            exec { "/vagrant/files/tools/setpassword.sh $name":
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

    @ssh_user { "elk": 
        uid    => "505",
        key    => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzklfofBRMF0doSKawOD0NQaq2z5VJUnsE3KNvEOln+l2BwHM2k2IdEXIfgR+BGUy+wz2wbDSiHVSEoqxX9tfnZSYxdI3IH8goNkkjdKy16r/cm/QEn5sSXgu0RowegTIKplFYU1CWNPlCViGXoUVatwEC2Byo9tz7/kMebQetAoeEMkRH0t/3pkgWqNHy8PDYUASp8PUnKUFcWhUyEokzfPxFllDBjdcMKpx6Iwk/iX/3LNmkXZvSQ6fbNj4a4oCKyx8BJBosUX/bopa0rhCZ6NGP0FHZsLZ9STO8fM5O921kMn7cDxe1MQwDTzvTl9ZJIfCzgZoySqHQ82JzR4nSQ==",
        attune => [".bashrc", ".vimrc", ".vim"],
    }

    @ssh_user { "yak": 
        uid    => "506",
        key    => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzklfofBRMF0doSKawOD0NQaq2z5VJUnsE3KNvEOln+l2BwHM2k2IdEXIfgR+BGUy+wz2wbDSiHVSEoqxX9tfnZSYxdI3IH8goNkkjdKy16r/cm/QEn5sSXgu0RowegTIKplFYU1CWNPlCViGXoUVatwEC2Byo9tz7/kMebQetAoeEMkRH0t/3pkgWqNHy8PDYUASp8PUnKUFcWhUyEokzfPxFllDBjdcMKpx6Iwk/iX/3LNmkXZvSQ6fbNj4a4oCKyx8BJBosUX/bopa0rhCZ6NGP0FHZsLZ9STO8fM5O921kMn7cDxe1MQwDTzvTl9ZJIfCzgZoySqHQ82JzR4nSQ==",
        ensure => absent,
    }

    @ssh_user { "emu":
        uid         => "507",
        key         => "AAAAB3NzaC1yc2EAAAABIwAAAQEA30Z4O2kddLLTuhZPT/WlJ29qZ5stFcGG0srP4Ga/GuRtJdXdQBRMchtoK4Jm7HWRSJhaX65QZQDitByko9Hcetq5tdL/VV+gXe2yBhN1wsTCPpefx2fOPkJdv+izCoAdEmSYUlRo9KuuJwsZxPk1eTkf89o0zkukVDwvGN0M16IeJx9x2y/V+JUSAGCMzEG8Vjjw2VQqKrhg12nLnub4vOzaZxi+QAQJEzcI/TyrB/Jtyl3nZ+gFXlJWoWhmwgSK691CqqR1FZ+QyxMIHxS47Q5/vjO7k8Z34K1L95piwtFGRKU6f64dDidzfbAvqdUQCdC6QMZ4A+eqet98XxmXjQ==",
        attune      => [".bashrc"],
        meta_attune => "emu",
    }

    @plain_user { "puffin":
        uid     => "508",
        attune  => [".bashrc", ".vimrc", ".vim"],
        ensure => absent,
    }
}

class user::horde_air {
    search User::Virtual

    realize( Ssh_user["emu"],
             Plain_user["puffin"] )

}

class user::horde_earth {
    search User::Virtual

    realize( Ssh_user["emu"], 
             Ssh_user["elk"],
             Ssh_user["yak"])
}

# Declare class
class { "install_repos": stage  => "first" }
class { "basic_package": }
class { "user::root": stage => "last"}

class { "user::virtual": }
class { "user::horde_air": }
class { "user::horde_earth": }

file { "/tmp/simple.txt":
    ensure => present,
    content => "Test me ...\n",
}

