module "yaml_file" {
    source = "../yaml-file"
    content = { all = {children = var.content} }
    filename = "${path.module}/../../../ansible/${var.filename}"
}