# -*- mode: ruby -*-
# vi: set ft=ruby :

machines = {
  "servidor" => {"memory" => "4096", "cpu" => "4", "ip" => "200", "image" => "centos/8"}
}

Vagrant.configure("2") do |config|

  config.vm.box_check_update = false
  config.vm.boot_timeout = 600
  machines.each do |name, conf|
    config.vm.define "#{name}" do |machine|
      machine.vm.box = "#{conf["image"]}"
      machine.vm.hostname = "#{name}"
      #machine.vm.network "public_network", bridge: "enp1s0", ip: "192.168.0.#{conf["ip"]}", gateway: "192.168.0.1" 
      machine.vm.network "public_network", bridge: "enp1s0", auto_config: false 
      machine.vm.provider "virtualbox" do |vb|
        vb.name = "#{name}"
        vb.memory = conf["memory"]
        vb.cpus = conf["cpu"]
        vb.customize ["modifyvm", :id, "--groups", "/Samba"]
	vb.customize ["storageattach", :id,
                "--storagectl", "IDE",
                "--port", "0", "--device", "1",
                "--type", "dvddrive",
                "--medium", "/usr/share/virtualbox/VBoxGuestAdditions.iso"]
      end
    end
  end

#SAMBA
  config.vm.define "servidor" do |servidor|
  
  servidor.vm.provision "shell", inline: <<-SHELL
    nmcli con mod "Wired connection 1" connection.id eth1			      #Network_Configuration
    nmcli con mod eth1 ipv4.addresses "192.168.0.200/24"			      #Network_Configuration
    nmcli con mod eth1 ipv4.gateway "192.168.0.1"				      #Network_Configuration
    nmcli con mod eth1 ipv4.dns "1.1.1.1" +ipv4.dns "1.0.0.1"			      #Network_Configuration
    nmcli con mod eth1 ipv4.method manual					      #Network_Configuration
    nmcli con mod eth1 connection.autoconnect yes				      #Network_Configuration
    nmcli con mod eth1 ipv6.method ignore					      #Network_Configuration
    nmcli con mod eth1 ipv6.never-default yes					      #Network_Configuration   
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf		      #Network_Configuration
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf		      #Network_Configuration
    sysctl -p									      #Network_Configuration
    timedatectl set-timezone America/Sao_Paulo					      #Operating_System
    yum install epel-release -y							      #Operating_System
    sed -i s/^enabled=0/enabled=1/ /etc/yum.repos.d/CentOS-PowerTools.repo	      #Operating_System
    yum update -y								      #Operating_System
    yum install elfutils-libelf-devel kernel-devel kernel-headers gcc make perl -y    #VBox_Guest_Additions
    yum install python3-devel python3 libselinux-python3 -y			      #Ansible
    yum groupinstall 'development tools' -y					      #Ansible
    yum install htop lsb vim tree gdisk iptraf lshw nload nmap telnet wget -y	      #Tools
    mkdir -p /etc/ansible							      #Ansible
    git clone https://github.com/fabiokerber/roles.git /etc/ansible		      #Ansible
    pip3 install ansible							      #Ansible
    touch /var/log/ansible.log && chown vagrant:root /var/log/ansible.log	      #Ansible
    chown -R vagrant:root /etc/ansible						      #Ansible
    sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config		      #Operating_System
  SHELL

  end
end
