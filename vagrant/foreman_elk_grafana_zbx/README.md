# Kompound V

|Tool|Version|
|-------------|-----------|
|`Zabbix`| latest
|`Ansible`| latest
|`Foreman`| latest
|`Grafana`| latest
|`ELK`| latest

# FOREMAN

**Links Foreman**<br>
https://www.youtube.com/watch?v=PQYCiJlnpHM<br>
https://www.youtube.com/watch?v=jC0c3kv2ofA<br>
https://theforeman.org/manuals/3.3/index.html<br>
https://github.com/ATIX-AG/foreman_acd<br>
https://groups.google.com/g/ansible-project/c/IJL4SXWPgL8<br>
https://pt.slideshare.net/NikhilKathole/ansible-integration-in-foreman<br>
https://docs.w3cub.com/ansible/collections/theforeman/foreman/index<br>
https://theforeman.org/plugins/foreman_ansible/3.x/index.html#2.Installation<br>
https://www.linuxtechi.com/install-configure-foreman-1-16-debian-9-ubuntu-16-04/<br>
https://www.itzgeek.com/how-tos/linux/centos-how-tos/install-foreman-on-centos-7-rhel-7-ubuntu-14-04-3.html<br>
https://docs.theforeman.org/nightly/Managing_Hosts/index-foreman-el.html#Synchronizing_Templates_Repositories_managing-hosts<br>
https://apidocs.theforeman.org/foreman/3.3/apidoc/v2.html<br>
https://projects.theforeman.org/projects/foreman/wiki/List_of_Plugins<br>
https://www.theforeman.org/manuals/3.3/index.html#5.1.9UsingOAuth<br>
https://www.theforeman.org/manuals/3.3/index.html#3.2.2InstallerOptions<br>
https://app.swaggerhub.com/apis/foremanmining/foreman-api/2.0.0<br>

**Links Ansible**<br>
https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html<br>
https://theforeman.github.io/foreman-ansible-modules/v0.3.0/modules/foreman_job_template_module.html<br>
https://docs.ansible.com/ansible/5/collections/theforeman/foreman/job_template_module.html<br>
https://galaxy.ansible.com/theforeman/foreman?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW<br>
https://theforeman.github.io/foreman-ansible-modules/v2.1.2/README.html#common-role-variables<br>

**Link Curl**<br>
https://reqbin.com/curl

**Vagrant Plugins**<br>
```
$ vagrant plugin install {vagrant-vboxmanage,vagrant-vbguest,vagrant-disksize,vagrant-env,vagrant-reload}
```

**Log Foreman**
```
> /var/log/foreman/production.log
```

**Install/Configure**
```
# foreman-installer --enable-foreman-plugin-{remote-execution,ansible} --enable-foreman-proxy-plugin-{ansible,remote-execution-ssh}
# foreman-installer --enable-foreman-plugin-{remote-execution,ansible} --enable-foreman-proxy-plugin-{ansible,remote-execution-ssh} --foreman-proxy-plugin-remote-execution-ssh-install-key=true (não recomendado em Prod)

(Atenção)
> /etc/ansible/ansible.cfg
> /etc/foreman-proxy/ansible.cfg
> /usr/share/foreman-proxy/.ansible.cfg
> /etc/foreman/settings.yaml (OAuth)
```

**Settings (FE)**
```
Settings > General > New host details UI
"Foreman will load the new UI for host details"
> No

Settings > Authentication > Trusted hosts
"List of hostnames, IPv4, IPv6 addresses or subnets to be trusted in addition to Smart Proxies for access to fact/report importers and ENC output"
e.g.: mgm-puppetmaster01.manager, mgm-puppetmaster02.manager, mgm-puppetmaster03.manager

Settings > Facts > Create new host when facts are uploaded
"Foreman will create the host when new facts are received"
> Yes

Settings > Config Management > Create new host when report is uploaded
"Foreman will create the host when a report is received"
> Yes

Settings > Remote Execution > SSH User
"Default user to use for SSH. You may override per host by setting a parameter called remote_execution_ssh_user."
(e.g.: host parameters)
> ansible

Settings > Remote Execution > Default SSH password
"Default password to use for SSH. You may override per host by setting a parameter called remote_execution_ssh_password." 
(e.g.: host parameters)
> <ansible_user_password>

Settings > Remote Execution > Default SSH key passphrase
"Default key passphrase to use for SSH. You may override per host by setting a parameter called remote_execution_ssh_key_passphrase."
(e.g.: host parameters)
> <key.pub_password>

Settings > Remote Execution > Connect by IP
"Should the ip addresses on host interfaces be preferred over the fqdn? It is useful when DNS not resolving the fqdns properly. You may override this per host by setting a parameter called remote_execution_connect_by_ip. For dual-stacked hosts you should consider the remote_execution_connect_by_ip_prefer_ipv6 setting"
```

