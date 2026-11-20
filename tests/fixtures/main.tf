terraform {
  required_version = ">= 1.5"
}

variable "name" {
  type    = string
  default = "sample"
}

output "greeting" {
  value = "hello ${var.name}"
}
