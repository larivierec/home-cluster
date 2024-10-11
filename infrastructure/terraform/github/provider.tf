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
  id = "b283f0a4-85da-4ce3-a5fa-b20400d83993"
}

data "bitwarden_secret" "github" {
  id = "4c93fe22-dd57-4d4d-96b2-b20600132b47"
}

locals {
  github_secrets = jsondecode(data.bitwarden_secret.github.value)
  secrets        = jsondecode(data.bitwarden_secret.this.value)
}
