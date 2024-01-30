## Links
https://artifacthub.io/packages/helm/bitnami/postgresql<br>
https://artifacthub.io/packages/helm/awx-operator/awx-operator<br>
https://github.com/ansible/awx-operator/issues/1524<br>
https://github.com/zalando/postgres-operator<br>
https://www.itwonderlab.com/postgres-kubernetes-nfs-volume/<br>
https://github.com/zalando/postgres-operator/blob/master/docs/quickstart.md<br>
https://phoenixnap.com/kb/postgresql-kubernetes<br>
https://portainer.github.io/k8s/charts/portainer/<br>

## Helm Values
https://raw.githubusercontent.com/ansible/awx-operator/devel/.helm/starter/values.yaml<br>
https://raw.githubusercontent.com/bitnami/charts/main/bitnami/postgresql/values.yaml<br>

## AWX Ingress Deploy
```
$ kubens awx
$ watch kubectl get all
$ kubectl -n awx apply -f /vagrant/files/awx-ing.yaml
$ kubectl get secret -n awx awx-admin-password -o jsonpath="{.data.password}" | base64 --decode
```

## Portainer Deploy
```
$ helm repo add portainer https://portainer.github.io/k8s/
$ helm repo update
$ helm upgrade --install --create-namespace -n portainer portainer portainer/portainer --set service.type=ClusterIP --set tls.force=true --set ingress.enabled=true --set ingress.ingressClassName=nginx --set ingress.annotations."nginx\.ingress\.kubernetes\.io/backend-protocol"=HTTPS --set ingress.hosts[0].host=portainer-awx.fks.lab --set ingress.hosts[0].paths[0].path="/" --set persistence.storageClass=standard
$ kubens portainer
$ watch kubectl get all
```

## /etc/hosts
```
cat << EOF >> /etc/hosts
192.168.56.180 web-awx.fks.lab
192.168.56.180 portainer-awx.fks.lab
EOF
```

## AWX Web
http://web-awx.fks.lab<br>
```
admin | (awx-admin-password)
```

## Portainer Web
http://portainer-awx.fks.lab<br>

## Backup
```
$ kubens awx
$ export PGPASSWORD=$(kubectl get secret -n awx awx-postgres-13 -o jsonpath="{.data.postgres-password}" | base64 --decode) && echo $PGPASSWORD
$ export AWXRANDOMPASS=$(openssl rand -hex 16) && echo $AWXRANDOMPASS
$ k get pods -o wide
$ kubectl exec -it pod/awx-postgres-13-0 -- /bin/bash
$ PGPASSWORD=<PGPASSWORD> psql --host localhost -U postgres -d postgres -p 5432
postgres=# create database awx_db;
postgres=# create user awx with encrypted password '<AWXRANDOMPASS>';
postgres=# grant all privileges on database awx_db to awx;
postgres=# exit;
$ helm upgrade --install awx awx-operator/awx-operator --version "$(cat /tmp/awxhelm_version)" --values /vagrant/files/awx-values.yaml --namespace awx --set AWX.postgres.password="$AWXRANDOMPASS"
$ watch kubectl get all
$ kubectl -n awx apply -f /vagrant/files/awx-ing.yaml
```