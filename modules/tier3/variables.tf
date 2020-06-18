variable "tenants" {
  type = map(object({
    name = string
  }))
}

variable "VRFs" {
  type = map(object({
    name = string
    tenant_dn = string
    enforcement = string
    preferred_group = string
  }))
}

variable "BDs" {
  type = map(object({
    name = string
    tenant_dn = string
    arp_flood = string
    vrf_dn = string
    L2_unknown_unicast = string
  }))
}