// # VMware Connectivity

variable "tectonic_vmware_vm_template_folder" {
  type        = "string"
  description = "Folder for VM template of CoreOS Container Linux."
}

variable "tectonic_vmware_server" {
  type        = "string"
  description = "vCenter Server IP/FQDN"
}

variable "tectonic_vmware_sslselfsigned" {
  type        = "string"
  description = "Is the vCenter certificate Self-Signed? Example: `tectonic_vmware_sslselfsigned = \"true\"` "
}

variable "tectonic_vmware_folder" {
  type        = "string"
  description = "vSphere Folder to create and add the Tectonic nodes"
}

//variable "tectonic_vmware_resource_pool" {
//  type        = "string"
//  description = "(optional) The name of a Resource Pool in which to launch the virtual machine. Requires full path. Full path can be obtained by executing `govc pool.info $ResourcePoolName`"
//  default     = ""
//}

// # Global

variable "tectonic_vmware_ssh_authorized_key" {
  type        = "string"
  description = "SSH public key to use as an authorized key. Example: `\"ssh-rsa AAAB3N...\"`"
}

variable "tectonic_vmware_ssh_private_key_path" {
  type        = "string"
  description = "SSH private key file in .pem format corresponding to tectonic_vmware_ssh_authorized_key. If not provided, SSH agent will be used."
  default     = ""
}

variable "tectonic_vmware_node_dns" {
  type        = "string"
  description = "DNS Server to be used by Virtual Machine(s). Multiple DNS servers can be separated by whitespace. Example: `\"192.168.1.1 192.168.2.1\"`"
}

variable "tectonic_vmware_controller_domain" {
  type        = "string"
  description = "The domain name which resolves to controller node(s)"
}

variable "tectonic_vmware_ingress_domain" {
  type        = "string"
  description = "The domain name which resolves to Tectonic Ingress (i.e. worker node(s))"
}

// # Node Settings

// ## ETCD

variable "tectonic_vmware_etcd_vcpu" {
  type        = "string"
  default     = "1"
  description = "etcd node(s) VM vCPU count"
}

variable "tectonic_vmware_etcd_memory" {
  type        = "string"
  default     = "4096"
  description = "etcd node(s) VM Memory Size in MB"
}

variable "tectonic_vmware_etcd_vm_template" {
  type        = "string"
  description = "Virtual Machine template of CoreOS Container Linux for etcd node(s)."
}

variable "tectonic_vmware_etcd_hostnames" {
  type = "map"

  description = <<EOF
  terraform map of etcd node(s) hostnames, example: 
  tectonic_vmware_etcd_hostnames = {
  "0" = "mycluster-etcd-0"
  "1" = "mycluster-etcd-1"
  "2" = "mycluster-etcd-2"
}
EOF
}

variable "tectonic_vmware_etcd_datacenters" {
  type = "map"

  description = <<EOF
  terraform map of etcd node(s) Virtual DataCenters, example:
  tectonic_vmware_etcd_datacenters = {
  "0" = "myvmwaredc-0"
  "1" = "myvmwaredc-1"
  "2" = "myvmwaredc-2"
}
EOF
}

variable "tectonic_vmware_etcd_clusters" {
  type = "map"

  description = <<EOF
  terraform map of etcd node(s) vSphere Clusters, example:
  tectonic_vmware_etcd_clusters = {
  "0" = "myvmwarecluster-0"
  "1" = "myvmwarecluster-1"
  "2" = "myvmwarecluster-2"
}
EOF
}

variable "tectonic_vmware_etcd_resource_pool" {
  type = "map"

  description = <<EOF
  terraform map of etcd node(s) vSphere Resource Pools, example:
  tectonic_vmware_etcd_resource_pool = {
  "0" = "myresourcepool-1"
  "1" = "myresourcepool-2"
  "2" = "myresourcepool-3"
}
EOF
}

variable "tectonic_vmware_etcd_datastores" {
  type = "map"

  description = <<EOF
  terraform map of etcd node(s) vSphere Datastores, example:
  tectonic_vmware_etcd_datastores = {
  "0" = "myvmwareds-0"
  "1" = "myvmwareds-1"
  "2" = "myvmwareds-2"
}
EOF
}

