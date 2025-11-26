terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "mycompany-tfstate-sandbox-123456789012"
    key          = "s3-demo/terraform.tfstate"
    region       = "eu-west-1"
    profile      = "sandbox"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "sandbox"
}

# 👇 NEW: call the module instead of defining resources directly
module "sandbox_bucket" {
  source      = "../../../modules/s3_bucket"   # ✅ correct

  bucket_name = "firstname-sandbox-bucket-12345"
  tags = {
    Name = "infra-playground"
    env  = "sandbox"
  }
}





