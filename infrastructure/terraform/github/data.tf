locals {
  default_issue_labels = [
    { name = "type/patch", color = "ffec19", description = "Issue relates to a patch version bump" },
    { name = "type/minor", color = "ff9800", description = "Issue relates to a minor version bump" },
    { name = "type/major", color = "f6412d", description = "Issue relates to a major version bump" },

    { name = "size/XS", color = "009900", description = "Marks a PR that changes 0-9 lines, ignoring generated files" },
    { name = "size/S", color = "77bb00", description = "Marks a PR that changes 10-29 lines, ignoring generated files" },
    { name = "size/M", color = "eebb00", description = "Marks a PR that changes 30-99 lines, ignoring generated files" },
    { name = "size/L", color = "ee9900", description = "Marks a PR that changes 100-499 lines, ignoring generated files" },
    { name = "size/XL", color = "ee5500", description = "Marks a PR that changes 500-999 lines, ignoring generated files" },
    { name = "size/XXL", color = "ee0000", description = "Marks PR that changes 1000+ lines, ignoring generated files" },

    { name = "bug", color = "d73a4a", description = "Something isn't working" },
    { name = "documentation", color = "0075ca", description = "Improvements or additions to documentation" },
    { name = "enhancement", color = "a2eeef", description = "New feature or request" },
    { name = "question", color = "d876e3", description = "Further information is requested" },
    { name = "wontfix", color = "ffffff", description = "This will not be worked on" },
    { name = "do-not-merge", color = "ee0701", description = "Marks PR that is not (yet) in a mergeable state" }
  ]
}

data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}
