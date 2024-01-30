package { 'mysql':
    ensure => installed,
    provider => 'gem',
}

package { 'rpm mysql':
    ensure => installed,
    name => 'mysql',
}