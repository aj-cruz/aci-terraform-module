variable "vpc_protection_groups" {
  type = map(object({
    name = string
    switch1 = string
    switch2 = string
    policy = string
    id = string
  }))
  default = {}
}

variable "lldp_policies" {
  type = map(object({
    name = string
    receive = string
    transmit = string
  }))
  default = {}
}

variable "cdp_policies" {
  type = map(object({
    name = string
    state = string
  }))
  default = {}
}

variable "lacp_policies" {
  type = map(object({
    name = string
    mode = string
  }))
}

variable "vlan_pools" {
  type = map(object({
    name = string
    alloc_mode = string
  }))
  default = {}
}

variable "encap_blocks" {
  type = map(object({
    pool = string
    from = string
    to = string
  }))
  default = {}
}

variable "phydoms" {
  type = map(object({
    name = string
    vpool = string
  }))
  default = {}
}

variable "l3odoms" {
  type = map(object({
    name = string
    vpool = string
  }))
  default = {}
}

variable "aaeps" {
  type = map(object({
    name = string
    domains = list(string)
  }))
  default = {}
}