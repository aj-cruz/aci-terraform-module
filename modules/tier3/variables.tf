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

variable "app_profiles" {
  type = map(object({
    name = string
    tenant_dn = string
  }))
}

variable "EPGs" {
  type = map(object({
    name = string
    annotation = string
    application_dn = string
    bridge_domain_dn = string
    pref_gr_memb = string
    domain_dn_list = list(string)
  }))
}

variable "epg_static_paths" {
  type = map(object({
    application_epg_dn = string
    tDn = string
    encap = string
    mode = string
    immediacy = string
    micro_seg_primary_encap = string
  }))
}

variable "epg_to_aaep" {
  type = map(object({
    path = string
    payload = string
  }))
}