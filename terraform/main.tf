locals {
  flux_ssh_private_key = try(var.git_credentials.flux_ssh_private_key_path, null) != null ? file(var.git_credentials.flux_ssh_private_key_path) : null
}

## https://registry.terraform.io/providers/fluxcd/flux/latest/docs/resources/bootstrap_git
resource "flux_bootstrap_git" "main" {
  author_email            = var.git_credentials.author_email
  author_name             = var.git_credentials.author_name
  branch                  = var.system_repo.branch
  cluster_domain          = var.flux_properties.cluster_domain
  commit_message_appendix = var.git_credentials.commit_message
  components              = var.flux_properties.components
  components_extra        = var.flux_properties.components_extra
  image_pull_secret       = var.flux_properties.image_pull_secret
  kustomization_override  = var.kustomization_override
  log_level               = var.flux_properties.log_level
  namespace               = var.system_repo.namespace
  network_policy          = var.flux_properties.network_policy
  path                    = var.system_repo.path == null ? format("flux/clusters/%s", var.aks_cluster_name) : var.system_repo.path
  registry                = var.flux_properties.registry
  secret_name             = var.system_repo.secret
  toleration_keys         = var.flux_properties.toleration_keys
  url                     = var.system_repo.url
  version                 = var.flux_properties.version

  ssh = {
    private_key = coalesce(local.flux_ssh_private_key, try(base64decode(data.external.env.result["FLUX_SSH_PRIVATE_KEY"]), ""))
    username    = var.git_credentials.ssh_username
    password    = try(base64decode(data.external.env.result["FLUX_SSH_PRIVATE_KEY_PASSWORD"]), null)
  }

}
