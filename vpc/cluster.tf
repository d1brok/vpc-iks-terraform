##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource ibm_container_vpc_cluster cluster {

  name               = var.cluster_name
  vpc_id             = ibm_is_vpc.vpc.id
  flavor             = var.machine_type
  worker_count       = var.worker_count
  resource_group_id  = data.ibm_resource_group.resource_group.id
  kube_version       = "1.18.9"
  # Lets Terraform start working with the cluster as soon as a node is available
  wait_till          = "OneWorkerNodeReady"

  zones {
    subnet_id = ibm_is_subnet.subnet.1.id
    name      = "${var.ibm_region}-1"
  }
  zones {
    subnet_id = ibm_is_subnet.subnet.2.id
    name      = "${var.ibm_region}-2"
  }
  zones {
    subnet_id = ibm_is_subnet.subnet.3.id
     name      = "${var.ibm_region}-3"
  }

  disable_public_service_endpoint = var.disable_pse
}

##############################################################################


##############################################################################
# Enable Private ALBs, disable public
##############################################################################

resource ibm_container_vpc_alb alb {
  count  = "6"

  alb_id = element(ibm_container_vpc_cluster.cluster.albs.*.id, count.index)
  enable = "${
    var.enable_albs && !var.only_private_albs
    ? true
    : var.only_private_albs && element(ibm_container_vpc_cluster.cluster.albs.*.alb_type, count.index) != "public"
      ? true
      : false
  }"
}

##############################################################################
