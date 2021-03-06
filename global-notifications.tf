resource "tfe_notification_configuration" "slack" {
  for_each         = toset([tfe_workspace.terraform-cloud.id, tfe_workspace.gcp-organization.id])
  name             = "needs_attention"
  enabled          = true
  destination_type = "slack"
  url              = "https://hooks.slack.com/services/${var.slack_token}"
  triggers         = var.notification_triggers
  workspace_id     = each.key
}

