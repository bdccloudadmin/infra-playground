# infra-playground

Terraform playground for my future startup infrastructure.

## Structure

- `modules/`
  - Reusable Terraform modules (e.g. `s3_bucket`).
- `envs/sandbox/`
  - `s3-demo/` – S3 bucket demo using `s3_bucket` module and remote state in S3.
  - `vpc-demo/` – VPC + subnets + IGW demo.
- `state-backend/`
  - Terraform project that bootstrapped the S3 bucket used as Terraform remote state.

## Usage

S3 demo:

```bash
cd envs/sandbox/s3-demo
terraform init
terraform plan
terraform apply

cd envs/sandbox/vpc-demo
terraform init
terraform plan
terraform apply


---

### Step 7.9 – Initialize Git in `infra-playground` (make it the repo root)

In PowerShell:

```powershell
cd C:\Users\sguis\infra-playground

git init
git status
