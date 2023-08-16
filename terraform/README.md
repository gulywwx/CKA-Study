
## Lab Environment:
To simplely setup 1 control plane and 2 work nodes ec2 environment using terrafrom on AWS.
you will need a valid AWS account with administrative privileges (or at least is allowed to execute the actions in the Terraform code). Get Access Key ID and a Secret Access Key of the AWS admin account.

```bash
# To use your IAM credentials to authenticate the Terraform AWS provider, set two environment variables.
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

# Update terraform.tfvars
vim terraform.tfvars

# Initialize the directory
terraform init

# Format and validate the configuration
terraform fmt
terraform validate

# Create infrastructure
terraform plan -var-file=terraform.tfvars -out=terraform.tfout
terraform apply -input=false -auto-approve=true -lock=true "terraform.tfout"

# Verify
ssh ubuntu@<control-plane node public ip>
kubectl get nodes

```