variable "tectonic_vmware_etcd_gateways" {
  type = "map"

  description = <<EOF
  terraform map of etcd node(s) network gateway IP, example:
  tectonic_vmware_etcd_gateways = {
  "0" = "192.168.246.99/24"
  "1" = "192.168.246.99/24"
  "2" = "192.168.246.99/24"
}
EOF
}

variable "tectonic_vmware_etcd_ip" {
  type = "map"

  description = <<EOF
  Terraform map of etcd node(s) IP Addresses, Example:
  tectonic_vmware_etcd_ip = {
  "0" = "192.168.246.10/24"
  "1" = "192.168.246.11/24"
  "2" = "192.168.246.12/24"
}
EOF
}

variable "tectonic_vmware_etcd_networks" {
  type = "map"

  description = <<EOF
  Terraform map of etcd node(s) vSphere network portgroups, Example:
  tectonic_vmware_etcd_ip = {
  "0" = "mynet-0"
  "1" = "mynet-1"
  "2" = "mynet-2"
}
EOF
}

variable "tectonic_etcd_ntp" {
  type = "map"

  description = <<EOF
  Terraform map of etcd node(s) NTP sources, Example:
  tectonic_vmware_etcd_ip = {
  "0" = "my.ntp.com"
  "1" = "my.ntp.com"
  "2" = "my.ntp.com"
}
EOF
}

// ## Masters

variable "tectonic_vmware_master_vcpu" {
  type        = "string"
  default     = "1"
  description = "Master node(s) vCPU count"
}

variable "tectonic_vmware_master_memory" {
  type        = "string"
  default     = "4096"
  description = "Master node(s) Memory Size in MB"
}

variable "tectonic_vmware_master_vm_template" {
  type        = "string"
  description = "Virtual Machine template of CoreOS Container Linux for master node(s)."
}

variable "tectonic_vmware_master_hostnames" {
  type = "map"

  description = <<EOF
  Terraform map of Master node(s) Hostnames, Example:
  tectonic_vmware_master_hostnames = {
  "0" = "mycluster-master-0"
  "1" = "mycluster-master-1"
}
EOF
}

variable "tectonic_vmware_master_datacenters" {
  type = "map"

  description = <<EOF
  terraform map of master node(s) Virtual DataCenters, example:
  tectonic_vmware_master_datacenters = {
  "0" = "myvmwaredc-0"
  "1" = "myvmwaredc-1"
  "2" = "myvmwaredc-2"
}
EOF
}

variable "tectonic_vmware_master_clusters" {
  type = "map"

  description = <<EOF
  terraform map of master node(s) vSphere Clusters, example:
  tectonic_vmware_master_clusters = {
  "0" = "myvmwarecluster-0"
  "1" = "myvmwarecluster-1"
  "2" = "myvmwarecluster-2"
}
EOF
}

variable "tectonic_vmware_master_resource_pool" {
  type = "map"

  description = <<EOF
  terraform map of master node(s) vSphere Resource pools, example:
  tectonic_vmware_master_resource_pool = {
  "0" = "myresourcepool-0"
  "1" = "myresourcepool-1"
  "2" = "myresourcepool-2"
}
EOF
}

variable "tectonic_vmware_master_datastores" {
  type = "map"

  description = <<EOF
  terraform map of master node(s) vSphere Datastores, example:
  tectonic_vmware_master_datastores = {
  "0" = "myvmwareds-0"
  "1" = "myvmwareds-1"
  "2" = "myvmwareds-2"
}
EOF
}

variable "tectonic_vmware_master_gateways" {
  type = "map"

  description = <<EOF
  terraform map of master node(s) network gateway IP, example:
  tectonic_vmware_master_gateways = {
  "0" = "192.168.246.99/24"
  "1" = "192.168.246.99/24"
  "2" = "192.168.246.99/24"
}
EOF
}

variable "tectonic_vmware_master_ip" {
  type = "map"

  description = <<EOF
  Terraform map of Master node(s) IP Addresses, Example: 
  tectonic_vmware_master_ip = {
  "0" = "192.168.246.20/24"
  "1" = "192.168.246.21/24"
}
EOF
}

variable "tectonic_vmware_master_networks" {
  type = "map"

  description = <<EOF
  Terraform map of master node(s) vSphere network portgroups, Example:
  tectonic_vmware_master_ip = {
  "0" = "mynet-0"
  "1" = "mynet-1"
}
EOF
}

