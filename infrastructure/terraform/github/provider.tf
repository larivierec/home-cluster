provider "github" {
  token = local.github_secrets["pat"]
}

provider "bitwarden" {
  access_token = data.sops_file.this.data["BW_PROJECT_TOKEN"]
  experimental {
    embedded_client = true
  }
}

data "bitwarden_secret" "this" {
  key = "actions_runner"
}

data "bitwarden_secret" "github" {
  key = "github"
}

locals {
  github_secrets = jsondecode(data.bitwarden_secret.github.value)
  secrets        = jsondecode(data.bitwarden_secret.this.value)
}
