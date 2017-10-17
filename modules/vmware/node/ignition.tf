data "ignition_config" "node" {
  count = "${var.instance_count}"

  users = [
    "${data.ignition_user.core.id}",
  ]

  files = [
    "${data.ignition_file.max-user-watches.id}",
    "${data.ignition_file.node_hostname.*.id[count.index]}",
    "${data.ignition_file.kubelet-env.id}",
    "${data.ignition_file.profile_node.id}",
    "${data.ignition_file.profile_systemd.id}",
    "${data.ignition_file.nfs_node.id}",
    "${data.ignition_file.iscsi_node.id}",
    "${data.ignition_file.trusted_ca.id}",
    "${data.ignition_file.ntp_conf.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.kubelet.*.id[count.index]}",
    "${data.ignition_systemd_unit.kubelet-env.id}",
    "${data.ignition_systemd_unit.bootkube.id}",
    "${data.ignition_systemd_unit.tectonic.id}",
    "${data.ignition_systemd_unit.rpc-statd.id}",
    "${data.ignition_systemd_unit.iscsid.id}",
    "${data.ignition_systemd_unit.update_ca.id}",
  ]

  networkd = [
    "${data.ignition_networkd_unit.vmnetwork.*.id[count.index]}",
  ]
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}

data "ignition_systemd_unit" "docker" {
  name   = "docker.service"
  enable = true

  dropin = [
    {
      name    = "10-dockeropts.conf"
      content = "[Service]\nEnvironment=\"DOCKER_OPTS=--log-opt max-size=50m --log-opt max-file=3\"\n"
    },
  ]
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "ignition_systemd_unit" "kubelet" {
  count   = "${var.instance_count}"
  name    = "kubelet.service"
  enable  = true

  content = <<EOF
  [Unit]
  Description=Kubelet via Hyperkube ACI

  [Service]
  EnvironmentFile=/etc/kubernetes/kubelet.env
  Environment="RKT_RUN_ARGS=--uuid-file-save=/var/cache/kubelet-pod.uuid \
		  --volume=resolv,kind=host,source=/etc/resolv.conf \
		  --mount volume=resolv,target=/etc/resolv.conf \
		  --volume var-lib-cni,kind=host,source=/var/lib/cni \
		  --mount volume=var-lib-cni,target=/var/lib/cni \
		  --volume var-log,kind=host,source=/var/log \
		  --mount volume=var-log,target=/var/log"

  ExecStartPre=/bin/mkdir -p /etc/kubernetes/manifests \
		  /srv/kubernetes/manifests /etc/kubernetes/checkpoint-secrets \
		  /etc/kubernetes/cni/net.d /var/lib/cni
  ExecStartPre=/usr/bin/bash -c "grep 'certificate-authority-data' /etc/kubernetes/kubeconfig | awk '{print $2}' | base64 -d > /etc/kubernetes/ca.crt"
  ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/cache/kubelet-pod.uuid

  ExecStart=/usr/lib/coreos/kubelet-wrapper \
		  --kubeconfig=/etc/kubernetes/kubeconfig \
		  --require-kubeconfig \
		  --cni-conf-dir=/etc/kubernetes/cni/net.d \
		  --network-plugin=cni \
		  --lock-file=/var/run/lock/kubelet.lock \
		  --exit-on-lock-contention \
		  --pod-manifest-path=/etc/kubernetes/manifests \
		  --allow-privileged \
		  --node-labels=${var.kubelet_node_label},failure-domain.beta.kubernetes.io/region=${var.node_regions["${count.index}"]},failure-domain.beta.kubernetes.io/zone=${var.node_zones["${count.index}"]} \
		  ${var.kubelet_node_taints != "" ? "--register-with-taints=${var.kubelet_node_taints}" : ""} \
		  ${var.kubelet_cni_bin_dir != "" ? "--cni-bin-dir=${var.kubelet_cni_bin_dir}" : ""} \
		  --minimum-container-ttl-duration=6m0s \
		  --cluster-dns=${var.kube_dns_service_ip} \
		  --cluster-domain=cluster.local \
		  --client-ca-file=/etc/kubernetes/ca.crt \
		  --anonymous-auth=false
  ExecStop=-/usr/bin/rkt stop --uuid-file=/var/cache/kubelet-pod.uuid

  Restart=always
  RestartSec=10

  [Install]
  WantedBy=multi-user.target
  ${var.nfs_enabled ? "Wants=rpc-statd.service" : ""}
EOF
}

data "template_file" "kubelet-env" {
  template = "${file("${path.module}/resources/services/kubelet-env.service")}"

  vars {
    kube_version_image_url = "${replace(var.container_images["kube_version"],var.image_re,"$1")}"
    kube_version_image_tag = "${replace(var.container_images["kube_version"],var.image_re,"$2")}"
    kubelet_image_url      = "${replace(var.container_images["hyperkube"],var.image_re,"$1")}"
  }
}

data "ignition_systemd_unit" "kubelet-env" {
  name    = "kubelet-env.service"
  enable  = true
  content = "${data.template_file.kubelet-env.rendered}"
}

data "ignition_file" "max-user-watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = 0644

  content {
    content = "fs.inotify.max_user_watches=16184"
  }
}

