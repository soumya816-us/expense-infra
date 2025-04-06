variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}


variable "common_tags" {
  
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
  }
}
variable "zone_id" {
  default = "Z03706093F6CZRPJ7KSFC"
  
}
variable "domain_name" {
  default = "telugustreetbyte.online"
}