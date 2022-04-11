module "yaml_file" {
    source = "../yaml-file"
    content = var.content
    filename = "${path.module}/../../../ansible/${var.filename}"
}