**Remote Execution SSH Another User (FE)**
```
Edit host parameters:
remote_execution_ssh_user | string | ansible
remote_execution_ssh_password | string | <ansible_user_password> (Somente quando solicita senha do usuario ansible para casos que não enviou a key ao destino)

"The granularity is per host/host group/subnet/domain/os/organization/location"
https://community.theforeman.org/t/remote-execution-ssh-user/6091
```

**Create Ansible User (foreman, srv01, srv02)**
```
$ sudo useradd -r -m ansible
$ tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1 (ansible password)
$ sudo passwd ansible

$ sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
$ sudo bash -c 'echo "AllowUsers root" >> /etc/ssh/sshd_config'
$ sudo bash -c 'echo "AllowUsers ansible" >> /etc/ssh/sshd_config'
$ sudo bash -c 'echo "AllowUsers fabio" >> /etc/ssh/sshd_config'
$ sudo bash -c 'echo "AllowUsers vagrant" >> /etc/ssh/sshd_config'
$ sudo systemctl restart sshd

$ sudo update-alternatives --config editor (Debian/Ubuntu Server only)
$ sudo bash -c 'visudo'
  ansible ALL=(ALL) NOPASSWD:ALL
```

**Send key.pub to target hosts**
```
# sudo -u foreman-proxy -s /bin/bash

Generate keygen
$ ssh-keygen -t rsa
$ ssh-copy-id -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub ansible@foreman.aut.lab
$ ssh-copy-id -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub ansible@srv01.aut.lab
$ ssh-copy-id -i ~foreman-proxy/.ssh/id_rsa_foreman_proxy.pub ansible@srv02.aut.lab
```

**First inventory (user foreman-proxy)**
```
$ vim ~/inventory
srv01 ansible_host=192.168.0.190
srv02 ansible_host=192.168.0.191

$ vim ~/hosts_setup.yml
---

- hosts: all
  tasks:
    - setup:

...

$ ansible-playbook ~/hosts_setup.yml -u ansible --private-key ~/.ssh/id_rsa_foreman_proxy -i ~/inventory
$ ansible-playbook ~/hosts_setup.yml -u ansible -k -i ~/inventory (Solicita senha do usuario ansible para casos que não enviou a key ao destino)
```

**Create group**
```
Configure > Host Groups > Create Host Group > Linux
```

**Job Templates (install_package)**<br>
https://www.youtube.com/watch?v=jC0c3kv2ofA<br>
```
foreman server:
$ git clone https://github.com/fabiokerber/Vagrant.git /tmp/Ansible
$ sudo cp -r /tmp/Ansible/foreman_elk_grafana_zbx/roles/* /etc/ansible/roles/

local machine:
$ curl --insecure -X POST https://192.168.0.180/api/job_templates -H 'Content-Type: application/json' --user admin:5fFMGVEmKe5wpFtB -d @/home/fabio/git-pessoal/Vagrant/foreman_elk_grafana_zbx/job_templates/install_package.json

foreman FE:
Hosts > Templates > Job Templates

  Inputs
    Name: package
    Required: Yes
    Input Type: User input
    Value Type: Plain
    Description: Name of the package to be installed
```

```
Hosts > Templates > Job Templates > "Run"
Ubuntu package - inotify-tools / sl
CentOS package - wget
```

