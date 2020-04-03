resource "null_resource" "monitoring_provisioner" {
  count = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0
  triggers = {
    monitoring_id = libvirt_domain.monitoring_domain.0.id
  }

  connection {
    host     = libvirt_domain.monitoring_domain.0.network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content = <<EOF
name_prefix: ${terraform.workspace}-${var.name}
hostname: ${terraform.workspace}-${var.name}
timezone: ${var.timezone}
network_domain: ${var.network_domain}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ",formatlist("'%s': '%s'",keys(var.reg_additional_modules),values(var.reg_additional_modules),),)}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", [var.monitoring_srv_ip]))}]
host_ip: ${var.monitoring_srv_ip}
role: monitoring
provider: libvirt
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitored_hosts: [${join(", ", formatlist("'%s'", var.monitored_hosts))}]
drbd_monitored_hosts: [${join(", ", formatlist("'%s'", var.drbd_monitored_hosts))}]
nw_monitored_hosts: [${join(", ", formatlist("'%s'", var.nw_monitored_hosts))}]
EOF
  destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.background ? "nohup" : ""} sh /tmp/salt/provision.sh > /tmp/provisioning.log ${var.background ? "&" : ""}",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}
