module "etcd" {
  source         = "../../modules/vmware/etcd"
  instance_count = "${var.tectonic_experimental ? 0 : var.tectonic_etcd_count }"

  cluster_name       = "${var.tectonic_cluster_name}"
  core_public_keys   = ["${var.tectonic_vmware_ssh_authorized_key}"]
  container_image    = "${var.tectonic_container_images["etcd"]}"
  base_domain        = "${var.tectonic_base_domain}"
  external_endpoints = ["${compact(var.tectonic_etcd_servers)}"]

  tls_ca_crt_pem     = "${module.bootkube.etcd_ca_crt_pem}"
  tls_server_crt_pem = "${module.bootkube.etcd_server_crt_pem}"
  tls_server_key_pem = "${module.bootkube.etcd_server_key_pem}"
  tls_client_crt_pem = "${module.bootkube.etcd_client_crt_pem}"
  tls_client_key_pem = "${module.bootkube.etcd_client_key_pem}"
  tls_peer_key_pem   = "${module.bootkube.etcd_peer_key_pem}"
  tls_peer_crt_pem   = "${module.bootkube.etcd_peer_crt_pem}"

  hostname   = "${var.tectonic_vmware_etcd_hostnames}"
  dns_server = "${var.tectonic_vmware_node_dns}"
  ip_address = "${var.tectonic_vmware_etcd_ip}"
  gateways   = "${var.tectonic_vmware_etcd_gateways}"

  vmware_datacenters      = "${var.tectonic_vmware_etcd_datacenters}"
  vmware_clusters         = "${var.tectonic_vmware_etcd_clusters}"
  vm_disk_datastores      = "${var.tectonic_vmware_etcd_datastores}"
  vm_network_labels       = "${var.tectonic_vmware_etcd_networks}"
  ntp_sources             = "${var.tectonic_etcd_ntp}"

  vmware_resource_pool    = "${var.tectonic_vmware_etcd_resource_pool}"
  vm_vcpu                 = "${var.tectonic_vmware_etcd_vcpu}"
  vm_memory               = "${var.tectonic_vmware_etcd_memory}"
  vm_disk_template        = "${var.tectonic_vmware_etcd_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${vsphere_folder.tectonic_vsphere_folder.path}"
  http_proxy_enabled      = "${var.tectonic_vmware_httpproxy_enabled}"
  http_proxy              = "${var.tectonic_vmware_httpproxy}"
  https_proxy             = "${var.tectonic_vmware_httpsproxy}"
  no_proxy                = "${var.tectonic_vmware_noproxy}"
  trusted_ca              = "${var.tectonic_trusted_ca}"

}

module "masters" {
  source           = "../../modules/vmware/node"
  instance_count   = "${var.tectonic_master_count}"
  base_domain      = "${var.tectonic_base_domain}"
  core_public_keys = ["${var.tectonic_vmware_ssh_authorized_key}"]
  hostname         = "${var.tectonic_vmware_master_hostnames}"
  dns_server       = "${var.tectonic_vmware_node_dns}"
  ip_address       = "${var.tectonic_vmware_master_ip}"
  gateways         = "${var.tectonic_vmware_master_gateways}"

  kubelet_node_label        = "node-role.kubernetes.io/master"
  kubelet_node_taints       = "node-role.kubernetes.io/master=:NoSchedule"
  kubelet_cni_bin_dir       = "${var.tectonic_calico_network_policy ? "/var/lib/cni/bin" : "" }"
  kube_dns_service_ip       = "${module.bootkube.kube_dns_service_ip}"
  container_images          = "${var.tectonic_container_images}"
  bootkube_service          = "${module.bootkube.systemd_service}"
  tectonic_service          = "${module.tectonic.systemd_service}"
  tectonic_service_disabled = "${var.tectonic_vanilla_k8s}"
  kube_image_url            = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$1")}"
  kube_image_tag            = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$2")}"

