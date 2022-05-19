variable "slack_token" { sensitive = true }

variable "org_name" {}
variable "tfc_email" {}
variable "terraform_version" {}

variable "github_token_id" {}
variable "githhub_org_name" {}
variable "vcs_repo" {}

variable "environments" {
  type = list(string)
  default = [
    "dev",
    "test",
    "stage",
    "prod",
  ]
}

variable "notification_triggers" {
  type = list(string)
  default = [ "run:needs_attention" ]
}

variable "workspaces" {
  type = list(map)
  default = [
    {
      workspace = "gcp-organization"
      vcs_branch = "main"
      envs = [ "dev", "stage", "prod" ]
      working_directory = "gke/tf"
      auto_apply = false
    }
}

