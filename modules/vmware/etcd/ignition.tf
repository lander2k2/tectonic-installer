data "ignition_config" "etcd" {
  count = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"

  users = [
    "${data.ignition_user.core.id}",
  ]

  files = [
    "${data.ignition_file.node_hostname.*.id[count.index]}",
    "${data.ignition_file.etcd_ca.id}",
    "${data.ignition_file.etcd_server_crt.id}",
    "${data.ignition_file.etcd_server_key.id}",
    "${data.ignition_file.etcd_client_crt.id}",
    "${data.ignition_file.etcd_client_key.id}",
    "${data.ignition_file.etcd_peer_crt.id}",
    "${data.ignition_file.etcd_peer_key.id}",
    "${data.ignition_file.profile_node.id}",
    "${data.ignition_file.profile_systemd.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.locksmithd.*.id[count.index]}",
    "${data.ignition_systemd_unit.etcd3.*.id[count.index]}",
  ]

  networkd = [
    "${data.ignition_networkd_unit.vmnetwork.*.id[count.index]}",
  ]
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}

data "ignition_file" "etcd_ca" {
  path       = "/etc/ssl/etcd/ca.crt"
  mode       = 0644
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.tls_ca_crt_pem}"
  }
}

data "ignition_file" "etcd_client_key" {
  path       = "/etc/ssl/etcd/client.key"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.tls_client_key_pem}"
  }
}

data "ignition_file" "etcd_client_crt" {
  path       = "/etc/ssl/etcd/client.crt"
  mode       = 0400
  uid        = 0
  gid        = 0
  filesystem = "root"

  content {
    content = "${var.tls_client_crt_pem}"
  }
}

data "ignition_file" "etcd_server_key" {
  path       = "/etc/ssl/etcd/server.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.tls_server_key_pem}"
  }
}

data "ignition_file" "etcd_server_crt" {
  path       = "/etc/ssl/etcd/server.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.tls_server_crt_pem}"
  }
}

data "ignition_file" "etcd_peer_key" {
  path       = "/etc/ssl/etcd/peer.key"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.tls_peer_key_pem}"
  }
}

data "ignition_file" "etcd_peer_crt" {
  path       = "/etc/ssl/etcd/peer.crt"
  mode       = 0400
  uid        = 232
  gid        = 232
  filesystem = "root"

  content {
    content = "${var.tls_peer_crt_pem}"
  }
}

data "ignition_systemd_unit" "locksmithd" {
  count = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"

  name   = "locksmithd.service"
  enable = true

  dropin = [
    {
      name    = "40-etcd-lock.conf"
      content = "[Service]\nEnvironment=REBOOT_STRATEGY=etcd-lock\n"
      name    = "40-etcd-lock.conf"

      content = <<EOF
[Service]
Environment=REBOOT_STRATEGY=etcd-lock
Environment=LOCKSMITHD_ETCD_CAFILE=/etc/ssl/etcd/ca.crt
Environment=LOCKSMITHD_ETCD_KEYFILE=/etc/ssl/etcd/client.key
Environment=LOCKSMITHD_ETCD_CERTFILE=/etc/ssl/etcd/client.crt
Environment=LOCKSMITHD_ENDPOINT=https://${var.hostname["${count.index}"]}.${var.base_domain}:2379
EOF
    },
  ]
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

data "template_file" "etcd-cluster" {
  template = "${file("${path.module}/resources/etcd-cluster")}"
  count    = "${var.instance_count}"

  vars = {
    etcd-name    = "${var.hostname["${count.index}"]}"
    etcd-address = "${var.hostname["${count.index}"]}.${var.base_domain}"
  }
}

data "ignition_systemd_unit" "etcd3" {
  count  = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"
  name   = "etcd-member.service"
  enable = true

  dropin = [
    {
      name = "40-etcd-cluster.conf"

      content = <<EOF
[Service]
Environment="ETCD_IMAGE=${var.container_image}"
Environment="RKT_RUN_ARGS=--volume etcd-ssl,kind=host,source=/etc/ssl/etcd \
  --mount volume=etcd-ssl,target=/etc/ssl/etcd"
ExecStart=
ExecStart=/usr/lib/coreos/etcd-wrapper \
--name=${var.hostname["${count.index}"]} \
--initial-cluster="${join("," , data.template_file.etcd-cluster.*.rendered)}" \
--advertise-client-urls=https://${var.hostname["${count.index}"]}.${var.base_domain}:2379 \
--cert-file=/etc/ssl/etcd/server.crt \
--key-file=/etc/ssl/etcd/server.key \
--peer-cert-file=/etc/ssl/etcd/peer.crt \
--peer-key-file=/etc/ssl/etcd/peer.key \
--peer-trusted-ca-file=/etc/ssl/etcd/ca.crt \
--peer-client-cert-auth=true \
--initial-advertise-peer-urls=https://${var.hostname["${count.index}"]}.${var.base_domain}:2380 \
--listen-client-urls=https://0.0.0.0:2379 \
--listen-peer-urls=https://0.0.0.0:2380 
EOF
    },
  ]
}

data "ignition_file" "node_hostname" {
  count      = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"
  path       = "/etc/hostname"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${var.hostname["${count.index}"]}"
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
  Gateway=${var.gateways["${count.index}"]}
  UseDomains=yes
  Domains=${var.base_domain}
EOF
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
  name    = "update_ca.service"

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

