# Set the execution paths
Exec { path => [ "/usr/local/bin/", "/usr/local/sbin/", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ]}

###################################################################
# CONFIGURATIONS
###################################################################
$machine_ip = "192.168.0.1"
$user = "root"
$homedir = "/${user}"
$apt_get_packages = ['python-software-properties', 'git-core', 'curl', 'vim', 'nano', 'make', 'phpunit']

$mysql_user = "root"
$mysql_pass = "root"

group { "puppet":
    ensure => present,
}

group { "admin":
    ensure => present,
}

file { "${homedir}":
    ensure => directory
}

exec { "apt-get update":
        command => "/usr/bin/apt-get update",
}

###################################################################
# INSTALL APT-GET PACKAGES
###################################################################
package { $apt_get_packages:
    ensure  => 'installed',
    require => Exec['apt-get update']
}

###################################################################
# INSTALL NGINX
###################################################################
package { 'nginx':
    ensure => installed,
    require => Exec['apt-get update']
}

# Site configuration happens in /var/www/SITENAME/config/nginx.conf
file { '/etc/nginx/nginx.conf':
    ensure  => file,
    source  => 'puppet:///modules/nginx/nginx.conf',
    owner   => 'www-data',
    group   => 'admin',
    require => Package['nginx']
}

file { '/etc/nginx/mime.types':
    ensure  => file,
    require => Package['nginx'],
    source  => 'puppet:///modules/nginx/mime.types',
}

file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
    require => Package['nginx']
}

# Service
service { 'nginx':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['nginx'],
}

###################################################################
# INSTALL PHP-FPM
###################################################################
$php5packages = ['php5', 'php-apc', 'php5-fpm', 'php5-curl', 'php5-cli', 'php5-intl', 'php5-imagick', 'php5-imap', 'php5-mcrypt', 'php5-memcached', 'php5-ming', 'php5-mysql', 'php5-pspell', 'php5-recode', 'php5-snmp', 'php5-tidy', 'php5-xmlrpc', 'php5-xsl', 'php5-xcache']

package { $php5packages:
    ensure  => 'installed',
    require => Exec['apt-get update']
}

file { '/etc/php5/fpm/pool.d/www.conf':
    source  => 'puppet:///modules/php5-fpm/www.conf',
    require => Package['php5-fpm']
}

file { '/etc/php5/cli/php.ini':
    source  => 'puppet:///modules/php5-fpm/php_cli.ini',
    require => Package['php5-cli'];
}

file { '/etc/php5/fpm/php.ini':
    source  => 'puppet:///modules/php5-fpm/php_fpm.ini',
    require => Package['php5-fpm'],
    notify  => Service['php5-fpm'];
}

# Apc
file { '/etc/php5/conf.d/apc.ini':
    source  => 'puppet:///modules/php5-fpm/apc.ini',
    require => Package['php-apc'],
    notify  => Service['php5-fpm'];
}

# Memcached
file { '/etc/php5/conf.d/memcached.ini':
    source  => 'puppet:///modules/php5-fpm/memcached.ini',
    require => Package['php5-memcached'],
    notify  => Service['php5-fpm']
}

# Service
service { 'php5-fpm':
    enable  => true,
    ensure  => running,
    require => Package['php5-fpm'],
}

###################################################################
# INSTALL COMPOSER
###################################################################
exec { 'composer-install-system-wide':
    command => 'su -c "cd /root && curl -sS https://getcomposer.org/installer | php && sudo mv /root/composer.phar /usr/local/bin/composer" ${user}',
    require => [Package['curl'], Package['php5-fpm']],
    creates => "/usr/local/bin/composer"
}

###################################################################
# INSTALL MYSQL
###################################################################
$mysqlpackages = ['mysql-server', 'mysql-client', 'mysql-common']

package { $mysqlpackages: 
    ensure => 'installed',
    require => Exec['apt-get update']
}

exec { 'set-mysql-root-password':
    subscribe   => [Package['mysql-common'], Package['mysql-client'], Package['mysql-server']],
    refreshonly => true,
    unless      => "mysqladmin -u${mysql_user} -p${mysql_password} status",
    command     => "mysqladmin -u${mysql_user} password ${mysql_password}",
    require     => Package['mysql-server'],
    notify      => Exec['grant-access-outside-vagrant']
}

exec { 'grant-access-outside-vagrant':
    command => "mysql -u${mysql_user} -p${mysql_password} -e \"GRANT ALL ON *.* TO '${mysql_user}'@'${machine_ip}' IDENTIFIED BY '${mysql_password}';\""
}

file { '/etc/mysql/my.cnf':
    source  => 'puppet:///modules/mysql/my.cnf',
    require => Package['mysql-server'],
    notify  => Service['mysql']
}

# Service
service { 'mysql':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['mysql-server']
}

###################################################################
# SYMFONY2 SPECIFIC, @TODO: Fix those that they do not error out
###################################################################
# PERMISSIONS ON FILES
#exec { 'permissions-cache':
#    command     => "find /var/www -type d -name 'cache'|grep 'app/cache'|xargs chmod -R 0777"
#}
#exec { 'owner-cache':
#    command     => "find /var/www -type d -name 'cache'|grep 'app/cache'|xargs chown -R www-data:www-data"
#}
#exec { 'permissions-logs':
#    command     => "find /var/www -type d -name 'logs'|grep 'app/logs'|xargs chmod -R 0777"
#}
#exec { 'owner-logs':
#    command     => "find /var/www -type d -name 'logs'|grep 'app/logs'|xargs chown -R www-data:www-data"
#}

###################################################################
# GRAPHITE && STATSD: TODO! (Provide Graphs with calls, uptime, ..)
###################################################################

###################################################################
# SUPERVISORD: TODO! (Automate restart of an app, example: NODE)
###################################################################

###################################################################
# INSTALL DOTFILES (@TODO Take the user his/her dotfiles)
###################################################################
exec { "dotfiles-install": 
    creates => "/root/.dotfiles",
    path    => '/bin:/usr/bin',
    command => 'su -c "git clone https://github.com/mathiasbynens/dotfiles.git /root/.dotfiles && cd /root/.dotfiles && ./bootstrap.sh --force"',
    require => Package['git-core']
}

file { "/root/.vim": 
    ensure => "directory"
}

file { "/root/.vim/swap":
    ensure => "directory"
}

file { "/root/.vim/backup":
    ensure => "directory"
}

file { "/root/.vim/undo":
    ensure => "directory"
}

file { "/root/.vim/cache":
    ensure => "directory"
}