class sysadmins {

    group { 'sysadmins':
        ensure => present,
    }

    user { 'bob':
        ensure => present,
        uid => '9999',
        groups => 'sysadmins',
    }

    user { 'susan':
        ensure => present,
        uid => '9998',
        groups => 'sysadmins',
    }

    user { 'peter':
        ensure => present,
        uid => '9997',
        groups => 'sysadmins',
    }

}