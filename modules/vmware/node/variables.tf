variable "instance_count" {
  type        = "string"
  description = "Number of nodes to be created."
}

variable "base_domain" {
  type = "string"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"
}

variable "kube_dns_service_ip" {
  type        = "string"
  description = "Service IP used to reach kube-dns"
}

variable "kubelet_node_label" {
  type        = "string"
  description = "Label that Kubelet will apply on the node"
}

variable "kubelet_node_taints" {
  type        = "string"
  description = "Taints that Kubelet will apply on the node"
}

variable "kubelet_cni_bin_dir" {
  type = "string"
}

variable "bootkube_service" {
  type        = "string"
  description = "The content of the bootkube systemd service unit"
}

variable "tectonic_service" {
  type        = "string"
  description = "The content of the tectonic installer systemd service unit"
}

variable "tectonic_service_disabled" {
  description = "Specifies whether the tectonic installer systemd unit will be disabled. If true, no tectonic assets will be deployed"
  default     = false
}

variable dns_server {
  type        = "string"
  description = "DNS Server of the nodes"
}

variable ip_address {
  type        = "map"
  description = "IP Address of the node"
}

variable gateways {
  type        = "map"
  description = "Network gateway IP for the node"
}

variable hostname {
  type        = "map"
  description = "Hostname of the node"
}

variable core_public_keys {
  type        = "list"
  description = "Public Key for Core User"
}

variable vmware_datacenters {
  type        = "map"
  description = "vSphere Datacenter to create VMs in"
}

variable vmware_clusters {
  type        = "map"
  description = "vSphere Cluster to create VMs in"
}

variable vm_disk_datastores {
  type        = "map"
  description = "vSphere Datastore to use for VMs"
}

variable vmware_resource_pool {
  type        = "map"
  description = "vSphere resource pool to create VMs in"
}

variable vm_vcpu {
  type        = "string"
  description = "VMs vCPU count"
}

variable vm_memory {
  type        = "string"
  description = "VMs Memory size in MB"
}

variable vm_network_labels {
  type        = "map"
  description = "VMs PortGroups"
}

variable vm_disk_template {
  type        = "string"
  description = "Disk template to use for cloning CoreOS Container Linux"
}

variable vm_disk_template_folder {
  type        = "string"
  description = "vSphere Folder CoreOS Container Linux is located in"
}

variable "vmware_folder" {
  type        = "string"
  description = "Name of the VMware folder to create objects in"
}

variable "kube_image_url" {
  type = "string"
}

variable "kube_image_tag" {
  type = "string"
}

variable "kubeconfig" {
  type        = "string"
  description = "Contents of Kubeconfig"
}

variable "private_key" {
  type        = "string"
  description = "SSH private key file in .pem format corresponding to tectonic_vmware_ssh_authorized_key. If not provided, SSH agent will be used."
  default     = ""
}

variable "image_re" {
  description = <<EOF
(internal) Regular expression used to extract repo and tag components from image strings
EOF

  type = "string"
}

variable "tectonic_vmware_worker_vcpu" {
  type        = "string"
  default     = "1"
  description = "Worker node(s) vCPU count"
}

variable "http_proxy_enabled" {
  type        = "string"
  description = "switch to configure hosts to use outbound http proxy"
}

variable "http_proxy" {
  type        = "string"
  description = "http_proxy variable for Nodes"
}

variable "https_proxy" {
  type        = "string"
  description = "https_proxy variable for Nodes"
}

variable "no_proxy" {
  type        = "string"
  description = "no_proxy variable for Nodes"
}

variable "nfs_enabled" {
  type        = "string"
  description = "NFS mount enabled"
}

variable "iscsi_enabled" {
  type        = "string"
  description = "iSCSI connections enabled"
}

variable "trusted_ca" {
  type        = "string"
  description = "Path to CA to add to trusted CAs on cluster nodes"
}

variable "ntp_sources" {
  type        = "map"
  description = "NTP sources for the node"
}

variable "node_regions" {
  type        = "map"
  description = "Regions used for failure-domain node label"
}

variable "node_zones" {
  type        = "map"
  description = "Zones used for failure-domain node label"
}
