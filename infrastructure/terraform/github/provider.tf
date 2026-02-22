provider "github" {
  token = local.github_secrets["pat"]
}

provider "onepassword" {
  connect_url   = "https://op.garb.dev"
  connect_token = data.sops_file.this.data["OP_CONNECT_TOKEN"]
}

data "onepassword_item" "actions_runner" {
  vault = "Homelab"
  title = "actions_runner"
}

data "onepassword_item" "github" {
  vault = "Homelab"
  title = "github"
}

data "onepassword_item" "onep" {
  vault = "Homelab"
  title = "1password"
}

locals {
  github_secrets = {
    for field in [
      for section in data.onepassword_item.github.section :
      section if section.label == "credentials"
    ][0].field :
    field.label => field.value
  }
  secrets = {
    for field in [
      for section in data.onepassword_item.actions_runner.section :
      section if section.label == "credentials"
    ][0].field :
    field.label => field.value
  }
  onep_secrets = {
    for field in [
      for section in data.onepassword_item.onep.section :
      section if section.label == "credentials"
    ][0].field :
    field.label => field.value
  }
}
