variable "project" {
  description = "Subnet name"
  default     = "demo"
}


variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "South India"
}


variable "subnet_name" {
  description = "Subnet name"
  default     = "subnet_1"
}

variable "subnet_addr_space" {
  description = "Virtual Network name"
  default     = ["10.123.1.0/24"]
}

variable "address_space" {
  description = "Virtual Network name"
  default     = ["10.123.0.0/16"]
}

variable "sg_name" {
  description = "Subnet name"
  default     = "demo-sg"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
    env    = "test"
    owner  = "sumit"
  }
}