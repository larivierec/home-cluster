provider "github" {
  token = local.github_secrets["pat"]
}

provider "onepassword" {
  # Uses OP_CONNECT_HOST and OP_CONNECT_TOKEN environment variables
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
