
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "null_resource" "create-demo-fms-apps-list" {
  provisioner "local-exec" {
    command = "aws fms put-apps-list --apps-list 'ListName=${local.fms-list-name},AppsList=[{AppName=MySQL,Protocol=TCP,Port=3306}]'"
  }
}

resource "null_resource" "output-id" {
  provisioner "local-exec" {
    command = "aws fms list-apps-lists --max-results 5 | jq '.AppsLists[] | select(.ListName == \"${local.fms-list-name}\") | .ListId' > ${data.template_file.apps-list-id.rendered}"
  }
  depends_on = [null_resource.create-demo-fms-apps-list]
}

resource "null_resource" "delete-demo-fms-apps-list" {
  count = "${var.delete != "false" ? 1 :0}"
  provisioner "local-exec" {
    command = "aws fms delete-apps-list --list-id ${trimspace(data.local_file.readId.content)}"
  }
  depends_on = [null_resource.create-demo-fms-apps-list]
}

data "template_file" "apps-list-id" {
  template = "${path.module}/id.log"
}

data "local_file" "readId" {
  filename = "${data.template_file.apps-list-id.rendered}"
  depends_on = [null_resource.output-id]
}

locals {
  fms-list-name = "DJL DEMO"
  delete = "true"
}