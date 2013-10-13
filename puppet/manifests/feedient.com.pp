class { 'apt': }

# Configurations
$HOME = "/home/vagrant"
$APTGETPACKAGES = ['python-software-properties', 'git-core', 'curl', 'vim', 'nano', 'make', 'phpunit']

###################################################################
# INSTALL APT-GET PACKAGES
###################################################################
package { $APTGETPACKAGES:
    ensure => 'installed'
}

###################################################################
# INSTALL NGINX CONFIGURATION
###################################################################
package { 'nginx':
    ensure => installed
}

file { '/etc/nginx/nginx.conf':
    source  => 'puppet:///modules/nginx/nginx.conf',
    require => Package['nginx']
}

###################################################################
# INSTALL NODEJS
###################################################################
apt::ppa { 'ppa:chris-lea/node.js': }

package { 'nodejs':
    ensure => present
}

# Feedient specific packages
$packages = ['express', 'ejs', 'ntwitter', 'mongodb', 'bcrypt', 'socket.io', 'async']

package { $packages: 
    ensure   => present,
    provider => 'npm',
    require  => Package['nodejs']
}

###################################################################
# INSTALL MONGODB
###################################################################
class { 'mongodb':
    # use the 10gen repo, mongodb  official installation
    enable_10gen => true
}

###################################################################
# INSTALL DOTFILES (@TODO Take the user his/her dotfiles)
###################################################################
exec { "dotfiles-install": 
    creates => '/home/vagrant/.dotfiles',
    path    => '/bin:/usr/bin',
    command => 'su -c "git clone https://github.com/mathiasbynens/dotfiles.git /home/vagrant/.dotfiles && cd /home/vagrant/.dotfiles && ./bootstrap.sh --force" vagrant',
    require => Package['git-core']
}

file { "${HOME}/.vim": 
    ensure => "directory"
}

file { "${HOME}/.vim/swap":
    ensure => "directory"
}

file { "${HOME}/.vim/backup":
    ensure => "directory"
}

file { "${HOME}/.vim/undo":
    ensure => "directory"
}

file { "${HOME}/.vim/cache":
    ensure => "directory"
}