**API**
```
https://192.168.0.180/apidoc
https://192.168.0.180/api/
https://192.168.0.180/api/hosts
https://192.168.0.180/api/job_templates
```
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/090720221423.png">
</kbd>
<br />
<br />
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/090720221424.png">
</kbd>
<br />
<br />
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/090720221425.png">
</kbd>
<br />
<br />
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/150720221641.png">
</kbd>
<br />
<br />
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/150720221642.png">
</kbd>
<br />
<br />
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/150720221643.png">
</kbd>
<br />
<br />
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/150720221644.png">
</kbd>
<br />
<br />
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/foreman_elk_grafana_zbx/img/180720221039.png">
</kbd>
<br />
<br />

```
List Hosts
$ curl --insecure -X GET https://192.168.0.180/api/hosts -H 'Content-Type: application/json' --user admin:ssiFUPrgjctKS8V3

Create Group
$ curl --insecure -X POST https://192.168.0.180/api/v2/hostgroups -H 'Content-Type: application/json' --user admin:aDWc6hefRW6nm9yB -d '{"name":"Linux","description":"Linux Servers"}'

Import Job Template (json)
$ curl --insecure -X POST https://192.168.0.180/api/v2/job_templates -H 'Content-Type: application/json' --user admin:aDWc6hefRW6nm9yB -d @/home/fabio/git-pessoal/Vagrant/foreman_elk_grafana_zbx/job_templates/install_package.json

Invoke Job Template (171 - Remove Files)
$ curl --insecure -X POST https://192.168.0.180/api/v2/job_invocations -H 'Content-Type: application/json' --user admin:aDWc6hefRW6nm9yB -d '{"job_invocation":{"job_template_id":"171","targeting_type":"static_query","search_query":"name = srv01.aut.lab"}}'

Invoke Job Template (169 - Install Package - sl)
$ curl --insecure -X POST https://192.168.0.180/api/v2/job_invocations -H 'Content-Type: application/json' --user admin:aDWc6hefRW6nm9yB -d '{"job_invocation":{"job_template_id":"169","targeting_type":"static_query","search_query":"name = srv01.aut.lab","inputs":{"package":"sl"}}}'
```

**Hammer (user foreman-proxy)**
```
# sudo -u foreman-proxy -s /bin/bash

Foreman user list:
$ hammer user list

Foreman list architecture
$ hammer architecture list
```

**Foreman Services Status**
```
# foreman-maintain service status -b
 - Verificar comando
```

**Cockpit**
```
https://docs.theforeman.org/nightly/Managing_Hosts/index-foreman-el.html
https://cockpit-project.org/running.html
```

**Foreman Console**
```
$ sudo bash -c 'foreman-rake console'
  Host.find_by_name("srv01.aut.lab").destroy
```

**environment-class-cache**
```
$ sudo cat /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf | grep environment-class-cache

https://www.puppeteers.net/blog/foreman-and-the-puppetserver-environment-cache/
```

|**Port**|**Protocol**|**Required For**|
|-------------|-----------|-----------|
|`53`| TCP & UDP | DNS Server |
|`67, 68`| UDP | DHCP Server |
|`69`| UDP | TFTP Server |
|`80, 443`| TCP | * HTTP & HTTPS access to Foreman web UI / provisioning templates - using Apache |
|`3000`| TCP | HTTP access to Foreman web UI / provisioning templates - using standalone WEBrick service |
|`5910 - 5930`| TCP | Server VNC Consoles |
|`5432`| TCP | Separate PostgreSQL database |
|`8140`| TCP | * Puppet server |
|`8443`| TCP | Smart Proxy, open only to Foreman |

*Ports indicated with * are running by default on a Foreman all-in-one installation and should be open.*<br>

# GRAFANA & ELK

**Links Grafana**<br>
https://phoenixnap.com/kb/elk-stack-docker<br>
https://medium.com/analytics-vidhya/installing-elk-stack-in-docker-828df335e421<br>

```
> Vagrantfile
  grafana_elk.vm.provision 'shell', inline: 'dockerd --max-concurrent-downloads 2 &>/dev/null' ("Weak Network")

> .env
  LOG_IP=
  ZBX_TAG=
  ELK_TAG=

> vagrant up grafana_elk

> http://LOG_IP:3000
  admin
  admin

> http://LOG_IP:5601

> http://LOG_IP:9200
```

