# Terraform: Status Dashboard on AWS

One `terraform apply` builds a server on AWS that runs a status dashboard
(Python app + Postgres) in Docker Compose. No manual setup after apply.

Dashboard code: https://github.com/Amruthjinesh/status-dashboard

## What it builds

- Security group: SSH (22) and dashboard (8000) open to my IP only
- EC2 t3.micro, Ubuntu 24.04, region eu-west-2
- `user_data` script installs Docker + Compose, clones the dashboard repo,
  writes the settings file, and starts it with `docker compose up`

## Diagram

```
 Laptop: terraform apply
          |
          v
 AWS (eu-west-2)
 +--------------------------------------+
 | Security group: 22, 8000 from my IP  |
 |  +--------------------------------+  |
 |  | EC2 t3.micro (Ubuntu 24.04)    |  |
 |  |  Docker + Compose              |  |
 |  |  [ app :8000 ] --> [ postgres ]|  |
 |  +--------------------------------+  |
 +--------------------------------------+
          ^
          |
 Browser: http://<public_ip>:8000
```

## Files

| File | Job |
|------|-----|
| main.tf | provider, AMI lookup, security group, EC2 + user_data |
| variables.tf | region, instance_type, key_name, my_ip, db_password |
| outputs.tf | public IP, dashboard URL, SSH command |
| .gitignore | keeps state, .terraform, tfvars and keys out of git |

## Requirements

- Terraform and AWS CLI, configured with an IAM user
- An existing EC2 key pair (default name `jenkins`, change `key_name`)

## How to run

```
terraform init
terraform apply -var="my_ip=YOUR_IP/32"
```

Terraform asks for `db_password` (letters and numbers only).
After about 3 minutes open the `dashboard_url` from the outputs.

## Clean up

```
terraform destroy -var="my_ip=YOUR_IP/32"
```

## Security notes

- `my_ip` and `db_password` have no defaults, so they are never in the code
- `db_password` is marked sensitive, but it still lands in `terraform.tfstate`
  (git-ignored, keep it local). A real team would use AWS Secrets Manager
  and remote state.
