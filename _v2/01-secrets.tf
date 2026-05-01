data "sops_file" "secrets" {
  source_file = "files/secrets.enc.yaml"
}
