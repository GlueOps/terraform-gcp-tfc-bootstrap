# Terraform to manage Terraform Cloud (GCP)
## Initially Setting Up TFC
1.  Comment out the following, from `workspaces/backend.tf` so it looks like the below:

```
  # variable "tfc_token" {}
  
  # terraform {
  #   required_version = "1.1.8"
  #   backend "remote" {
  #     organization = "GlueOps"
  #     workspaces {
  #       name = "terraform-cloud"
  #     }
  #   }
  #   required_providers {
  #     tfe = "0.30.2"
  #   }
  # }
  
  
  provider "tfe" {
  #  token = var.tfc_token
  }
```

2. cd to `workspaces/` and run the commands below - note that you must enter any string for `slack_token` until the token is available in steps below.
  `terraform login`
  `terraform init`
  `terraform apply --target=tfe_organization.primary_org`

3.  Connect GithuHub **using service account** (e.g. `github@glueops.dev`)
https://app.terraform.io/app/GlueOps/settings/version-control/add
! don't forget to grant access when approving

4. Get `OAuth Token ID`  (https://app.terraform.io/app/GlueOps/settings/version-control)

5. Go to `workspaces/locals.tf` and add `OAuth Token ID`

6. Run another targeted apply to deploy the workspaces:`terraform apply --target=tfe_workspace.terraform-cloud --target=tfe_workspace.gcp-organization`
**make sure there is at least one commit in the repositories backing the new workspaces**

7. Create a slack token to enter for the final apply. (https://{your-workspace}.slack.com/apps/A0F7XDUAZ-incoming-webhooks)

8. Run `terraform apply` and paste in the slack token you created.

## Migrate from Local TF to TFC
9. Create an org token for TFC - https://app.terraform.io/app/GlueOps/settings/authentication-tokens

10. Put org token in variables in TFC workspaces `terraform_cloud` as a sensitive, Terraform variable,  called `tfc_token`, use the description: **tfc org token**

11. Uncomment terraform block in `backend.tf`, so it looks like this:
```
# variable "tfc_token" {}

terraform {
  required_version = "1.1.8"
  backend "remote" {
    organization = "GlueOps"
    workspaces {
      name = "terraform-cloud"
    }
  }
  required_providers {
    tfe = "0.31.0"
  }
}


provider "tfe" {
  # token = var.tfc_token
}
```


12. `terraform init`
13. Type `yes` to migrate backend to TFC
14. Make sure all changes from `local.tf` are committed and pushed up



15. Abandon any other file changes to the repo, they aren't needed


16. In the the Org settings add a variable set called `tfc_core` that applies for all workspaces and add then add `TF_VAR_slack_token` as a sensitive environment variable.



## Set up GCP Service User

1. At the Organization level, grant `Billing Account Administrator`, `Owner`, and `Organization Administrator` permissions to your user.
2. Create project for service accounts, e.g. `glueops-1-svc-accounts`
ref: https://lunajacob.medium.com/setting-up-terraform-cloud-with-gcp-e1fe6c99a78e

3. Create a billing account for GCP and link the billing account to your service project.

4. Enable `Cloud Billing API` for service account, at https://console.cloud.google.com/apis/library/cloudbilling.googleapis.com.
   Enable `Resource Manager API` for service account, at https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com
   Enable `Cloud KMS API` for service account, at https://console.developers.google.com/apis/api/cloudkms.googleapis.com
   Enable `AppEngine API` for service account, at https://console.cloud.google.com/apis/library/appengine.googleapis.com
   Enable `CloudBuild API` for service account, at https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com
   Enable `Kubernetes Engine API` for service account, at https://console.developers.google.com/apis/library/container.googleapis.com


5. open CloudShell in the service account environment and run the following:
```
gcloud iam service-accounts create svc-terraform \
--description "Service account for all projects, used by Terraform Cloud" \
--display-name "svc-account for Terraform Cloud"
```

6. Retrieve service account email address using: `gcloud iam service-accounts list`
```
$ gcloud iam service-accounts list
DISPLAY NAME: svc-account for Terraform Cloud
EMAIL: svc-terraform@glueops-1-svc-accounts.iam.gserviceaccount.com
DISABLED: False
```


7. At the `Organization` level, grant `Billing Account Administrator`, `Organization Administrator`, and `Project Creator` roles to `svc-terraform@glueops-1-svc-accounts.iam.gserviceaccount.com`, so they apply to all projects.
Navigate to IAM and use the email address you saved to apply permissions.




8. Created key for `svc-terraform@glueops-1-svc-accounts.iam.gserviceaccount.com` in GCP Console
 - export key as json and remove newlines
 - edit keyfile to remove all newlines (e.g. in vim, use `:%s/\n//g`)
 - add a sensitive Environment variable called `GOOGLE_CREDENTIALS` to the variable set created above (tfc_core) - use the service account name as the description.
 
9. Add service account email to `gcp-infrastructure/organization/tf/locals.tf`

