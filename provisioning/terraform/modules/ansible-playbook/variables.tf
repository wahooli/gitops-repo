variable "plays" {
    type        = list(object({
        hosts               = list(string)
        gather_facts        = bool
        become              = bool
        any_errors_fatal    = optional(bool)
        roles               = list(string)
    }))
    description = "Plays in playbook"
    validation {
        condition = length(var.plays) >= 1
        error_message = "You have to define plays."
    }
}

variable "filename" {
    type        = string
    description = "Filename to be generated. Relative to ansible directory"
}