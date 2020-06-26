variable "tenants" {
  type = map(object({
    name = string
  }))
  default = {}
}

variable "VRFs" {
  type = map(object({
    name = string
    tenant_dn = string
    enforcement = string
    preferred_group = string
  }))
  default = {}
}

variable "BDs" {
  type = map(object({
    name = string
    tenant_dn = string
    arp_flood = string
    vrf_dn = string
    L2_unknown_unicast = string
  }))
  default = {}
}

variable "app_profiles" {
  type = map(object({
    name = string
    tenant_dn = string
  }))
  default = {}
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
  default = {}
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
  default = {}
}

// variable "epg_to_aaep" {
//   type = map(object({
//     path = string
//     payload = string
//   }))
// }

// variable "epg_to_aaep" {
//   type = map(object({
//     aaep_dn = string
//     epg_dn = list(string)
//   }))
// }