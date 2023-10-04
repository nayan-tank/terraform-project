variable "vpc_cidr" {
   default = "10.1.0.0/16"
}

variable "basename" {
   description = "Prefix used for all resources names"
   default = "dev"
}

variable "cluster_name" {
  type        = string
  description = "Name of the eks cluster"
}



variable "azs" {
  type = list(string)
  default = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
}

variable "public_subnet_list" {
   type = map
   default = {
      public-1 = {
         index = 0
         az = "us-east-2a"
         cidr = "10.1.1.0/24"
      }
      public-2 = {
         index = 1
         az = "us-east-2b"
         cidr = "10.1.2.0/24"
      }
      public-3 = {
         index = 2
         az = "us-east-2c"
         cidr = "10.1.3.0/24"
      }
   }
}

variable "private_subnet_list" {
   type = map
   default = {
      private-1 = {
         index = 0
         az = "us-east-2a"
         cidr = "10.1.4.0/24"
      }
      private-2 = {
         index = 1
         az = "us-east-2b"
         cidr = "10.1.5.0/24"
      }
      private-3 = {
         index = 2
         az = "us-east-2c"
         cidr = "10.1.6.0/24"
      }
   }
}


variable "route_cidr" {
  type = string
  default = "0.0.0.0/0"
}
