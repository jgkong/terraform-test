######################################################
################# VM Intances ########################
######################################################
resource "ibm_compute_vm_instance" "vm_test" {
    count                       = "${var.vm_count}"
    hostname                    = "${var.PROJECT_NAME}-${var.hostname}-${count.index}"
    domain                      = "${var.domain}"
    datacenter                  = "${var.datacenter}"
    flavor_key_name             = "${var.flavor_key_name}"
    os_reference_code           = "${var.os_reference_code}"
    local_disk                  = "${var.local_disk}"
    private_network_only        = "${var.private_network_only}"
    notes                       = "${var.notes}"
    private_security_group_ids  = ["${ibm_security_group.sg_app_ingress.id}"]
}

######################################################
################# Security Groups ####################
######################################################
resource "ibm_security_group" "sg_app_ingress" {
    name        = "${var.PROJECT_NAME}-${var.hostname}-sg-ingress"
    description = "allow my app traffic"
}

resource "ibm_security_group_rule" "sg_app_ingress_rule" {
    direction         = "ingress"
    ether_type        = "IPv4"
    port_range_min    = "${var.sg_ingress_port_min}"
    port_range_max    = "${var.sg_ingress_port_max}"
    protocol          = "tcp"
    security_group_id = "${ibm_security_group.sg_app_ingress.id}"
}

######################################################
################# Load Balancer ######################
######################################################
resource "ibm_lbaas" "lbaas" {
  name                    = "${var.PROJECT_NAME}-${var.hostname}-lb"
  subnets                 = "${var.lbaas_subnets}"
  protocols = [{
    frontend_protocol     = "${var.lb_frontend_protocol}"
    frontend_port         = "${var.lb_frontend_port}"
    backend_protocol      = "${var.lb_backend_protocol}"
    backend_port          = "${var.lb_backend_port}"
    load_balancing_method = "round_robin"
  }]
}

resource "ibm_lbaas_server_instance_attachment" "lbaas_member_0" {
  private_ip_address = "${ibm_compute_vm_instance.vm_test.0.ipv4_address_private}"
  lbaas_id           = "${ibm_lbaas.lbaas.id}"
}

resource "ibm_lbaas_server_instance_attachment" "lbaas_member_1" {
  private_ip_address = "${ibm_compute_vm_instance.vm_test.1.ipv4_address_private}"
  lbaas_id           = "${ibm_lbaas.lbaas.id}"
}

# count = 1
# resource "ibm_lbaas_server_instance_attachment" "lbaas_member" {
#   private_ip_address = "${ibm_compute_vm_instance.vm_test.ipv4_address_private}"
#   lbaas_id           = "${ibm_lbaas.lbaas.id}"
# }

# count > 1
# resource "ibm_lbaas_server_instance_attachment" "lbaas_member" {
#   private_ip_address = "${ibm_compute_vm_instance.vm_test.*.ipv4_address_private}"
#   lbaas_id           = "${ibm_lbaas.lbaas.id}"
# }
