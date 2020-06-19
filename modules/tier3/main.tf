// This module will hold all "Tier 3" ACI configurations including:
// -Tenants
// -VRFs
// -Bridge Domains
// -EPGs
// -Application Profiles
// -L3Outs

resource "aci_tenant" "tenants" {
    for_each = var.tenants
    name = each.value.name
}

resource "aci_vrf" "vrfs" {
    for_each = var.VRFs
    name = each.value.name
    tenant_dn = each.value.tenant_dn
    pc_enf_pref = each.value.enforcement
}

resource "aci_any" "any" {
    depends_on = [aci_vrf.vrfs]
    for_each = var.VRFs
    vrf_dn = aci_vrf.vrfs[each.key].id
    pref_gr_memb = each.value.preferred_group
}

resource "aci_bridge_domain" "BDs" {
    depends_on = [aci_tenant.tenants]
    for_each = var.BDs
    name = each.value.name
    tenant_dn = each.value.tenant_dn
    relation_fv_rs_ctx = each.value.vrf_dn
    arp_flood = each.value.arp_flood
    unk_mac_ucast_act = each.value.L2_unknown_unicast
}

resource "aci_application_profile" "APPs" {
    depends_on = [aci_tenant.tenants]
    for_each = var.app_profiles
    name = each.value.name
    tenant_dn = each.value.tenant_dn
}

resource "aci_application_epg" "EPGs" {
    depends_on = [aci_tenant.tenants]
    for_each = var.EPGs
    name = each.value.name
    annotation = each.value.annotation
    application_profile_dn = each.value.application_dn
    pref_gr_memb = each.value.pref_gr_memb
    relation_fv_rs_bd = each.value.bridge_domain_dn
    relation_fv_rs_dom_att = each.value.domain_dn_list
}

resource "aci_epg_to_static_path" "paths" {
    depends_on = [aci_application_epg.EPGs]
    for_each = var.epg_static_paths
    application_epg_dn = each.value.application_epg_dn
    tdn = each.value.tDn
    encap = each.value.encap
    mode = each.value.mode
    instr_imedcy = each.value.immediacy
    primary_encap = each.value.micro_seg_primary_encap
}