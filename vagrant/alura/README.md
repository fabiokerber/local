# 1.Alura

### Vagrant & Puppet & Ansible
<br />

**Início**

*PowerShell - precise (Ubuntu 12.04)*
```
> vagrant version
> vagrant init hashicorp/precise64 
> vagrant up 
> vagrant status
> vagrant halt
> vagrant suspend
> vagrant reload
> vagrant ssh (u vagrant / s vagrant - default)
> vagrant ssh-config
> vagrant destroy
> vagrant validate
> vagrant global-status (exibe todos os ambientes virtualizados)
> vagrant global-status --prune (remove entradas antigas)
> vagrant destroy <id> (conforme comando acima - funciona de qualquer pasta)
> vagrant <comando> <id> (conforme exemplos acima)
> vagrant box list
> vagrant snapshot save win_server snap190120221650
> vagrant snapshot restore win_server snap190120221650
> vagrant snapshot list
> vagrant snapshot delete win_server snap190120221650
```
<br />

**Port Forwarding**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    Vagrant.configure("2") do |config|
        config.vm.box = "ubuntu/bionic64"
    end

> vagrant up
> vagrant ssh
    $ sudo apt update
    $ sudo apt install -y nginx
    $ netstat -lntp
    $ curl http://localhost
    $ exit
> vagrant halt

!!! edit Vagranfile !!!
    config.vm.network "forwarded_port", guest: 80, host:8089

> vagrant up

!!! navegador http://localhost:8089 !!!
```
<br />

**Private Network**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    config.vm.network "private_network", ip: "192.168.50.4"

> vagrant up / vagrant reload
> vagrant ssh
```
<br />

**DHCP**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    config.vm.network "private_network", type: "dhcp"

> vagrant up / vagrant reload
> vagrant ssh
```
<br />


**Public Network (Bridge)**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    config.vm.network "public_network"

> vagrant up / vagrant reload
> vagrant ssh

!!! edit Vagranfile !!!
    config.vm.network "public_network", ip: "192.168.0.50"

> vagrant up / vagrant reload
> vagrant ssh
```
<br />

**Conexão via SSH (Private Key)**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
> vagrant ssh-config
    IdentityFile ...

>  ssh -i D:/git_projects/Vagrant/1.Alura/bionic/.vagrant/machines/default/virtualbox/private_key vagrant@192.168.0.50
```
<br />

**Adicionando SSH Key à VM(Private Key)**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
> ssh-keygen -t rsa
    D:/git_projects/Vagrant/1.Alura/bionic/id_bionic

> vagrant ssh
    $ ls /vagrant
    $ cp /vagrant/id_bionic.pub ~
    $ cat /vagrant/id_bionic.pub >> .ssh/authorized_keys
```
<br />

**Shell Provisioner**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    config.vm.provision "shell", inline: "echo Hello, World >> hello.txt"

> vagrant up / vagrant reload (Necessário forçar com o comando abaixo, pois o provision é somente no ato da criação)
> vagrant provision

> vagrant ssh
    $ cat hello.txt

```
<br />

**Synced Folder & +Shell**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! create folder configs !!!
!!! copy id_bionic.pub to configs !!!

!!! edit Vagranfile !!!
    config.vm.synced_folder "./configs", "/configs" (Mapeia pasta configs dentro de bionic em /configs)
    config.vm.synced_folder ".", "/vagrant", disabled: true (Desabilita o mapeamento do conteúdo da pasta padrão "bionic")

> vagrant destroy -f
> vagrant up

```
<br />

**Provisionando MySQL**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    $script_mysql = <<-SCRIPT
        apt-get update && \
        apt-get install -y mysql-server-5.7 && \
        mysql -e "create user 'phpuser'@'%' identified by 'pass';"
    SCRIPT

    config.vm.provision "shell", inline: $script_mysql

> vagrant destroy -f
> vagrant up
> vagrant ssh
    $ sudo mysql
    mysql> select user from mysql.user
    mysql> ;
    $ cat /etc/mysql/mysql.conf.d/mysqld.cnf >> /configs/mysqld.cnf

!!! /configs/mysqld.cnf !!!
    bind-address		= 0.0.0.0 (Permitir conexão externa a partir de qualquer host)

!!! edit Vagranfile !!!
    config.vm.provision "shell", inline: "cat /configs/mysqld.cnf > /etc/mysql/mysql.conf.d/mysqld.cnf"
    config.vm.provision "shell", inline: "service mysql restart"

> vagrant destroy -f
> vagrant up
```
<br />

**Multi-Machine**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    $script_mysql = <<-SCRIPT
        apt-get update && \
        apt-get install -y mysql-server-5.7 && \
        mysql -e "create user 'phpuser'@'%' identified by 'pass';"
    SCRIPT

    Vagrant.configure("2") do |config|
        config.vm.box = "ubuntu/bionic64"

        config.vm.define "mysqldb" do |mysql|

            mysql.vm.network "public_network", ip: "192.168.0.50"

            mysql.vm.provision "shell", inline: "cat /configs/id_bionic.pub >> .ssh/authorized_keys"
            mysql.vm.provision "shell", inline: $script_mysql
            mysql.vm.provision "shell", inline: "cat /configs/mysqld.cnf > /etc/mysql/mysql.conf.d/mysqld.cnf"
            mysql.vm.provision "shell", inline: "service mysql restart"

            mysql.vm.synced_folder "./configs", "/configs"
            mysql.vm.synced_folder ".", "/vagrant", disabled: true

        end

        config.vm.define "phpweb" do |phpweb|

            phpweb.vm.network "forwarded_port", guest:80, host:8089
            phpweb.vm.network "public_network", ip: "192.168.0.100"

            phpweb.vm.provision "shell", inline: "apt-get update && apt-get install -y puppet"

        end

    end

> vagrant destroy -f
> vagrant up
> vagrant ssh phpweb
> vagrant ssh mysqldb
```
<br />

