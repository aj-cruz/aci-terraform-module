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