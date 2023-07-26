# Scalelite Enterprise

Deploy Scalelite Enterprise using open source installers. Scalelite Entrprise is comprised of

- [BigBlueButton](https://github.com/bigbluebutton/bigbluebutton) is an open source purpose-built virtual classroom that empowers teachers to teach and learners to learn.
- [Scalelite](https://github.com/blindsidenetworks/scalelite) is an open source load balancer that manages a pool of BigBlueButton servers. It makes the pool of servers appear as a single (very scalable) BigBlueButton server.
- [GreenLight](https://github.com/bigbluebutton/greenlight) is an open-source, LGPL-3.0 licensed web application that allows organizations to quickly set up a complete web conferencing platform using their existing BigBlueButton server.

A typical redundant deployment will include at least two BigBlueButton, Scalelite, and GreenLight servers where the Scalelite and GreenLight servers are behind application load balancers. __Currently, application load balancers have not been implemented and round-robin DNS is used.__

# Deployment Workstation Setup

On a linux workstation install the following

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) is the AWS Command Line Interface open source tool that enables you to interact with AWS services using commands in your command-line shell.
1. [Terraform](https://developer.hashicorp.com/terraform/downloads) is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share
1. [Python 3.x](https://www.python.org/downloads/) is an interpreted, object-oriented, high-level programming language with dynamic semantics
1. [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) - recommend installing ansible through `python3` rather than an RPM to ensure ansible is using python3.
1. [LEGO](https://github.com/go-acme/lego) is optional and is used generate SSL certificates.
1. [yq](https://github.com/mikefarah/yq) is a lightweight and portable command-line YAML, JSON and XML processor.

# AWS Deployment

```
git clone https://github.com/paulseto/sle.git
cd sle/deployments/aws_ubuntu

# Optional, create a backend.tf from https://developer.hashicorp.com/terraform/language/settings/backends/configuration

terraform init
terraform workspace new dev

# Create a configuration file by copying the sample configuration. The configuration will include the terraform workspace name
cp vars.sample.yml vars.dev.yml

export AUTO=yes
make apply.vpc
make apply.vpc-data
make apply.eip
make apply.efs
make apply.bbb
make apply.bbb
make bbb
make apply.sl
make apply.sl
make sl
make sl.bbb
make sl.tenants # if enable_tenants=yes
make apply.gl
make apply.gl
make gl
```
## Configuration File Settings
| Setting | Description | Default |
| ------- | ----------- | :-----: |
|prefix|Name tag prefix for all provisioned resource.|_required_|
|domain|Domain name for servers. |_required_|
|email|Email used by the install to generate SSL certificates.<br/>When email is blank, _ssl.crt\_file_ and _ssl.key\_file_ are required.|null|
|hostname_pattern|General naming convention of hosts when more than one instance is created. For example,<br/>`> format("%s%02d", "bbb", 3)`<br/>`"bbb03"`<br/>`> format("%s%02d", "bbb", 10)`<br/>`"bbb10"`<br/>__Note__: zero padding is recommended when there are 10 or more instances.|%s%d|
|ami_name_filter| general filter to select the the most recent base image for provisioned servers. Use [aws ec2 describe-images](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-images.html) to identify possible images.| _ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*_ for `aws_ubuntu` deployment|
|ami_id|Use a specific image for deployment by specifying the Amazon Machine Image id. When specified, `ami_name_filter` is ignored.|null|
|iam_role| IAM role to assign to instances. See [AWS Policy](#aws-policies) section below. |null|
|aws.region| AWS Region where servers will be deployed | _required_ |
|aws.profile| AWS region profile used for deployment | default|
|eip.create|Create elastic ip addresses for each server listed in `eip.hostanmes`|false|
|eip.hostnames|array of hostnames to either create when `eip.create` is true or when false use already created elastic ip addresses. When hostnames are not supplied, the public ip address of the instance will be used. |[ ]|
|efs.create| Create an efs. An efs is required when deploying Scalelite or when there is a desire to save BBB recordings onto external storage | false |
|vpc.id| deploy onto an existing VPC | null |
|vpc.cidr| create a new VPC with cidr_block | null |
|vpc.bits| Use addition bits for creation of subnets |8|
|vpc.az| array of letters for availability zones to use | ["a","b"]|
|cache.use_docker|Use docker image instead of AWS Elasticache. When deploying multiple Scalelite servers, docker can not be used|false|
|cache.docker_image|Redis docker image from docker.io|null|
|cache.instance_type|AWS instance type for elasticache|cache.t4g.micro|
|cache.instance_count|number of instances in the cluster|2|
|cache.engine|AWS caching type. Use `redis` only.|redis|
|cache.engine_version|Version of redis|5.0.6|
|cache.parameter_group|parameters for cache|null|
|db.use_docker|Use docker image instead of deploying an AWS database|false|
|db.docker_image| Postgres docker image from docker.io| null|
|db.engine| Postgres engine. See [Supported DB engines for DB instance classes](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora) |aurora-postgresql|
|db.engine_version| | version of Postgresql |15.3|
|db.parameter_group|database engine parameters|aurora-postgresql15|
|db.instance_type|AWS instance type. |db.t4g.micro|
|db.instance_count|Number of instances in the cluster|2|
|db.root_username| admin user name | postgres |
|db.root_password| admin password. When a password is not set, terraform generates a password|null|
|bbb.type|EC2 instance type|c5.4xlarge|
|bbb.count| Number of BBB servers to deploy|2|
|bbb.size| Root volume size in GB| 50|
|bbb.hostname|hostname of BBB servers|bbb|
|bbb.hostname_pattern|Overrides the general `hostname_pattern`| _hostname_pattern_|
|bbb.iam_role|IAM role to assign to BBB instances. When a value is not supplied the general  `iam_role` value is used. | _iam\_role_|
|bbb.ami_name_filter|Override filter for selecting an image to use for BBB servers| _ami\_name\_filter_|
|bbb.ami_id|Specific AMI image to use for BBB servers| _ami\_id_|
|bbb.email|Email used to generate SSL certificate for BBB servers. Overrides the `email` | _email_|
|bbb.secrets|Map of secrets for each BBB host.|null|
|sl.type|EC2 instance type for Scalelite servers|t3.medium|
|sl.count|Number of Scalelite servers to deploy|1|
|sl.size|Size of root volume in GB|20|
|sl.hostname|Hostname or hostname prefix used when there are multiple Scalelite servers deployed|sl|
|sl.hostname_pattern|Overrides the general `hostname_pattern`| _hostname_pattern_|
|sl.iam_role|IAM role to assign to Scalelite instances. When a value is not supplied the general  `iam_role` value is used. | _iam\_role_|
|sl.ami_name_filter|Override filter for selecting an image to use for Scalelite servers| _ami\_name\_filter_|
|sl.ami_id|Specific AMI image to use for Scalelite servers| _ami\_id_|
|sl.lb_secret|Load balancer secret. A random password will be generated when the secret is not supplied|null|
|sl.image_tag|Docker tag version of Scalelite on [docker.io](https://hub.docker.com/r/blindsidenetwks/scalelite/tags)|v1.5-stable-focal260-alpine|
|sl.enable_tenants| flag to configure Scalelite to support multi-tenancy|false|
|sl.tenants| map of tenant hosts and their secrets|
|sl.tenant_ssl.key_file|Location of SSL private key for tenant subdomain(S)|null|
|sl.tenant_ssl.crt_file|Location of SSL Certificate for tenant subdomain(s)|null|
|gl.type|EC2 instance type for GreenLight servers|t3.medium|
|gl.count|Number of GreenLight servers to deploy|1|
|gl.size|Root volume size in GB|20|
|gl.hostname|Hostname or hostname prefix used when there are multiple GreenLight servers deployed|sl|
|gl.hostname_pattern|Overrides the general `hostname_pattern`| _hostname_pattern_|
|gl.iam_role|IAM role to assign to GreenLight instances. When a value is not supplied the general  `iam_role` value is used. | _iam\_role_|
|gl.ami_name_filter|Override filter for selecting an image to use for GreenLight servers| _ami\_name\_filter_|
|gl.ami_id|Specific AMI image to use for GreenLight servers| _ami\_id_|
|gl.admin.email|Admin user's email|null|
|gl.admin.password|Admin user's password|null|
|gl.admin.name|Admin user's name|null|
|ssh.user|ssh user|_required_|
|ssh.key_name|Name of key pair assigned to instances|_required_|
|ssh.key_file|SSH identify file associated with `ssh.key_name` |_required_|
|ssl.crt_file|Wildcard SSL certificate file|null|
|ssl.key_file|Wildcard SSL private key file|null|

# AWS Policies

IAM role assigned to instances must have the following capabilites as shown in the examples below.

1. Log to CloudWatch
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::myawsbucket/*"
        }
    ]
}
```
2. Mount and Read/Write to EFS
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "efs-statement-bbb-pen-policy",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientMount"
            ],
            "Resource": "arn:aws:elasticfilesystem:ca-central-1:927630699464:file-system/fs-0b2a0758d7c21db2e",
            "Condition": {
                "Bool": {
                    "elasticfilesystem:AccessedViaMountTarget": "true"
                }
            }
        },
        {
            "Sid": "efs-statement-bbb-pen-users",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::927630699464:role/AdministratorAccess"
            },
            "Action": [
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientMount"
            ],
            "Resource": "arn:aws:elasticfilesystem:ca-central-1:927630699464:file-system/fs-0b2a0758d7c21db2e"
        }
    ]
}
```