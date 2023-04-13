generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "1.79.4"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }
  }
}

%{ if local.cloud == "both" }
provider "tencentcloud" {
  region   = "${local.tencent_region}"
}
%{ else }
provider "tencentcloud" {
  secret_id  = "${get_parent_terragrunt_dir()}/../../../secure/tf/keys/${local.project}-service-account-key.json"
  secret_key = "${local.project}-service-account-key.json"
  region     = "$(local.tencent_region}"
}
%{ endif }

provider "google" {
  credentials    = "${get_parent_terragrunt_dir()}/../../../secure/tf/keys/service-account-key.json"
  project        = "${local.project}"
  region         = "${local.gcp_region}"
}

EOF
}
