variable "region" { default = "eu-central-1" }
variable "profile" { default = "terraform" }
variable "key" { default = "Frankfurt-key" }
variable "instance_type" { default = "t2.micro" }
variable "ami" { default = "ami-030e490c34394591b" }

variable "stack" { default = "terrik" }
variable "database_name" { default = "wordpress" }
variable "database_user" { default = "marti" }
variable "database_password" { default = "password" }
