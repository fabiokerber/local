## Links
https://docs.localstack.cloud/user-guide/integrations/kubernetes/<br>
https://docs.localstack.cloud/getting-started/installation/#helm<br>
https://docs.localstack.cloud/tutorials/<br>
https://docs.localstack.cloud/tutorials/s3-static-website-terraform<br>
https://artifacthub.io/packages/helm/localstack/localstack<br>
https://github.com/localstack/awscli-local<br>
https://docs.localstack.cloud/user-guide/aws/elastic-compute-cloud/<br>

## Helm Values
https://github.com/localstack/helm-charts/blob/main/charts/localstack/values.yaml<br>

## vagrant ssh ubuntu_kind
```
kubens awslocal
k get pods -o wide
k get nodes -o wide
export AWS_ENDPOINT_URL=http://<node IP>:31566
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
awslocal s3api create-bucket --bucket testwebsite
awslocal s3api list-buckets
awslocal s3 ls
cd /root/tf-ec2/
tflocal init
tflocal plan
tflocal apply -auto-approve
awslocal ec2 describe-instances --region="us-east-1" --filters "Name=instance-type,Values=t3.nano" --query "Reservations[].Instances[].InstanceId"
cd /root/tf-dynamodb/
tflocal init
tflocal plan
tflocal apply -auto-approve
```