  vmware_datacenters      = "${var.tectonic_vmware_master_datacenters}"
  vmware_clusters         = "${var.tectonic_vmware_master_clusters}"
  vm_disk_datastores      = "${var.tectonic_vmware_master_datastores}"
  vm_network_labels       = "${var.tectonic_vmware_master_networks}"
  ntp_sources             = "${var.tectonic_master_ntp}"

  vmware_resource_pool    = "${var.tectonic_vmware_master_resource_pool}"
  vm_vcpu                 = "${var.tectonic_vmware_master_vcpu}"
  vm_memory               = "${var.tectonic_vmware_master_memory}"
  vm_disk_template        = "${var.tectonic_vmware_master_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${vsphere_folder.tectonic_vsphere_folder.path}"
  kubeconfig              = "${module.bootkube.kubeconfig}"
  private_key             = "${var.tectonic_vmware_ssh_private_key_path}"
  image_re                = "${var.tectonic_image_re}"
  http_proxy_enabled      = "${var.tectonic_vmware_httpproxy_enabled}"
  http_proxy              =  "${var.tectonic_vmware_httpproxy}"
  https_proxy             =  "${var.tectonic_vmware_httpsproxy}"
  no_proxy                =  "${var.tectonic_vmware_noproxy}"
  nfs_enabled             = "${var.tectonic_vmware_nfs_enabled}"
  iscsi_enabled           = "${var.tectonic_vmware_iscsi_enabled}"
  trusted_ca              = "${var.tectonic_trusted_ca}"

}

module "workers" {
  source           = "../../modules/vmware/node"
  instance_count   = "${var.tectonic_worker_count}"
  base_domain      = "${var.tectonic_base_domain}"
  core_public_keys = ["${var.tectonic_vmware_ssh_authorized_key}"]
  hostname         = "${var.tectonic_vmware_worker_hostnames}"
  dns_server       = "${var.tectonic_vmware_node_dns}"
  ip_address       = "${var.tectonic_vmware_worker_ip}"
  gateways         = "${var.tectonic_vmware_worker_gateways}"

  kubelet_node_label  = "node-role.kubernetes.io/node"
  kubelet_node_taints = ""
  kubelet_cni_bin_dir = "${var.tectonic_calico_network_policy ? "/var/lib/cni/bin" : "" }"
  kube_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
  container_images    = "${var.tectonic_container_images}"
  bootkube_service    = ""
  tectonic_service    = ""
  kube_image_url      = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$1")}"
  kube_image_tag      = "${replace(var.tectonic_container_images["hyperkube"],var.tectonic_image_re,"$2")}"

  vmware_datacenters      = "${var.tectonic_vmware_worker_datacenters}"
  vmware_clusters         = "${var.tectonic_vmware_worker_clusters}"
  vm_disk_datastores      = "${var.tectonic_vmware_worker_datastores}"
  vm_network_labels       = "${var.tectonic_vmware_worker_networks}"
  ntp_sources             = "${var.tectonic_worker_ntp}"

  vmware_resource_pool    = "${var.tectonic_vmware_worker_resource_pool}"
  vm_vcpu                 = "${var.tectonic_vmware_worker_vcpu}"
  vm_memory               = "${var.tectonic_vmware_worker_memory}"
  vm_disk_template        = "${var.tectonic_vmware_worker_vm_template}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  vmware_folder           = "${vsphere_folder.tectonic_vsphere_folder.path}"
  kubeconfig              = "${module.bootkube.kubeconfig}"
  private_key             = "${var.tectonic_vmware_ssh_private_key_path}"
  image_re                = "${var.tectonic_image_re}"
  http_proxy_enabled      = "${var.tectonic_vmware_httpproxy_enabled}"
  http_proxy              =  "${var.tectonic_vmware_httpproxy}"
  https_proxy             =  "${var.tectonic_vmware_httpsproxy}"
  no_proxy                =  "${var.tectonic_vmware_noproxy}"
  nfs_enabled             = "${var.tectonic_vmware_nfs_enabled}"
  iscsi_enabled           = "${var.tectonic_vmware_iscsi_enabled}"
  trusted_ca              = "${var.tectonic_trusted_ca}"

}
