// Install CoreOS to disk
resource "matchbox_group" "coreos-install" {
  count   = "${length(var.tectonic_metal_controller_names) + length(var.tectonic_metal_worker_names)}"
  name    = "${format("coreos-install-%s", element(concat(var.tectonic_metal_controller_names, var.tectonic_metal_worker_names), count.index))}"
  profile = "${matchbox_profile.coreos-install.name}"

  selector {
    mac = "${element(concat(var.tectonic_metal_controller_macs, var.tectonic_metal_worker_macs), count.index)}"
  }

  metadata {
    coreos_channel     = "${var.tectonic_cl_channel}"
    coreos_version     = "${var.tectonic_metal_cl_version}"
    ignition_endpoint  = "${var.tectonic_metal_matchbox_http_endpoint}/ignition"
    baseurl            = "${var.tectonic_metal_matchbox_http_endpoint}/assets/coreos"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"
  }
}

// DO NOT PLACE SECRETS IN USER-DATA

resource "matchbox_group" "controller" {
  count   = "${length(var.tectonic_metal_controller_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_controller_names, count.index))}"
  profile = "${matchbox_profile.tectonic-controller.name}"

  selector {
    mac = "${element(var.tectonic_metal_controller_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name          = "${element(var.tectonic_metal_controller_domains, count.index)}"
    etcd_name            = "${element(var.tectonic_metal_controller_names, count.index)}"
    etcd_initial_cluster = "${join(",", formatlist("%s=http://%s:2380", var.tectonic_metal_controller_names, var.tectonic_metal_controller_domains))}"
    k8s_dns_service_ip   = "${var.tectonic_kube_dns_service_ip}"
    ssh_authorized_key   = "${var.tectonic_ssh_authorized_key}"
  }
}

resource "matchbox_group" "worker" {
  count   = "${length(var.tectonic_metal_worker_names)}"
  name    = "${format("%s-%s", var.tectonic_cluster_name, element(var.tectonic_metal_worker_names, count.index))}"
  profile = "${matchbox_profile.tectonic-worker.name}"

  selector {
    mac = "${element(var.tectonic_metal_worker_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name        = "${element(var.tectonic_metal_worker_domains, count.index)}"
    etcd_endpoints     = "${join(",", formatlist("%s:2379", var.tectonic_metal_controller_domains))}"
    k8s_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
    ssh_authorized_key = "${var.tectonic_ssh_authorized_key}"
  }
}
