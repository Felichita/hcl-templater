remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket      = "${local.rs_project}"
    credentials = "${get_parent_terragrunt_dir()}/../../../secure/tf/keys/${local.rs_project}-service-account-key.json"
    prefix      = "${local.project}/${path_relative_to_include()}"
    location    = "${local.gcp_region}"
    project     = "${local.project}"
  }
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}

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

%{if local.cloud == "both"}
provider "tencentcloud" {
  region   = "${local.tencent_region}"
}
%{else}
provider "tencentcloud" {
  secret_id  = "${get_parent_terragrunt_dir()}/../../../secure/tf/keys/${local.project}-service-account-key.json"
  secret_key = "${local.project}-service-account-key.json"
  region     = "$(local.tencent_region}"
}
%{endif}

provider "google" {
  credentials    = "${get_parent_terragrunt_dir()}/../../../secure/tf/keys/service-account-key.json"
  project        = "${local.project}"
  region         = "${local.gcp_region}"
}

EOF
}


locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")

  common_vars = merge(
    yamldecode(file(find_in_parent_folders("account.yaml", local.default_yaml_path))),
    yamldecode(file(find_in_parent_folders("env.yaml", local.default_yaml_path))),
  )

  tencent_region = lookup(local.common_vars, "region", "eu-frankfurt")
  gcp_region     = lookup(local.common_vars, "location", "europe-central2")
  rs_project     = "cosmos-tfstate"
  project        = lookup(local.common_vars, "project", "project")
  cloud          = lookup(local.common_vars, "gcp", "both")
}
