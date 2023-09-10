variable "tag_common" {
  type = string

  validation {
    condition = can(regex("([0-9a-z])", var.tag_common))
    error_message = "For tag value only a-z and 0-9 are allowed."
  }
}

variable "rds" {}