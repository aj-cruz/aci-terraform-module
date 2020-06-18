// This module will hold all "Tier 2" ACI configurations including:
// -Switch Profiles
// -Interface Policy Groups
// -Interface Profiles

resource "aci_leaf_access_port_policy_group" "Access-PolGrp" {
    for_each = var.access_pol_grps
    name = each.value.name
    relation_infra_rs_att_ent_p = each.value.aaep
    relation_infra_rs_cdp_if_pol = each.value.cdp_pol
    relation_infra_rs_lldp_if_pol = each.value.lldp_pol
}

resource "aci_pcvpc_interface_policy_group" "PCVPC-PolGrp" {
    for_each = var.pc_pol_grps
    name = each.value.name
    lag_t = each.value.type
    relation_infra_rs_att_ent_p = each.value.aaep
    relation_infra_rs_cdp_if_pol = each.value.cdp_pol
    relation_infra_rs_lldp_if_pol = each.value.lldp_pol
    relation_infra_rs_lacp_pol = each.value.lacp_pol
}

resource "aci_leaf_interface_profile" "Profiles" {
    for_each = var.leaf_int_profiles
    name = each.value.name
}

resource "aci_access_port_selector" "Access-Port-Selectors" {
    for_each = var.access_port_selectors
    name = each.value.name
    leaf_interface_profile_dn = each.value.int_pro
    access_port_selector_type = each.value.type
    # This is broken for now, waiting on fix from provider (can't add policy group)
    relation_infra_rs_acc_base_grp = each.value.int_grp
}

resource "aci_access_port_block" "Access-Port-Blocks" {
    depends_on = [aci_access_port_selector.Access-Port-Selectors]
    for_each = var.access_port_selectors
    name = each.value.block_name
    access_port_selector_dn = aci_access_port_selector.Access-Port-Selectors[each.key].id
    from_card = each.value.from[0]
    from_port = each.value.from[1]
    to_card = each.value.to[0]
    to_port = each.value.to[1]
}

resource "aci_leaf_profile" "Profiles" {
    for_each = var.leaf_switch_profiles
    name = each.value.name
    relation_infra_rs_acc_port_p = each.value.int_selector_profile_dn_list
}

resource "aci_switch_association" "Associations" {
    # This is broken for now, waiting on fix from provider (no way to add switch range/block)    
    for_each = var.switch_associations
    name = each.value.name
    leaf_profile_dn = each.value.leaf_pro_dn
    switch_association_type = each.value.type
}