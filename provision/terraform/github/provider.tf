provider "github" {
  token = data.sops_file.this.data["SECRET_PAT_TF"]
}
