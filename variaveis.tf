variable "porta_ssh" {
  type    = number
  default = 22
}

variable "ips_qualquer_lugar_v4" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ips_qualquer_lugar_v6" {
  type    = list(string)
  default = ["::/0"]
}