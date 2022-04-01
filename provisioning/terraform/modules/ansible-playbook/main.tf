terraform {
    experiments = [module_variable_optional_attrs]
}

module "yaml_file" {
    source = "../yaml-file"
    content = var.plays
    filename = "${path.module}/../../../ansible/${var.filename}"
}