data "ignition_systemd_unit" "bootkube" {
  name    = "bootkube.service"
  content = "${var.bootkube_service}"
}

data "ignition_systemd_unit" "tectonic" {
  name    = "tectonic.service"
  enable  = "${var.tectonic_service_disabled == 0 ? true : false}"
  content = "${var.tectonic_service}"
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

data "ignition_systemd_unit" "rpc-statd" {
  name   = "rpc-statd.service"
  enable = "${var.nfs_enabled ? true : false}"

  content = <<EOF
  [Unit]
  Description=NFS status monitor for NFSv2/3 locking.
  DefaultDependencies=no
  Conflicts=umount.target
  Requires=nss-lookup.target rpcbind.target
  After=network.target nss-lookup.target rpcbind.target
  PartOf=nfs-utils.service

  [Service]
  Type=forking
  PIDFile=/var/run/rpc.statd.pid
  ExecStart=/sbin/rpc.statd --no-notify $STATDARGS

  [Install]
  WantedBy=multi-user.target
EOF
}

data "ignition_file" "iscsi_node" {
  count      = "${var.iscsi_enabled ? 1 : 0}"
  path       = "/etc/iscsi/iscsid.conf"
  mode       = 0644
  filesystem = "root"

  content {
    content = <<EOF

EOF
  }
}

data "ignition_systemd_unit" "iscsid" {
  name   = "iscsid.service"
  enable = "${var.iscsi_enabled ? true : false}"
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
  Gateway=${var.gateways["${count.index}"]}
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

data "ignition_file" "kubelet-env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = 0644

  content {
    content = <<EOF
KUBELET_IMAGE_URL="${var.kube_image_url}"
KUBELET_IMAGE_TAG="${var.kube_image_tag}"
EOF
  }
}

data "ignition_file" "trusted_ca" {
  path       = "/etc/ssl/certs/Local_Trusted.pem"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${file(var.trusted_ca)}"
  }
}

data "ignition_systemd_unit" "update_ca" {
  name   = "update_ca.service"
  enable = true

  content = <<EOF
  [Unit]
  Description=Run script to update the system bundle of Certificate Authorities

  [Service]
  Type=oneshot
  ExecStart=/usr/sbin/update-ca-certificates

  [Install]
  WantedBy=multi-user.target
EOF
}

data "ignition_file" "ntp_conf" {
  count      = "${length(keys(var.ntp_sources)) > 0 ? 1 : 0}"
  path       = "/etc/systemd/timesyncd.conf"
  mode       = 0644
  filesystem = "root"

  content {
    content = <<EOF
[Time]
NTP=${var.ntp_sources["${count.index}"]}
EOF
  }
}
