terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true
    endpoints {
        ec2 = "$AWS_ENDPOINT_URL"
        sts = "$AWS_ENDPOINT_URL"
        secretsmanager = "$AWS_ENDPOINT_URL"
    }
}

resource "aws_instance" "web-server" {
    ami = "ami-ff0fea8310f3"
    instance_type = "t3.nano"
    count = 5
    tags = {
        Name = "web-server-${count.index}"
    }
}
