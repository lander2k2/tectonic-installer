provider "vsphere" {
  version              = "0.4.2"
  vsphere_server       = "${var.tectonic_vmware_server}"
  allow_unverified_ssl = "${var.tectonic_vmware_sslselfsigned}"
}

data "vsphere_datacenter" "dc" {
  name = "${var.tectonic_vmware_worker_datacenters[0]}"
}

resource "vsphere_folder" "tectonic_vsphere_folder" {
  path          = "${var.tectonic_vmware_folder}"
  type          = "${var.tectonic_vmware_type}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
