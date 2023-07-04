module "home-ops" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "home-cluster"
  description = "k3s cluster using gitops (flux) and renovate automation"
  topics      = ["flux", "gitops", "iac", "k8s-at-home", "kubernetes", "renovate", "nvidia-docker", "k3s", "bitwarden"]
  visibility  = "public"

  auto_init              = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = {
    "RIVERBOT_APP_ID"          = lookup(local.github_secrets, "bot_id").text
    "RIVERBOT_APP_PRIVATE_KEY" = data.sops_file.this.data["SECRET_BOT_PRIVATE_KEY"]
  }

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/kubernetes", color = "72ccf3", description = "Issue relates to Kubernetes" },
      { name = "area/terraform", color = "72ccf3", description = "Issue relates to Terraform" },

      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
      { name = "renovate/helm", color = "ffc300", description = "Issue relates to a Renovate helm update" },
    ],
    local.default_issue_labels
  )
}
