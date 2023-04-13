remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.rs_project}"
    credentials    = "${get_parent_terragrunt_dir()}/../../../secure/tf/keys/${local.rs_project}-service-account-key.json"
    prefix         = "${local.project}/${path_relative_to_include()}"
    location       = "${local.gcp_region}"
    project        = "${local.project}"
  }
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}
