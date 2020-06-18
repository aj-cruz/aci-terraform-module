variable "vpc_protection_groups" {
  type = map(object({
    name = string
    switch1 = string
    switch2 = string
    policy = string
    id = string
  }))
}

variable "lldp_policies" {
  type = map(object({
    name = string
    receive = string
    transmit = string
  }))
}

variable "cdp_policies" {
  type = map(object({
    name = string
    state = string
  }))
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
}

variable "encap_blocks" {
  type = map(object({
    pool = string
    from = string
    to = string
  }))
}

variable "phydoms" {
  type = map(object({
    name = string
    vpool = string
  }))
}

variable "l3odoms" {
  type = map(object({
    name = string
    vpool = string
  }))
}

variable "paaeps" {
  type = map(object({
    name = string
    domains = list(string)
  }))
}

variable "l3oaaeps" {
  type = map(object({
    name = string
    domains = list(string)
  }))
}