variable "access_pol_grps" {
  type = map(object({
    name = string
    aaep = string
    cdp_pol = string
    lldp_pol = string
  }))
}

variable "pc_pol_grps" {
  type = map(object({
    name = string
    type = string
    aaep = string
    cdp_pol = string
    lldp_pol = string
    lacp_pol = string
  }))
}

variable "leaf_int_profiles" {
  type = map(object({
    name = string
  }))
}

variable "access_port_selectors" {
  type = map(object({
    name = string
    block_name = string
    int_pro = string
    type = string
    int_grp = string
    from = list(number)
    to = list(number)
  }))
}


variable "leaf_switch_profiles" {
  type = map(object({
    name = string
    int_selector_profile_dn_list = list(string)
  }))
}

variable "switch_associations" {
  type = map(object({
    name = string
    leaf_pro_dn = string
    type = string
  }))
}