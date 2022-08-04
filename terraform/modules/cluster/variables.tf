variable "private_key_file" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "public_key_file" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "cluster_name" {
  type    = string
  default = null
}

variable "allowed_ssh_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allowed_k8s_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "pod_network_cidr_block" {
  type    = string
  default = null
}

variable "master_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "worker_instance_type" {
  type    = string
  default = "t2.small"
}

variable "num_workers" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
