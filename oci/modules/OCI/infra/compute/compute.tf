variable "app_display_name" {
  default = ""
}

variable "compartment_id" {
description = "Compartment OCID"
default = "adas"
}


variable "vm_availability_domain" {
description = "VM availability domain"
}

variable "vm_display_name" {
description = "VM display name"
}

variable "vm_shape" {
description = "VM shape"
}

variable "vm_primary_vnic_display_name" {
description = "VM primary VNIC display name"
}

variable "vm_ssh_public_key_path" {
description = "VM ssh public key file path"
}

variable "vm_creation_timeout" {
description = "VM creation timeout"
}

variable "vm_app_shape" {
  default = "VM.Standard2.1"
}

variable "oci_subnet_id1" {
  description = "oci_subnet_id"
}

variable "oci_subnet_id3" {
  description = "oci_subnet_id"
}

variable "tenancy_ocid" {
description = "tenancy ocid"
}

data "oci_core_images" "vThuder_image" {
  compartment_id = "${var.tenancy_ocid}"
 }
locals {
  vThunder__image_ocid = "ocid1.image.oc1..aaaaaaaai3isjh6znmwpju7bahjzqek2v3w7l2iipffj4gikyfz752f7avqq"
  }

resource "oci_core_instance" "vthunder_vm" {
  compartment_id = "${var.compartment_id}"
  display_name = "${var.vm_display_name}"
  availability_domain = "${var.vm_availability_domain}"

  source_details {
    source_id = "${local.vThunder__image_ocid}"
    source_type = "image"
  }

  shape = "${var.vm_shape}"

  create_vnic_details {
    subnet_id = "${var.oci_subnet_id1}"
    display_name = "${var.vm_primary_vnic_display_name}"
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = "${file( var.vm_ssh_public_key_path )}"
  }
  timeouts {
    create = "${var.vm_creation_timeout}"
  }
}


##APP SERVER###

resource "oci_core_instance" "app-server" {
  compartment_id = "${var.compartment_id}"
  display_name = "${var.app_display_name}"
  availability_domain = "${var.vm_availability_domain}"

  source_details {
    source_id = "ocid1.image.oc1.iad.aaaaaaaaek6aecdnja3rc6qmimbv4x3cipl5b4mknkxlp4xqpmjbbv43dloa"
    source_type = "image"
  }

  shape = "${var.vm_app_shape}"

  create_vnic_details {
    subnet_id = "${var.oci_subnet_id3}"
    assign_public_ip = false  }
  metadata {
    ssh_authorized_keys = "${file( var.vm_ssh_public_key_path )}"
    user_data = "${base64encode(file("user_data.sh"))}"

  }
  timeouts {
    create = "${var.vm_creation_timeout}"
  }
}

output "ip" {value = "${oci_core_instance.vthunder_vm.*.public_ip}"}
output "backend_server_ip" {value = "${element(oci_core_instance.app-server.*.private_ip,0)}"}

output "instance_id" { value = "${oci_core_instance.vthunder_vm.id}" }
