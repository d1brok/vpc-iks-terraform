##############################################################################
# This file creates the VPC, Zones, subnets and public gateway for the VPC
# a separate file sets up the load balancers, listeners, pools and members
##############################################################################


##############################################################################
# Create a VPC
##############################################################################

resource ibm_is_vpc vpc {
  name                      = "${var.unique_id}-vpc"
  resource_group            = data.ibm_resource_group.resource_group.id
  classic_access            = var.classic_access
  address_prefix_management = "manual"
  tags                      = var.tags
}


##############################################################################
# Create Address Prefixes
##############################################################################

resource ibm_is_vpc_address_prefix prefix1 {
  name  = "${var.unique_id}-prefix-zone-1}"
  zone  = "${var.ibm_region}-1}"
  vpc   = ibm_is_vpc.vpc.id
  cidr  = element(var.prefix_cidr_blocks, 0)
}

resource ibm_is_vpc_address_prefix prefix2 {
  name  = "${var.unique_id}-prefix-zone-2}"
  zone  = "${var.ibm_region}-2}"
  vpc   = ibm_is_vpc.vpc.id
  cidr  = element(var.prefix_cidr_blocks, 1)
}

resource ibm_is_vpc_address_prefix prefix3 {
  name  = "${var.unique_id}-prefix-zone-3}"
  zone  = "${var.ibm_region}-2}"
  vpc   = ibm_is_vpc.vpc.id
  cidr  = element(var.prefix_cidr_blocks, 2)
}


##############################################################################
# Create Public Gateways
##############################################################################

resource ibm_is_public_gateway gateway {
  count = var.number_of_zones

  name  = "${var.unique_id}-gateway-zone-${count.index+1}"
  vpc   = ibm_is_vpc.vpc.id
  zone  = "${var.ibm_region}-${count.index+1}"
}

##############################################################################
# Create Subnets
##############################################################################

resource ibm_is_subnet subnet1 {
  name            = "${var.unique_id}-subnet-1"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-1"
  ipv4_cidr_block = element(var.subnet_cidr_blocks, 1)
  public_gateway  = element(ibm_is_public_gateway.gateway.*.id, 1)
  network_acl     = ibm_is_network_acl.multizone_acl.id
  depends_on      = [ibm_is_vpc_address_prefix.prefix1]
}

resource ibm_is_subnet subnet2 {
  name            = "${var.unique_id}-subnet-2"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-2"
  ipv4_cidr_block = element(var.subnet_cidr_blocks, 2)
  public_gateway  = element(ibm_is_public_gateway.gateway.*.id, 2)
  network_acl     = ibm_is_network_acl.multizone_acl.id
  depends_on      = [ibm_is_vpc_address_prefix.prefix2]
}

resource ibm_is_subnet subnet3 {
  name            = "${var.unique_id}-subnet-3"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-3"
  ipv4_cidr_block = element(var.subnet_cidr_blocks, 3)
  public_gateway  = element(ibm_is_public_gateway.gateway.*.id, 3)
  network_acl     = ibm_is_network_acl.multizone_acl.id
  depends_on      = [ibm_is_vpc_address_prefix.prefix3]
}


##############################################################################
