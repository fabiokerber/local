## Links
https://www.lisenet.com/2022/deploy-elasticsearch-and-kibana-on-kubernetes-with-helm/
https://devopscube.com/create-self-signed-certificates-openssl/
https://artifacthub.io/packages/helm/elastic/elasticsearch?modal=values
https://artifacthub.io/packages/helm/elastic/kibana?modal=values

## Helm Values
```
https://raw.githubusercontent.com/elastic/helm-charts/main/elasticsearch/values.yaml
https://raw.githubusercontent.com/elastic/helm-charts/main/kibana/values.yaml
https://github.com/elastic/helm-charts/releases/tag/v7.17.3
```

## Version 7.16.1 (instalação manual)
```
$ kubectl create ns logging
$ kubectl -n logging apply -f /home/vagrant/ELK/install_helm/files/volumes.yaml
$ docker run -it -v $(pwd):/cert docker.elastic.co/elasticsearch/elasticsearch:7.17.3 ./bin/elasticsearch-certutil ca --out /cert/elastic-stack-ca.p12
$ kubectl -n logging create secret generic elastic-stack-ca --from-file=elastic-stack-ca.p12
$ kubectl -n logging create secret generic elastic-stack-ca-password --from-literal=xpack.security.transport.ssl.keystore.secure_password='952271' --from-literal=xpack.security.transport.ssl.truststore.secure_password='952271'
$ kubectl -n logging create secret generic elasticsearch-master-account --from-literal=username=elastic --from-literal=password='R4bhvp2h37'
$ helm upgrade --install elasticsearch elastic/elasticsearch --version "7.17.3" --values /home/vagrant/ELK/install_helm/files/es-values-v7.yaml --namespace logging
$ kubectl -n logging exec -it elasticsearch-master-0 -- bash
curl -u "elastic:R4bhvp2h37" -X POST "localhost:9200/_security/user/kibana_system/_password?pretty" -H 'Content-Type: application/json' -d"
{
  \"password\" : \"R4bhvp2h37\"
}"
$ kubectl -n logging create secret generic kibana-master-account --from-literal=username=kibana_system --from-literal=password='R4bhvp2h37'
$ helm upgrade --install kibana elastic/kibana --version "7.16.1" --values /home/vagrant/ELK/install_helm/files/kb-values-v7.yaml --namespace logging
```

## Version 8.5.1
```
$ kubectl -n logging get secrets/elasticsearch-master-credentials -o jsonpath='{.data.password}' | base64 -d
```

## Deploy Portainer
```
$ helm repo add portainer https://portainer.github.io/k8s/
$ helm repo update
$ helm upgrade --install --create-namespace -n portainer portainer portainer/portainer --set service.type=ClusterIP --set tls.force=true --set ingress.enabled=true --set ingress.ingressClassName=nginx --set ingress.annotations."nginx\.ingress\.kubernetes\.io/backend-protocol"=HTTPS --set ingress.hosts[0].host=portainer-logs.fks.lab --set ingress.hosts[0].paths[0].path="/"
```

## /etc/hosts
```
cat << EOF >> /etc/hosts
192.168.56.180 kb-logs.fks.lab
192.168.56.180 es-logs.fks.lab
192.168.56.180 portainer-logs.fks.lab
EOF
```

## Navegador > https://kb-logs.fks.lab

## Snapshot Repo
```
PUT _snapshot/fs-snapshots
{
  "type": "fs",
  "settings": {
    "location": "/mnt"
  }
}
```

## Backup
```
# export ELASTIC_USER=elastic
# export ELASTIC_PASS=''

# k exec -ti pod/elasticsearch-master-0 -- bash
  # curl -ku "$ELASTIC_USER:$ELASTIC_PASS" -X GET "https://localhost:9200"
# curl -ku "$ELASTIC_USER:$ELASTIC_PASS" -X GET "https://es-logs.fks.lab:9200"

# elasticsearch@lab-master-0:~$ curl -u "$ELASTIC_USER:$ELASTIC_PASS" -X POST "localhost:9200/_security/user/fabio?pretty" -H 'Content-Type: application/json' -d'
{
  "password" : "952271",
  "roles" : [ "superuser"],
  "full_name" : "fabio",
  "email" : "fabio@lab.pt"
}'
```
```
https://discuss.elastic.co/t/accidentally-deleted-security-index-for-x-pack/69844/2

$ kubectl -n logging exec -it elasticsearch-master-0 -- bash
curl -u "elastic:R4bhvp2h37" -X POST "localhost:9200/_security/user/kibana_system/_password?pretty" -H 'Content-Type: application/json' -d"
{
  \"password\" : \"R4bhvp2h37\"
}"
```