# ZABBIX
```
> .env
  ZABBIX_IP=
  TAG=

> vagrant up zabbix

> http://ZABBIX_IP:8080
  Admin
  zabbix
```

# BACKUP 

**ELK - Mapping**<br>
Esquema de como os dados devem ser armazenados.<br>
Que tipo de dado é, como indexar e como analisar.<br>

**ELK - Analyzer**<br>
Keyword type mapping - Localiza somente as palavras que possuem a exatamente a correspondência conforme o que foi buscado.<br>
Text type mapping - Localiza palavras (mesmo que com baixa relevância), que possuem partes do que foi buscado.<br> 

**ELK - Commands**
```
_Indexando Obra de Shakespeare
$ cd /tmp
$ wget http://media.sundog-soft.com/es7/shakes-mapping.json
$ wget http://media.sundog-soft.com/es7/shakespeare_7.0.json
$ curl -H "Content-Type: application/json" -XPUT 192.168.0.185:9200/shakespeare --data-binary @shakes-mapping.json
$ curl -H "Content-Type: application/json" -XPOST 192.168.0.185:9200/shakespeare/_bulk?pretty --data-binary @shakespeare_7.0.json
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/shakespeare/_search?pretty -d '{"query" : {"match_phrase": {"text_entry" : "to be or not to be"}}}'

_Cria índice
$ curl -H "Content-Type: application/json" -XPUT 192.168.0.185:9200/movies -d '{ "mappings": { "properties": {"year": {"type": "date"} } } }'

_Checa índice criado
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_mapping

_Cria um documento com identificador único.
_Se não atribuir o identificador único, o ELK o faz.
$ curl -H "Content-Type: application/json" -XPOST 192.168.0.185:9200/movies/_doc/109487 -d '{ "genre": ["IMAX","Sci-Fi"], "title": "Interstelar", "year": 2014 }'

_Checa registro no índice movies
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_search?pretty

_Envia lotes de documentos
$ curl -H "Content-Type: application/json" -XPUT 192.168.0.185:9200/_bulk -d '{ "create": { "_index": "movies", "_id": "1111" } } { "id": "1111", "title": "Star Trek Beyond", "year": 2016, "genre": ["Action", "Adventure", "Sci-Fi"] } { "create": { "_index": "movies", "_id": "2222" } } { "id": "2222", "title": "Star Wars: Episode VII - The Force Awakens", "year": 2015, "genre": ["Action", "Adventure", "Sci-Fi", "Fantasy", "IMAX"] }'

_Outra forma de enviar os movies
$ cd /tmp
$ wget http://media.sundog-soft.com/es7/movies.json
$ curl -H "Content-Type: application/json" -XPUT 192.168.0.185:9200/_bulk?pretty --data-binary @movies.json
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_search?pretty

_Atualiza um documento no ELK (atualiza a versão do doc, ou seja, cria um novo documento com a nova versão)
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_search?pretty (busca _id Interstellar)
$ curl -H "Content-Type: application/json" -XPUT 192.168.0.185:9200/movies/_doc/109487?pretty -d '{"genres": ["IMAX","Sci-Fi"], "title": "Interstellar 2", "year": 2014}'
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_doc/109487?pretty

_Update de documento
$ curl -H "Content-Type: application/json" -XPOST 192.168.0.185:9200/movies/_doc/109487/_update -d '{"doc": { "title": "Interestellar 3 "}}'

_Exclusão de documentos
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_doc/109487?pretty
$ curl -H "Content-Type: application/json" -XDELETE 192.168.0.185:9200/movies/_doc/109487?pretty
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_doc/109487?pretty

_Consulta por palavra chave (max_score o título Star Trek)
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_search?pretty -d '{"query": {"match": {"title": "Star Trek"}}}'

_Consulta por frase (trará resultado caso seja exatamente o que foi pesquisado)
$ curl -H "Content-Type: application/json" -XGET 192.168.0.185:9200/movies/_search?pretty -d '{"query": {"match_phrase": {"title": "Star Trek"}}}'

_Deleta índice movies
$ curl -H "Content-Type: application/json" -XDELETE 192.168.0.185:9200/movies

_Recria a estrutura antes de importar os movies
(genre type keyword só trará resultado caso seja exatamente o que foi pesquisado)
$ curl -H "Content-Type: application/json" -XPUT 192.168.0.185:9200/movies -d '{"mappings": {"properties": {"id": {"type": "integer"}, "year": {"type": "date"}, "genre": {"type": "keyword"}, "title": {"type": "text", "analyzer": "english"}}}}}'
$ curl -H "Content-Type: application/json" -XPUT 192.168.0.185:9200/_bulk?pretty --data-binary @movies.json
```

