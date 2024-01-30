exec { 'install application':
    path => '/usr/local/bin:/usr/bin:/bin',
    command => 'install.sh',
    unless => 'test -d /opt/myapp',
}