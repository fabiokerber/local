# -*- mode: ruby -*-
# vi: set ft=ruby :

machines = {
  "servidor" => {"memory" => "4096", "cpu" => "4", "ip" => "10", "image" => "centos/8"}
}

Vagrant.configure("2") do |config|

  config.vm.box_check_update = false
  config.vm.boot_timeout = 600
  machines.each do |name, conf|
    config.vm.define "#{name}" do |machine|
      machine.vm.box = "#{conf["image"]}"
      machine.vm.hostname = "#{name}"
      machine.vm.network "private_network", ip: "192.168.99.#{conf["ip"]}"
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
    servidor.vm.network "forwarded_port", guest: 137, host: 137
    servidor.vm.network "forwarded_port", guest: 138, host: 138
    servidor.vm.network "forwarded_port", guest: 139, host: 139
    servidor.vm.network "forwarded_port", guest: 445, host: 445

  servidor.vm.provision "shell", inline: <<-SHELL
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
