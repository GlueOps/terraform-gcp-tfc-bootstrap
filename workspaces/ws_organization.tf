
resource "tfe_workspace" "gcp-organization" {
  name              = "gcp-organization"
  organization      = tfe_organization.primary_org.id
  terraform_version = local.terraform_version
  description       = "Terraform for managing the GCP organization and all associated projects."
  working_directory = "organization/tf"
  vcs_repo {
    identifier     = "${local.vcs_settings.githhub_org_name}/${local.vcs_settings.vcs_repo}"
    branch         = "main"
    oauth_token_id = local.vcs_settings.github_token_id

  }
}
