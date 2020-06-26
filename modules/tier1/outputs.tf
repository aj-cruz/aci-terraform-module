output "VLAN-Pools" {
    value = {
        for pool in aci_vlan_pool.VLAN-Pools:
        pool["name"] => pool["id"]
    }
}

output "PhyDoms" {
    value = {
        for dom in aci_physical_domain.PhyDom:
        dom["name"] => dom["id"]
    }
}

output "L3ODoms" {
    value = {
        for dom in aci_l3_domain_profile.L3ODom:
        dom["name"] => dom["id"]
    }
}

output "AAEPs" {
    value = {
        for aaep in aci_attachable_access_entity_profile.AAEPs:
        aaep["name"] => aaep["id"]
    }
}

output "CDP-Policies" {
    value = {
        for pol in aci_cdp_interface_policy.CDP-Policies:
        pol["name"] => pol["id"]
    }
}

output "LLDP-Policies" {
    value = {
        for pol in aci_lldp_interface_policy.LLDP-Policies:
        pol["name"] => pol["id"]
    }
}

output "LACP-Policies" {
    value = {
        for pol in aci_lacp_policy.LACP-Policies:
        pol["name"] => pol["id"]
    }
}