variable "tectonic_master_ntp" {
  type = "map"

  description = <<EOF
  Terraform map of master node(s) NTP time sources, Example:
  tectonic_vmware_master_ip = {
  "0" = "my.ntp.com"
  "1" = "my.ntp.com"
}
EOF
}

// ## Workers

variable "tectonic_vmware_worker_vcpu" {
  type        = "string"
  default     = "1"
  description = "Worker node(s) vCPU count"
}

variable "tectonic_vmware_worker_memory" {
  type        = "string"
  default     = "4096"
  description = "Worker node(s) Memory Size in MB"
}

variable "tectonic_vmware_worker_vm_template" {
  type        = "string"
  description = "Virtual Machine template of CoreOS Container Linux for worker node(s)."
}

variable "tectonic_vmware_worker_hostnames" {
  type = "map"

  description = <<EOF
  Terraform map of Worker node(s) Hostnames, Example: 
  tectonic_vmware_worker_hostnames = {
  "0" = "mycluster-worker-0"
  "1" = "mycluster-worker-1"
}
EOF
}

variable "tectonic_vmware_worker_datacenters" {
  type = "map"

  description = <<EOF
  terraform map of worker node(s) Virtual DataCenters, example:
  tectonic_vmware_worker_datacenters = {
  "0" = "myvmwaredc-0"
  "1" = "myvmwaredc-1"
}
EOF
}

variable "tectonic_vmware_worker_clusters" {
  type = "map"

  description = <<EOF
  terraform map of worker node(s) vSphere Clusters, example:
  tectonic_vmware_worker_clusters = {
  "0" = "myvmwarecluster-0"
  "1" = "myvmwarecluster-1"
}
EOF
}

variable "tectonic_vmware_worker_resource_pool" {
  type = "map"

  description = <<EOF
  terraform map of worker node(s) vSphere Resource Pools, example:
  tectonic_vmware_worker_resource_pool = {
  "0" = "myresourcepool-0"
  "1" = "myresourcepool-1"
}
EOF
}

variable "tectonic_vmware_worker_datastores" {
  type = "map"

  description = <<EOF
  terraform map of worker node(s) vSphere Datastores, example:
  tectonic_vmware_worker_datastores = {
  "0" = "myvmwareds-0"
  "1" = "myvmwareds-1"
}
EOF
}

variable "tectonic_vmware_worker_gateways" {
  type = "map"

  description = <<EOF
  terraform map of worker node(s) network gateway IP, example:
  tectonic_vmware_worker_gateways = {
  "0" = "192.168.246.99/24"
  "1" = "192.168.246.99/24"
}
EOF
}

variable "tectonic_vmware_worker_ip" {
  type = "map"

  description = <<EOF
  Terraform map of Worker node(s) IP Addresses, Example: 
  tectonic_vmware_worker_ip = {
  "0" = "192.168.246.30/24"
  "1" = "192.168.246.31/24"
}
EOF
}

variable "tectonic_vmware_worker_networks" {
  type = "map"

  description = <<EOF
  Terraform map of worker node(s) vSphere network portgroups, Example:
  tectonic_vmware_worker_ip = {
  "0" = "mynet-0"
  "1" = "mynet-1"
}
EOF
}

variable "tectonic_worker_ntp" {
  type = "map"

  description = <<EOF
  Terraform map of worker node(s) NTP time sources, Example:
  tectonic_vmware_worker_ip = {
  "0" = "my.ntp.com"
  "1" = "my.ntp.com"
}
EOF
}

variable "tectonic_vmware_httpproxy_enabled" {
  type        = "string"
  default     = "false"
  description = "switch to configure hosts to use outbound http proxy"
}

variable "tectonic_vmware_httpproxy" {
  type        = "string"
  description = "http_proxy variable for Nodes"
}

variable "tectonic_vmware_httpsproxy" {
  type        = "string"
  description = "https_proxy variable for Nodes"
}

variable "tectonic_vmware_noproxy" {
  type        = "string"
  description = "no_proxy variable for Nodes"
}

variable "tectonic_vmware_nfs_enabled" {
  type        = "string"
  default     = "false"
  description = "enable NFS mount"
}

variable "tectonic_vmware_iscsi_enabled" {
  type        = "string"
  default     = "false"
  description = "enable iSCSI connections"
}

variable "tectonic_trusted_ca" {
  type        = "string"
  description = "Path to CA to add to trusted CAs on cluster nodes"
}
