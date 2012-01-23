#!/usr/bin/env puppet

### Brubeck installs consist of installing ZeroMQ, Mongrel2 and some Python
### packages. This script currently covers all of this, though it'd be ideal
### to break it apart into more modular components.

### Rewritten in Master-less Puppet code by Rob Terhaar, just cuz.

###
### Settings
###

$home = inline_template("<%= ENV['HOME'] %>")
$quickness_dir = "${home}/.quickness"
$src_dir = "${quickness_dir}/src"
$brubeck_dir = "${src_dir}/brubeck"
$brubeck_git = "https://github.com/j2labs/brubeck.git"

# setup default path for exec resource so we don't have to use full paths
Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

###
### Directory Structures
###

file {"$quickness_dir": 
  ensure  => 'directory',
}

file {"$src_dir": 
  ensure  => 'directory', 
  require => File["$quickness_dir"],
}

###
### System Depenencies
###

case $operatingsystem {
  'Debian','Ubuntu': { 

    $deps = ['python-dev', 'python-pip', 'libevent-dev', 'libev4', 'git-core']

    exec {'apt-get-up':
      command => 'apt-get update'
      before  => Package[$deps]
    }

  }
  'Redhat', 'Centos', 'Solaris', 'FreeBSD', default {
    # other OS's are currently unsupported
    # etc.. etc..
    fail('Todo')
  }
}

package {"$deps":
  ensure  => 'installed',
}

###
### Formula Dependencies
###

#./zeromq.sh
#./mongrel2.sh
# todo!

###
### Brubeck
###

file {"$brubeck_dir":
  ensure  => 'directory',
  require => File["$src_dir"],
}

exec {"brubeck_co":
  command => "git clone $brubeck_git"
  creates => "${brubeck_dir}/.git",
  require => Package["$deps"],
}

### Install Brubeck's dependencies
command {'bru_deps':
  command => "pip install -I -r ${brubeck_dir}/envs/brubeck.reqs",
  require => Exec['brubeck_co'],
  before  => Exec['bru_install'],
}

### Concurrency already handled with gevent + zeromq
command {'gevent_deps':
  command => "pip install -I -r ${brubeck_dir}/envs/gevent.reqs",
  require => [ Exec['brubeck_co'], Exec['bru_deps'] ],
  before  => Exec['bru_install'],
}

### Install Brubeck itself
command {'bru_install':
  command => 'python ./setup.py install',
}


