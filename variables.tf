variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "demo-rg"
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "South India"
}

variable "vn_name" {
  description = "Virtual Network name"
  default     = "demo-network"
}

variable "address_space" {
  description = "Virtual Network name"
  default     = ["10.123.0.0/16"]
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