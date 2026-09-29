variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_link" {
  type = string
}

variable "environment" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "cloudflare_zone" {
  description = "Zone the records are created in, as registered in Cloudflare. The zone id is looked up from it."
  type        = string
}

variable "base_mapping" {
  type = string
}