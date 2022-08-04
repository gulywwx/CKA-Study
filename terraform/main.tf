module "network" {
  source     = "./modules/network"
  cidr_block = "10.0.0.0/16"
  tags       = { "cluster" = module.cluster.cluster_name }
}

module "cluster" {
  source                 = "./modules/cluster"
  vpc_id                 = module.network.vpc_id
  subnet_id              = module.network.subnet_id
  cluster_name           = var.cluster_name
  pod_network_cidr_block = var.pod_network_cidr_block
}