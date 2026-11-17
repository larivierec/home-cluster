locals {
  home_cluster_issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/kubernetes", color = "72ccf3", description = "Issue relates to Kubernetes" },
      { name = "area/terraform", color = "72ccf3", description = "Issue relates to Terraform" },
      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
      { name = "renovate/helm", color = "ffc300", description = "Issue relates to a Renovate helm update" },
    ],
    local.default_issue_labels
  )

  cloudflare_ddns_issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/go", color = "72ccf3", description = "Issue relates to Go" },
      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
    ],
    local.default_issue_labels
  )

  containers_issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/containers", color = "72ccf3", description = "Issue related to dockerfiles" },
      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
    ],
    local.default_issue_labels
  )

  aws_es_proxy_issue_labels = concat(
    [
      { name = "area/ci", color = "72ccf3", description = "Issue relates to CI" },
      { name = "area/go", color = "72ccf3", description = "Issue relates to Go" },
      { name = "renovate/container", color = "ffc300", description = "Issue relates to a Renovate container update" },
    ],
    local.default_issue_labels
  )
}

resource "github_repository" "home_cluster" {
  name                   = "home-cluster"
  description            = "Talos cluster using gitops and renovate automation"
  topics                 = ["kubernetes", "gitops", "kubesearch", "renovate", "flux", "talos"]
  visibility             = "public"
  homepage_url           = "https://garb.dev"
  auto_init              = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  has_issues             = true
  has_wiki               = false
  has_projects           = false
  is_template            = false
  archived               = false
  archive_on_destroy     = true

  lifecycle {
    ignore_changes = [auto_init, gitignore_template, license_template, template]
  }
}

resource "github_issue_label" "home_cluster" {
  for_each = { for label in local.home_cluster_issue_labels : lower(label.name) => label }

  repository  = github_repository.home_cluster.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}

resource "github_actions_secret" "home_cluster" {
  for_each = {
    RIVERBOT_APP_ID          = nonsensitive(local.github_secrets["bot_id"])
    RIVERBOT_APP_PRIVATE_KEY = nonsensitive(base64decode(local.github_secrets["bot_pk_b64"]))
    OP_CONNECT_TOKEN         = nonsensitive(local.onep_secrets["OP_CONNECT_TOKEN"])
  }

  repository  = github_repository.home_cluster.name
  secret_name = each.key
  value       = each.value
}

resource "github_repository" "cloudflare_ddns" {
  name                   = "cloudflare-ddns"
  description            = "Cloudflare ddns written in Golang"
  topics                 = ["go", "ddns", "cloudflare", "containers"]
  visibility             = "public"
  homepage_url           = "https://garb.dev"
  auto_init              = false
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  has_issues             = true
  has_wiki               = false
  has_projects           = false
  is_template            = false
  archived               = false
  archive_on_destroy     = true

  lifecycle {
    ignore_changes = [auto_init, gitignore_template, license_template, template]
  }
}

resource "github_issue_label" "cloudflare_ddns" {
  for_each = { for label in local.cloudflare_ddns_issue_labels : lower(label.name) => label }

  repository  = github_repository.cloudflare_ddns.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}

resource "github_repository" "containers" {
  name                   = "containers"
  description            = "Containers used in my kubernetes cluster and other various containers"
  topics                 = ["docker", "containers"]
  visibility             = "public"
  homepage_url           = "https://garb.dev"
  auto_init              = false
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  has_issues             = true
  has_wiki               = false
  has_projects           = false
  is_template            = false
  archived               = false
  archive_on_destroy     = true

  lifecycle {
    ignore_changes = [auto_init, gitignore_template, license_template, template]
  }
}

resource "github_issue_label" "containers" {
  for_each = { for label in local.containers_issue_labels : lower(label.name) => label }

  repository  = github_repository.containers.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}

resource "github_repository" "aws_es_proxy" {
  name                   = "aws-es-proxy"
  description            = "Fork of AWS ES Proxy `abutaha/aws-es-proxy` providing automatic updates via Renovate"
  topics                 = ["go", "aws", "es", "elasticsearch", "aws-sdk-go-v2"]
  visibility             = "public"
  homepage_url           = ""
  auto_init              = false
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  has_issues             = true
  has_wiki               = false
  has_projects           = false
  is_template            = false
  archived               = false
  archive_on_destroy     = true

  lifecycle {
    ignore_changes = [auto_init, gitignore_template, license_template, template]
  }
}

resource "github_issue_label" "aws_es_proxy" {
  for_each = { for label in local.aws_es_proxy_issue_labels : lower(label.name) => label }

  repository  = github_repository.aws_es_proxy.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}
