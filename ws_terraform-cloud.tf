
resource "tfe_workspace" "terraform-cloud" {
  name              = "terraform-cloud"
  organization      = tfe_organization.primary_org.id
  description       = "Workspace for managing all TFC workspaces with TFC."
  working_directory = "workspaces"
  vcs_repo {
    identifier     = "${var.githhub_org_name}/terraform-cloud"
    branch         = "main"
    oauth_token_id = var.github_token_id

  }
}

