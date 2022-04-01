resource "local_file" "yaml_generic" {
    # content  = yamlencode(var.content)
    # found this replace regex from github issue, makes the output yaml more neat, even if default functionality could work. didn't test it
    content = replace(yamlencode(var.content), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:")
    filename = abspath(var.filename)
}