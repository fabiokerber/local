group { 'sysadmins':
    ensure => present,
}

user { 'bob':
    ensure => present,
    uid => '9999',
    groups => 'sysadmins',
}