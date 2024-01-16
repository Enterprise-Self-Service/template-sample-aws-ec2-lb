variable "vpc_name" {
  description = "Name of VPC you would like to select"
  type        = string
  default     = "*"
}

variable "subnet_name" {
  description = "Name of subnets you would like to select"
  type        = string
  default     = "*"
}

variable "user_data" {
  type        = string
  description = "Either a shell script, or cloud-init script for the instance to run on first boot"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "The AWS EC2 instance type"
  default     = "t2.small"
}

variable "instance_count" {
  type        = number
  description = "How many instances"
  default     = 1
}

variable "instance_profile" {
  type        = string
  description = "Instance profile name that is attached to the instance"
  default     = "AmazonSSMRoleForInstancesQuickSetup"
}

variable "disk_size" {
  type        = string
  description = "The size of the disk attached to the instance"
  default     = "50"
}

variable "alb_name" {
  description = "The name of the ALB you would like to create"
  type        = string
  default     = "public-alb"
}

variable "hosted_zone_id" {
  type = string
}

variable "domain" {
  description = "What domain will point to the load balamncer. Note DNS entry will be created"
  type = string
}

variable "host_header" {
  type = string
}
