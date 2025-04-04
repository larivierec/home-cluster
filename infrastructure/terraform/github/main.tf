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

module "aws-es-proxy" {
  source  = "mineiros-io/repository/github"
  version = "0.18.0"

  name        = "aws-es-proxy"
  description = "Fork of AWS ES Proxy `abutaha/aws-es-proxy` providing automatic updates via Renovate"
  topics      = ["go", "aws", "es", "elasticsearch", "aws-sdk-go-v2"]
  visibility  = "public"

  auto_init              = false
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  has_issues   = true
  has_wiki     = false
  has_projects = false
  is_template  = false

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

resource "github_repository" "renovate" {
  name        = ".github"
  description = "Personal renovate configuration"
  visibility  = "public"
}

resource "github_repository_topics" "renovate" {
  repository = github_repository.renovate.name
  topics     = ["renovate"]
}

resource "github_actions_secret" "bot_app_id" {
  repository      = github_repository.renovate.name
  secret_name     = "RIVERBOT_APP_ID"
  plaintext_value = nonsensitive(local.github_secrets["bot_id"])
}

resource "github_actions_secret" "bot_app_pk" {
  repository      = github_repository.renovate.name
  secret_name     = "RIVERBOT_APP_PRIVATE_KEY"
  plaintext_value = nonsensitive(base64decode(local.github_secrets["bot_pk_b64"]))
}
