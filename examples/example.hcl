%include _global/remote_state.hcl
%include _global/provider.hcl

locals {
 default_yaml_path = find_in_parent_folders("empty.yaml")

 common_vars = merge(
   yamldecode(file(find_in_parent_folders("account.yaml", local.default_yaml_path))),
   yamldecode(file(find_in_parent_folders("env.yaml", local.default_yaml_path))),
 )

  tencent_region = lookup(local.common_vars, "region",   "eu-frankfurt")
  gcp_region     = lookup(local.common_vars, "location", "europe-central2")
  rs_project     = "cosmos-tfstate"
  project        = lookup(local.common_vars, "project", "dydx-testnet")
  cloud          = lookup(local.common_vars, "gcp", "both")
}