**Puppet**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! create folder config/manifests !!!
!!! edit config/manifests/phpweb.pp !!!
    exec { 'apt-update':
      command => '/usr/bin/apt-get update' 
    }

    package { ['php7.2' ,'php7.2-mysql'] :
      require => Exec['apt-update'],
      ensure => installed,
    }

    exec { 'run-php7':
      require => Package['php7.2'],
      command => '/usr/bin/php -S 0.0.0.0:8888 -t /vagrant/src &'
    }
```
<br />

**Puppet + Ansible**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
        phpweb.vm.provision "puppet" do |puppet|

            puppet.manifests_path = "./configs/manifests"
            puppet.manifest_file = "phpweb.pp"

!!! create folder src !!!
!!! edit src/index.php !!!

```
<br />

**Instalação Ansible**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    config.vm.define "mysqlserver" do |mysqlserver|
        mysqlserver.vm.network "public_network", ip: "192.168.0.150"
    end

    config.vm.define "ansible" do |ansible|
        ansible.vm.network "public_network", ip: "192.168.0.200"
        ansible.vm.provision "shell",
            inline: "apt-get update && \
                     apt-get install -y software-properties-common && \
                     apt-add-repository --yes --update ppa:ansible/ansible && \
                     apt-get install -y ansible"
    end

> vagrant destroy -f
> vagrant up
> vagrant ssh ansible
    $ ansible-playbook --version

!!! edit Vagranfile !!!
    mysqlserver.vm.provision "shell", inline: "cat /vagrant/configs/id_bionic.pub >> .ssh/authorized_keys"

> vagrant up mysqlserver
> vagrant ssh mysqlserver
    $ cat .ssh/authorized_keys

!!! edit Vagranfile !!!
    ansible.vm.provision "shell", inline: "cp /vagrant/id_bionic /home/vagrant && chmod 600 /home/vagrant/id_bionic && chown vagrant:vagrant /home/vagrant/id_bionic"
> vagrant provision ansible
```
<br />

**Testando Playbook**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! create folder configs/ansible !!!
!!! edit configs/ansible/hosts !!!
    [mysqlserver]
    192.168.1.22

    [mysqlserver:vars]
    ansible_user=vagrant
    ansible_ssh_private_key_file=/home/vagrant/id_bionic
    ansible_python_interpreter=/usr/bin/python3
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'

!!! edit configs/ansible/playbook.yml !!!
  - hosts: all
    handlers:
      - name: restart mysql
        service:
          name: mysql
          state: restarted
        become: yes

    tasks:
      - name: 'Instalar MySQL Server'
        apt:
          update_cache: yes
          cache_valid_time: 3600 #1 hora
          name: ["mysql-server-5.7", "python3-mysqldb"]
          state: latest
        become: yes

      - name: 'Criar usuario no MySQL'
        mysql_user:
          login_user: root
          name: phpuser
          password: pass
          priv: '*.*:ALL'
          host: '%'
          state: present
        become: yes

      - name: 'Copiar arquivo mysqld.cnf'
        copy:
          src: /vagrant/configs/mysqld.cnf
          dest: /etc/mysql/mysql.conf.d/mysqld.cnf
          owner: root
          group: root
          mode: 0644
        become: yes
        notify:
          - restart mysql

> vagrant destroy -f
> vagrant ssh ansible
    $ ansible-playbook -i /vagrant/configs/ansible/hosts /vagrant/configs/ansible/playbook.yml

> vagrant up mysqlserver
> vagrant up ansible
```
<br />

**Integrando com o Vagrant**

*PowerShell - bionic (Ubuntu 18.04.6)*
```
!!! edit Vagranfile !!!
    ansible.vm.provision "shell", inline: "ansible-playbook -i /vagrant/configs/ansible/hosts /vagrant/configs/ansible/playbook.yml"

> vagrant destroy -f
> vagrant up mysqlserver
> vagrant up ansible
> vagrant up phpweb
```
<br />

**Configuração de Hardware**

*Anotação*
```
(Geral)
Vagrant.configure ("2") do |config|
config.vm.box = "ubuntu/bionic64"

config.vm.provider "virtualbox" do |vb|
vb.memory = 512
vb.cpus = 1
end

------------------------------------------------
(Apenas PHPWEB)
config.vm.define "phpweb" do |phpweb|
    phpweb.vm.network "forwarded_port", guest: 8888, host: 8888
    phpweb.vm.network "public_network", ip: "192.168.1.25"

    phpweb.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.cpus = 2
        vb.name = "ubuntu_bionic_php7"
end

```
<br />

|Tools      |Links/Tips|
|-------------|-----------|
|`Vagrant Downloads`| https://www.vagrantup.com/downloads
|`Vagrant Docs`| https://www.vagrantup.com/docs
|`Virtualbox Downloads`| https://www.virtualbox.org/wiki/Downloads
|`Ansible Install`| http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
|`Puppet Lamp`| https://www.digitalocean.com/community/tutorials/getting-started-with-puppet-code-manifests-and-modules
|`PowerShell`| Set-PSReadlineOption -BellStyle None
