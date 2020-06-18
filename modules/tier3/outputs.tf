// Return maps of object names to distinguished names
// so that in main.tf we can reference user-friendly names

output "Tenants" {
    value = {
        for tn in aci_tenant.tenants:
        tn["name"] => tn["id"]
    }
}

output "VRFs" {
    # Since VRFs can have the same name I will append the key with the tenant separated with a slash
    # EXAMPLE: TENANT1/PROD-VRF
    value = {
        for vrf in aci_vrf.vrfs:
        join("/", [trim(vrf["tenant_dn"], "uni/tn-"), vrf["name"]]) => vrf["id"]
    }
}