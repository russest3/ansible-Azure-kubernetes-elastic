variable "rg" {
  type    = string
  default = "test"
}

variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West US2"
}

variable "vmname" {
  type    = string
  default = "c1-cp1"
}

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "admin_name" {
  type    = string
  default = ""
}

variable "admin_pw" {
  type    = string
  default = ""
  sensitive = false
}

variable "env" {
  type    = string
  default = "test"
}

variable "bh_name" {
  type    = string
  default = "bh"
}

variable "workernode1_name" {
  type    = string
  default = "c1-node1"
}

variable "workernode2_name" {
  type    = string
  default = "c1-node2"
}

variable "workernode3_name" {
  type    = string
  default = "c1-node3"
}

variable "jumpbox_name" {
  type    = string
  default = "jumpbox"
}

variable "service_account_pub_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXE1PRXznqKzuWfFYcFDs8wMpewMcYcor+gOs0uQZyw/ZEhb7iL66vvxwXnC8j5p2u2GACW2QViMH5KvcRr+NdBj9i5eXaVjRJ3HoTewKlqPQdhxGf20H6sGoWH1ztFRV7+wvVctJJhO/7q+8gyqg51LN9M6QAN+yg0pdJJmJNd95p7Q5XQdemDPyAtuPItl+2EDexpJIxcdXMCrrXXlFdOcAeALVUlr6U6QzJIvPGB8cj3rUtF5SVXwdg5d3Sj0rb7YIF3W+NXHh2/EuSLYpjqD18rvP+X6ZXUUk/c1K2wWZALejvgfsE+JxoG2+m+KlEcFd622hWbLmfmXPkuHZuKUFR+GscPlnDKbEuTKvp35wOTP/7fDJPAt0yTMrMW/DGrSFsGgq/Bcq7/6sydqQ2VArhuClY6Bw2npTJ/oMj2tYDXejWZIEhUHzZH9tMdm7hRtlLUNbFGMrsBJI1KQuWJobbyt3g4wpaVTBoam3WRiq77aoh7+QC9uSZFflSH0FyDCQnNUN8TEWBfcw7BmQHtmISUoN7XcDhMDstYyfJtj4YG2uFD46qkuZll2tMSxE5TwDJW9kfZp8jKmy+0ojKEhWIBdmmnGLfKUIrNT2/czyvEfCbGel+cPH+6lfL6iXosv1rwXUSXiUK1mTq2ndZLiON2pLeRyVO15wWxypbbQ== srussel0@dlautobots01.wil.csc.local"
}
