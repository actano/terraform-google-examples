

provider "google" {
  credentials = "${file("/Users/petercaron/keys/rplan-enterprise-9ff48e745334.json")}"
  project     = "rplan-enterprise"
  region      = "europe-west1"
#  region = "${var.region}"
}

data "google_project" "current" {}

data "google_compute_default_service_account" "default" {}

resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "${var.network_cidr}"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
}

#resource "google_compute_instance" "default" {
#  count                     = "${var.num_nodes}"
#  name                      = "${var.name}-${count.index + 1}"
#  zone                      = "${var.zone}"
#  tags                      = ["${concat(list("${var.name}-ssh", "${var.name}"), var.node_tags)}"]
#  machine_type              = "${var.machine_type}"
#  min_cpu_platform          = "${var.min_cpu_platform}"
#  allow_stopping_for_update = true

#  boot_disk {
#    auto_delete = "${var.disk_auto_delete}"

#    initialize_params {
#      image = "${var.image_project}/${var.image_family}"
#      size  = "${var.disk_size_gb}"
#      type  = "${var.disk_type}"
#    }
#  }



resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "n1-standard-1"
  zone         = "europe-west1-d"

  tags = ["rplan", "enterprise"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    version = "enterprise"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
