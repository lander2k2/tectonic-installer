data "ignition_config" "node" {
  count = "${var.instance_count}"

  users = [
    "${data.ignition_user.core.id}",
  ]

  files = [
    "${var.ign_max_user_watches_id}",
    "${data.ignition_file.node_hostname.*.id[count.index]}",
    "${var.ign_installer_kubelet_env_id}",
    "${data.ignition_file.profile_node.id}",
    "${data.ignition_file.profile_systemd.id}",
    "${data.ignition_file.nfs_node.id}",
  ]

  systemd = ["${compact(list(
    var.ign_docker_dropin_id,
    var.ign_locksmithd_service_id,
    var.ign_k8s_node_bootstrap_service_id,
    var.ign_kubelet_service_id,
    var.ign_bootkube_service_id,
    var.ign_tectonic_service_id,
    var.ign_bootkube_path_unit_id,
    var.ign_tectonic_path_unit_id,
    var.ign_rpc_statd_service_id,
   ))}"]

  networkd = [
    "${data.ignition_networkd_unit.vmnetwork.*.id[count.index]}",
  ]
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}

data "ignition_file" "max-user-watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = 0644

  content {
    content = "fs.inotify.max_user_watches=16184"
  }
}

data "ignition_systemd_unit" "vmtoolsd_member" {
  name   = "vmtoolsd.service"
  enable = true

  content = <<EOF
  [Unit]
  Description=VMware Tools Agent
  Documentation=http://open-vm-tools.sourceforge.net/
  ConditionVirtualization=vmware
  [Service]
  ExecStartPre=/usr/bin/ln -sfT /usr/share/oem/vmware-tools /etc/vmware-tools
  ExecStart=/usr/share/oem/bin/vmtoolsd
  TimeoutStopSec=5
EOF
}

data "ignition_file" "profile_node" {
  count      = "${var.http_proxy_enabled ? 1 : 0}"
  path       = "/etc/profile.env"
  mode       = 0644
  filesystem = "root"

  content {
    content = <<EOF
export HTTP_PROXY=${var.http_proxy}
export HTTPS_PROXY=${var.https_proxy}
export NO_PROXY=${var.no_proxy}
export http_proxy=${var.http_proxy}
export https_proxy=${var.https_proxy}
export no_proxy=${var.no_proxy}
EOF
  }
}

data "ignition_file" "profile_systemd" {
  count      = "${var.http_proxy_enabled ? 1 : 0}"
  path       = "/etc/systemd/system.conf.d/10-default-env.conf"
  mode       = 0644
  filesystem = "root"

  content {
    content = <<EOF
[Manager]
DefaultEnvironment=HTTP_PROXY=${var.http_proxy}
DefaultEnvironment=HTTPS_PROXY=${var.https_proxy}
DefaultEnvironment=NO_PROXY=${var.no_proxy}
DefaultEnvironment=http_proxy=${var.http_proxy}
DefaultEnvironment=https_proxy=${var.https_proxy}
DefaultEnvironment=no_proxy=${var.no_proxy}
EOF
  }
}

data "ignition_file" "nfs_node" {
  count      = "${var.nfs_enabled ? 1 : 0}"
  path       = "/etc/conf.d/nfs"
  mode       = 0644
  filesystem = "root"

  content {
    content = <<EOF
OPTS_RPC_MOUNTD=""
EOF
  }
}

data "ignition_networkd_unit" "vmnetwork" {
  count = "${var.instance_count}"
  name  = "00-ens192.network"

  content = <<EOF
  [Match]
  Name=ens192
  [Network]
  DNS=${var.dns_server}
  Address=${var.ip_address["${count.index}"]}
  Gateway=${var.gateway}
  UseDomains=yes
  Domains=${var.base_domain}
EOF
}

data "ignition_file" "node_hostname" {
  count      = "${var.instance_count}"
  path       = "/etc/hostname"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${var.hostname["${count.index}"]}"
  }
}