**FOREMAN - Sapo**

- Local Server Debian 11 (vagrant)
```
$ sudo apt update
$ sudo apt install -y libc6-dev vim git curl rsync ca-certificates
$ sudo apt install -y build-essential checkinstall
$ sudo apt install -y libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev
$ wget -O /tmp/SAPO_Python-3.9.13.tgz  https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tgz
$ sudo tar xzf /tmp/SAPO_Python-3.9.13.tgz -C /usr/local/src/
$ cd /usr/local/src/Python-3.9.13/ && ./configure --enable-optimizations && sudo make altinstall
$ pip3.9 install --upgrade pip && pip3.9 install --upgrade setuptools
$ pip3.9 install setuptools_rust wheel && pip3.9 install ansible
$ pip3.9 install psutil
$ pip3.9 install ansible-tower-cli
$ mkdir /tmp/pip
$ pip3.9 freeze > /tmp/pip/requirements.txt
$ pip3.9 download -r /tmp/pip/requirements.txt -d /tmp/pip/
$ tar -czvf /tmp/SAPO_pip.tar.gz -C /tmp/pip/ .
$ wget -O /tmp/SAPO_puppet7-release-bullseye https://apt.puppet.com/puppet7-release-bullseye.deb
$ wget -O /tmp/SAPO_foreman.asc https://deb.theforeman.org/foreman.asc
$ rsync -avzpogt -P /tmp/SAPO_* fabio@10.135.7.228:/tmp
```

- Foreman Server Debian 11 (10.135.7.228)
```
# apt update
# apt install -y libc6-dev vim git curl ca-certificates
# apt install -y build-essential checkinstall
# apt install -y libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev
# tar xzf /tmp/SAPO_Python-3.9.13.tgz -C /usr/local/src/
# cd /usr/local/src/Python-3.9.13/ && ./configure --enable-optimizations && make altinstall
# mkdir /usr/local/src/pip3.9
# tar xzf /tmp/SAPO_pip.tar.gz -C /usr/local/src/pip3.9
# pip3.9 install -r /usr/local/src/pip3.9/requirements.txt --no-index --find-links /usr/local/src/pip3.9
# mkdir -p /etc/ansible/roles
# touch {/var/log/ansible.log,/etc/ansible/hosts}
# chmod 777 /var/log/ansible.log
# vi /etc/ansible/ansible.cfg (GitLab)
# sed -i '/url/d' /etc/ansible/ansible.cfg && sed -i "53 i url = 'https://`hostname -f`'" /etc/ansible/ansible.cfg
# mv /tmp/SAPO_puppet7-release-bullseye /tmp/puppet7-release-bullseye.deb
# apt install -y /tmp/puppet7-release-bullseye.deb
# mv /tmp/SAPO_foreman.asc /etc/apt/trusted.gpg.d/foreman.asc
# echo "deb http://deb.theforeman.org/ bullseye 3.2" | sudo tee /etc/apt/sources.list.d/foreman.list
# echo "deb http://deb.theforeman.org/ plugins 3.2" | sudo tee -a /etc/apt/sources.list.d/foreman.list
# apt update
# apt install -y foreman-installer (Y)
# foreman-installer --enable-foreman-plugin-{remote-execution,ansible,templates} --enable-foreman-proxy-plugin-{remote-execution-ssh,ansible}
# chown foreman-proxy.root /usr/share/foreman-proxy/
# sed -i "2 i deprecation_warnings = False" /etc/foreman-proxy/ansible.cfg
# apt autoremove -y
```