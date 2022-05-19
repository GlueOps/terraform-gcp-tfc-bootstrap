locals {
  env_data = flatten([
    for wks in var.workspaces : [
      for env in wks.env : [
        {
          workspace         = wks.workspace
          vcs_branch        = wks.vcs_branch
          env               = env
          working_directory = wks.working_directory
        }
      ]
    ]
  ])
}

resource "tfe_organization" "primary_org" {
  name                     = var.org_name
  email                    = var.tfc_email
  collaborator_auth_policy = "two_factor_mandatory"
}

module "workspaces" {
  source   = "git::https://github.com/GlueOps/terraform-multi-environment-workspace.git?ref=v0.1.1"
  for_each = toset(local.env_data)

  tf_cloud_workspace_name       = each.value.env_data.workspace
  organization                  = tfe_organization.primary_org.id
  terraform_version             = local.terraform_version
  working_directory             = each.value.working_directory
  oauth_token_id                = var.github_token_id
  tf_local_workspace            = each.value.env
  vcs_repo                      = "${local.vcs_settings.githhub_org_name}/${local.vcs_settings.vcs_repo}"
  vcs_branch                    = each.value.vcs_branch
  workspace_ids_to_trigger_runs = [tfe_workspace.gcp-organization.id]
  auto_apply                    = each.value.auto_apply
  slack_token                   = var.slack_token
}

