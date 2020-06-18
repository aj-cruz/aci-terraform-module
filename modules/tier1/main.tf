// This module will hold all "Tier 1" ACI configurations including:
// -VPC Domains
// -Interface policies (LLDP, CDP, etc.)
// -VLAN Pools and associated encapsulation blocks
// -Domains
// -AAEPs

resource "aci_vpc_explicit_protection_group" "VPC-Group" {
  for_each = var.vpc_protection_groups
  name  = each.value.name
  switch1 = each.value.switch1
  switch2 = each.value.switch2
  vpc_domain_policy = each.value.policy
  vpc_explicit_protection_group_id  = each.value.id
}

resource "aci_lldp_interface_policy" "LLDP-Policies" {
  for_each = var.lldp_policies
  name  = each.value.name
  admin_rx_st = each.value.receive
  admin_tx_st = each.value.transmit
}

resource "aci_cdp_interface_policy" "CDP-Policies" {
  for_each = var.cdp_policies
  name  = each.value.name
  admin_st  = each.value.state
}

resource "aci_lacp_policy" "LACP-Policies" {
  for_each = var.lacp_policies
  name  = each.value.name
  mode = each.value.mode
}

resource "aci_vlan_pool" "VLAN-Pools" {
  for_each = var.vlan_pools
  name  = each.value.name
  alloc_mode  = each.value.alloc_mode
}

resource "aci_ranges" "Encap-Block" {
  for_each = var.encap_blocks
  depends_on = [aci_vlan_pool.VLAN-Pools]
  vlan_pool_dn  = each.value.pool
  _from = each.value.from
  to = each.value.to
}

resource "aci_physical_domain" "PhyDom" {
  depends_on = [aci_vlan_pool.VLAN-Pools]
  for_each = var.phydoms
  name  = each.value.name
  relation_infra_rs_vlan_ns = each.value.vpool
}

resource "aci_l3_domain_profile" "L3ODom" {
  depends_on = [aci_vlan_pool.VLAN-Pools]
  for_each = var.l3odoms
  name  = each.value.name
  relation_infra_rs_vlan_ns = each.value.vpool
}

resource "aci_attachable_access_entity_profile" "Physical-AAEPs" {
  depends_on = [aci_physical_domain.PhyDom]
  for_each = var.paaeps
  name  = each.value.name
  relation_infra_rs_dom_p = each.value.domains
}

resource "aci_attachable_access_entity_profile" "L3Out-AAEPs" {
  depends_on = [aci_l3_domain_profile.L3ODom]
  for_each = var.l3oaaeps
  name  = each.value.name
  relation_infra_rs_dom_p = each.value.domains
}
