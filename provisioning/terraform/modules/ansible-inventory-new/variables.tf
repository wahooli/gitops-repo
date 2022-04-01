variable "content" {
    type        = map(object({
        hosts   = map(any)
    }))
    description = "Content to be encoded as yaml"

}

variable "filename" {
    type        = string
    description = "Filename to be generated. Relative to ansible directory"
}