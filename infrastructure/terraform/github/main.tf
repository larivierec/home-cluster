module "home-cluster" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name         = "home-cluster"
  description  = "Talos cluster using gitops and renovate automation"
  topics       = ["flux", "gitops", "iac", "k8s-at-home", "kubernetes", "renovate", "tailscale", "talos", "bitwarden"]
  visibility   = "public"
  homepage_url = "https://garb.dev"

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
    "RIVERBOT_APP_ID"          = nonsensitive(local.github_secrets["bot_id"])
    "RIVERBOT_APP_PRIVATE_KEY" = nonsensitive(base64decode(local.github_secrets["bot_pk_b64"]))
    "BW_ACCESS_TOKEN"          = nonsensitive(local.github_secrets["gha_bw_access_token"])
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

module "cloudflare-ddns" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name         = "cloudflare-ddns"
  description  = "Cloudflare ddns written in Golang"
  topics       = ["go", "ddns", "cloudflare", "containers"]
  visibility   = "public"
  homepage_url = "https://garb.dev"

  auto_init              = false
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = {
    "RIVERBOT_APP_ID"          = nonsensitive(local.github_secrets["bot_id"])
    "RIVERBOT_APP_PRIVATE_KEY" = nonsensitive(base64decode(local.github_secrets["bot_pk_b64"]))
  }

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/go", color = "72ccf3", description = "Issue relates to Go" },

      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
    ],
    local.default_issue_labels
  )
}

module "containers" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name         = "containers"
  description  = "Containers used in my kubernetes cluster and other various containers"
  topics       = ["docker", "containers"]
  visibility   = "public"
  homepage_url = "https://garb.dev"

  auto_init              = false
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

  plaintext_secrets = {
    "RIVERBOT_APP_ID"          = nonsensitive(local.github_secrets["bot_id"])
    "RIVERBOT_APP_PRIVATE_KEY" = nonsensitive(base64decode(local.github_secrets["bot_pk_b64"]))
  }

  issue_labels_merge_with_github_labels = false
  issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/containers", color = "72ccf3", description = "Issue related to dockerfiles" },
      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
    ],
    local.default_issue_labels
  )
}
