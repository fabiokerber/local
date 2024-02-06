# Self Healing Project (Auto Remediação) #
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/self_healing.png">
</kbd>
<br />
<br />

## Benefits<br>
Self healing is better than depending on humans for several reasons:<br>
<br>
*. "Automated solutions are less likely to miss issues by mistake, or to make errors when resolving them."*<br>
*. "Self-healing technology is better positioned to fix problems faster than humans because it can react instantly based on rules or machine learning. It doesn’t have to stop and think about the issue before taking action."*<br>
*. "A self-healing environment can scale without limit. This is a key advantage over manually managed environments, whose scalability is limited in some respects by the availability of human admins."*<br>
(https://devops.com/self-healing-service-management-future-devops/)

## Architecture<br>
<kbd>
    <img src="https://github.com/fabiokerber/Vagrant/blob/main/zbx_awx_sh/draw/images/draw.png">
</kbd>
<br />
<br />

## Demo<br>
[![Watch the video](https://github.com/fabiokerber/lab/blob/main/images/youtube_image.jpg)](https://www.youtube.com/watch?v=MFPBuaThhV8)

Pré requisitos:

|Tool|Link\Command|
|-------------|-----------|
|`Vagrant`| https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.msi
|`Install Vagrant Env Plugin`| > vagrant plugin install vagrant-env
|`VirtualBox`| https://download.virtualbox.org/virtualbox/6.1.30/VirtualBox-6.1.30-148432-Win.exe
|`Postman`| https://www.postman.com/downloads/

|Tool|Version|
|-------------|-----------|
|`AWX`| v17.1.0
|`Zabbix`| v5.2.7
|`Docker`| v20.10.12
|`CentOS 7`| v7.8.2003
|`Ubuntu Server`| v20.04.3 LTS
|`Vagrant`| v2.2.19
|`VirtualBox`| v6.1.30

|VM|Requirement|
|-------------|-----------|
|`Zabbix`| 4vCPU 4GB
|`AWX`| 4vCPU 8GB
|`Centos SRV01`| 2vCPU 1GB

# Vagrant #
```
!!! Edit Vagrantfile !!!
    centos_srv01.vm.provision 'shell', inline: 'sudo sed -i "s|Server=127.0.0.1|Server=192.168.0.50|g" /etc/zabbix/zabbix_agentd.conf'

!!! Edit .env !!!
    TAG='5.2' (tag zabbix)
    ZABBIX_IP='192.168.0.50'
    AWX_IP='192.168.0.100'
    CENTOS_SRV01='192.168.0.150'
    INTERFACE_LAN='TP-Link Wireless MU-MIMO USB Adapter'

    Obs: .env = Variáveis para docker-compose.yml e Vagrantfile
         dockerfile/*.dockerfile = Necessário alterar tag zabbix manualmente
```

# AWX #

```
> vagrant up awx_srv
> vagrant ssh awx_srv -c 'cat /tmp/awx-17.1.0/installer/inventory | grep admin_password' (anotar!)
> vagrant ssh awx_srv -c 'sudo tower-cli config | grep password' (anotar!)
> vagrant ssh awx_srv
    $ curl -X POST -k -H "Content-type: application/json" -d '{"description":"Personal Tower CLI token", "application":null, "scope":"write"}' http://admin:<admin_password>@192.168.0.100/api/v2/users/1/personal_tokens/ | python3 -m json.tool (Get Token)
> vagrant ssh awx_srv -c "sudo -- sh -c 'echo 192.168.0.150 centos_srv01 >> /etc/hosts'" (registrado mas ineficaz)

http://AWX_IP
    admin
    "admin_password"
```

. Criar organizacao **(Lab)**<br>
. Criar credencial **Linux Server** u: awx | p: awx_pass **(Lab | Machine | Privilege Escalation Method: sudo | Privilege Escalation Password: awx_pass)**<br>
. Criar credencial **Windows Server** u: vagrant | p: vagrant **(Lab | Machine)**<br>
. Criar inventario **(Servers Linux | Organization: Lab | Instance Groups: tower)**<br>
. Criar host **(hostname 192.168.0.150)**<br>
. Criar projeto Linux **(Update System | Organization: Lab)**<br>
. Criar projeto Linux **(Install NGINX | Organization: Lab)**<br>
. Criar projeto Linux **(Restart Services | Organization: Lab)**<br>
. Criar projeto Windows **(7zip | Organization: Lab)**<br>
. Criar templates Linux **(Credentials: awx | Variables: Prompt on launch | Limit: Prompt on launch | Privilege Escalation: On)**<br>
. Criar templates Windows **(Credentials: vagrant | Variables: Prompt on launch | Limit: Prompt on launch)**<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. Template Install 7zip **(Playbook: install.yml)**<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. Template Remove 7zip **(Playbook: remove.yml)**<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. Variables templates Windows<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;---<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_connection: winrm<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_winrm_kerberos_delegation: true<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_winrm_scheme: http<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_port: 5985<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. Variables templates Windows *SERVER DEFAULT (.ISO)*<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;---<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_connection: winrm<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_winrm_kerberos_delegation: true<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_winrm_scheme: http<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_port: 5985<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ansible_winrm_transport: ntlm<br>


**POSTMAN - GET - Info execução template 9 "Update System".**
```
http://192.168.0.100/api/v2/job_templates/9/
admin
<admin_password>
```
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/150120221604.jpg">
</kbd>
<br />
<br />

**POSTMAN - POST - Acionamento template 9 "Update System".**
```
http://192.168.0.100/api/v2/job_templates/9/launch/
admin
<admin_password>
```
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/150120221612.jpg">
</kbd>
<br />
<br />

**POSTMAN - POST - Acionamento template 11 com Extra Vars "Install NGINX".**
```
http://192.168.0.100/api/v2/job_templates/11/launch/
admin
<admin_password>

{
    "extra_vars": {
        "hostname": "centos_srv01"
    }
}
```
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/150120221639.jpg">
</kbd>
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/150120221641.jpg">
</kbd>
<br />
<br />

**POSTMAN - POST - Acionamento template 11 sem Extra Vars "Install NGINX".**<br>
Obs: Não houve acionamento no AWX.<br>
```
http://192.168.0.100/api/v2/job_templates/11/launch/
admin
<admin_password>
```
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/150120221651.jpg">
</kbd>
<br />
<br />

**Curl - POST - Acionamento templates 9 e 11 (com Extra Vars), via centos-srv01.**<br>
```
https://adam.younglogic.com/2018/08/job-tower-rest/ (fonte)
https://github.com/ansible/ansible/issues/37702 (fonte)

> vagrant ssh centos_srv01
    $ curl -H "Content-Type: application/json" -X POST -s -u admin:madoov4T -k http://192.168.0.100/api/v2/job_templates/9/launch/ | jq '.url'
    $ curl -H "Content-Type: application/json" -X POST -s -u admin:ei4meiZo -d '{ "limit": "192.168.0.150", "extra_vars": { "service": "nginx" }}' -k http://192.168.0.100/api/v2/job_templates/10/launch/ | jq '.url' (limit e extra vars)
```

# ZABBIX #

```
> vagrant up zabbix_srv

http://ZABBIX_IP:8080
    Admin
    zabbix
```

. Configurar TimeZone Administration > General > GUI<br>
. Configurar TimeZone User Settings > Profile<br>
. Zabbix Server > Remover template Zabbix Agent > Unlink and Clear<br>
. Importar zbx_templates<br>
. Criar host group > Servers Nginx<br>
. Criar hosts com o **hostname por IP** e aplicar novos templates aos hosts<br>

**Configurar Action.**
```
curl -H "Content-Type: application/json" -X POST -s -u admin:Aereiz8d -d '{ "limit": "{HOST.HOST}" }' -k http://192.168.0.100/api/v2/job_templates/13/launch/ | jq '.url'

Obs: Atentar senha admin e endereço template.
```
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/160120221929.jpg">
</kbd>
<br />
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/160120221930.jpg">
</kbd>
<br />
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/160120221931.jpg">
</kbd>
<br />
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/160120221932.jpg">
</kbd>
<br />
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/160120221933.jpg">
</kbd>
<br />
<kbd>
    <img src="https://github.com/fabiokerber/lab/blob/main/images/170120221141.jpg">
</kbd>
<br />
<br />


# CENTOS SRV01 #

```
> vagrant up centos_srv01
```

# WIN SERVER #

## VAGRANT ##

```
> vagrant up win_server

Exemplo deploy vagrant:

    win_server: 3389 (guest) => 53389 (host) (adapter 1)
    win_server: 5985 (guest) => 55985 (host) (adapter 1)
    win_server: 5986 (guest) => 55986 (host) (adapter 1)
    win_server: 22 (guest) => 2200 (host) (adapter 1)
################################################################
    win_server: WinRM address: 127.0.0.1:55985
    win_server: WinRM username: vagrant
    win_server: WinRM execution_time_limit: PT2H
    win_server: WinRM transport: negotiate

Configurar Rede

PowerShell Como Administrador

. Fuso Horário
    > tzutil /s "E. South America Standard Time"
    > reg query HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation (verificar TimeZone)
```

## SERVER DEFAULT (.ISO) ##

```
Configurar Rede

PowerShell Como Administrador

---- WinRM (HTTP - Testado AWX para WinServer) ----

. Enable Remote Desktop
    > Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
    > Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

. Fuso Horário
    > tzutil /s "E. South America Standard Time"
    > reg query HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation (verificar TimeZone)

. Ping & WinRM
    > netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol="icmpv4:8,any" dir=in action=allow
    > Set-ItemProperty –Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System –Name LocalAccountTokenFilterPolicy –Value 1 -Type DWord
    > Enable-PSRemoting -Force
    > Set-Item wsman:\localhost\client\trustedhosts * -Force (Verificar trocar * por IP/DNS do AWX)
    > Restart-Service WinRM
    > netsh advfirewall firewall add rule name="WinRM TCP Port 5985" dir=in action=allow protocol=TCP localport=5985

---- WinRM (HTTPS - Testado WinServer para WinServer) ----

    > netsh advfirewall firewall add rule name="WinRM TCP Port 5986" dir=in action=allow protocol=TCP localport=5986

    > New-SelfSignedCertificate -DnsName 192.168.0.200 -CertStoreLocation C:\Users\Administrator
        > Exemplo: 41C96A1AC3F179BDE372CAE68E6D9272D7D5FC03

. CMD Como Administrador
    > winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=”192.168.0.200”; CertificateThumbprint=”41C96A1AC3F179BDE372CAE68E6D9272D7D5FC03”}

. Teste de fora (WinRM HTTPS - Testado WinServer para WinServer)
    > $so = New-PsSessionOption -SkipCACheck -SkipCNCheck; Enter-PSSession -ComputerName 192.168.0.200 -Credential Administrator -UseSSL -SessionOption $so

. Backup
    > Test-NetConnection -ComputerName 192.168.0.200 -Port 5985 (teste de porta)
    > Get-Item WSMan:\localhost\Client\TrustedHosts (listar TrustedHosts)
    > winrm enumerate winrm/config/listener (PowerShell winrm configs)
```

# Backup #


**Zabbix (docker run)**
```
$ docker network create --driver bridge zabbix-network
$ docker run --name mysql-server -t -e MYSQL_DATABASE="zabbixdb" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="H9W&n#Iv" -e MYSQL_ROOT_PASSWORD="UCxV*rR&" --network=zabbix-network -d mysql:8.0 --character-set-server=utf8 --collation-server=utf8_bin --default-authentication-plugin=mysql_native_password
$ docker run --name zabbix-java-gateway -t --network=zabbix-network --restart unless-stopped -d zabbix/zabbix-java-gateway:alpine-5.4-latest
$ docker run --name zabbix-server-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbixdb" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="H9W&n#Iv" -e MYSQL_ROOT_PASSWORD="UCxV*rR&" -e ZBX_JAVAGATEWAY="zabbix-java-gateway" --network=zabbix-network -p 10051:10051 --restart unless-stopped -d zabbix/zabbix-server-mysql:alpine-5.4-latest
$ docker run --name zabbix-web-nginx-mysql -t -e ZBX_SERVER_HOST="zabbix-server-mysql" -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbixdb" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="H9W&n#Iv" -e MYSQL_ROOT_PASSWORD="UCxV*rR&" --network=zabbix-network -p 80:8080 --restart unless-stopped -d zabbix/zabbix-web-nginx-mysql:alpine-5.4-latest
$ docker run --name zabbix-agent -e ZBX_HOSTNAME="Zabbix server" -e ZBX_SERVER_HOST="172.20.240.3" -e ZBX_LISTENPORT=10050 --network=zabbix-network -p 10050:10050 -d zabbix/zabbix-agent:alpine-5.4-latest
```


**Zabbix (docker compose)**
```
$ docker-compose build
$ docker-compose --profile zabbix up -d
$ watch docker ps
```


**AWX Links**<br>
https://geekflare.com/ansible-playbook-windows-example/ (Playbooks Windows)


**AWX cli**
```
> vagrant ssh awx_srv
    $ tower-cli config

!!! Verificar possibilidade de montar essa pasta em um disco adicional !!!
    zabbix_srv.vm.provision 'shell', inline: 'sudo mkdir /zabbixdb'

$ docker stop $(docker ps -q)
$ docker container prune
$ docker exec -it <container name> /bin/bash
$ sudo docker exec -ti --user=root awx_web /bin/bash
> vagrant suspend
> vagrant ssh zabbix_srv -c 'sudo docker ps'
> vagrant ssh zabbix_srv -c 'sudo docker-compose -f /vagrant/docker-compose.yml --profile zabbix up -d'
```


**Docker Hub - Zabbix**<br>
https://hub.docker.com/r/zabbix/zabbix-java-gateway<br>
https://hub.docker.com/r/zabbix/zabbix-server-mysql<br>
https://hub.docker.com/r/zabbix/zabbix-web-nginx-mysql<br>
https://hub.docker.com/r/zabbix/zabbix-agent<br>
https://www.youtube.com/watch?v=ScKlF0ICVYA&t=957s (Zabbix Docker Containers)<br>


**Zabbix**<br>
https://www.zabbix.com/documentation/current/pt/manual/config/notifications/action/operation/macros
https://www.zabbix.com/documentation/current/en/manual/appendix/macros/supported_by_location 


# "PONTOS DE ATENÇÃO" #
. Host somente referênciado via IP.<br>
. Não encontrei forma de enviar 'extra vars' no comando curl da Action no Zabbix.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Talvez utilizar macros no *template > alerta/trigger* e adicionar no comando da action...<br>
. Criar usuário Windows com perfil adm para execução de playbooks AWX (utilizado o próprio vagrant para fins de teste).<br>
. Backup<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. Zabbix<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - Banco gerado em unidade de disco apartada do sistema operacional da VM (Argon)<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - Procedimento quando subir o Zabbix realizar o import da base (Argon)<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - Procedimento de export database (Argon)<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. Awx<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - Backup e restore aplicação e/ou database<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. Contemplar Restore cenário de destruição pods e vms<br>