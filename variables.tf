variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "South India"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = ""
}

variable "subnet_name" {
  description = "The name of the subnet to use in VM scale set"
  default     = ""
}

variable "pip_name" {
  description = "The name of the public ip"
  default     = ""
}


variable "virtual_machine_name" {
  description = "The name of the virtual machine."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    environment = "test"
    owner       = "sumit"
  }
}