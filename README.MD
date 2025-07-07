# GCP Infrastructure with Terraform

This project provisions:
- A GCP Compute Engine instance
- A VPC with subnet and firewall rules
- A GCS bucket for Terraform state storage

## Prerequisites
- Google Cloud SDK installed and configured
- Terraform installed
- SSH key pair for instance access

## Usage
1. `terraform init`
2. `terraform plan -var="project_id=your-project-id"`
3. `terraform apply -var="project_id=your-project-id"`
4. `terraform destroy -var="project_id=your-project-id"` when done
