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

output "L3Outs" {
    value = {
        for l3o in aci_l3_outside.L3Outs:
        l3o["name"] => l3o["id"]
    }
}

output "App-Profiles" {
    # Since App Profiles can have the same name I will append the key with the tenant separated with a slash
    # EXAMPLE: TENANT1/Production-Network
    value = {
        for app in aci_application_profile.APPs:
        join("/", [trim(app["tenant_dn"], "uni/tn-"), app["name"]]) => app["id"]
    }
}

output "Bridge-Domains" {
    # Since Bridge Domains can have the same name I will append the key with the tenant separated with a slash
    # EXAMPLE: TENANT1/WEB-BD
    value = {
        for bd in aci_bridge_domain.BDs:
        join("/", [trim(bd["tenant_dn"], "uni/tn-"), bd["name"]]) => bd["id"]
    }
}

output "EPGs" {
    # Since EPGs can have the same name I will put the tenant and application profile in the key
    # EXAMPLE: TENANT1-Production-Network-VLAN5-EPG
    # Terraform wont let me do nested trim functions, so I can't strip out more than 1 level of characters
    # Because of this I will use an annotation for the key. The caveat is I can't use forward slashes
    # in the annotation, so I will use a dash (See EPG section of main.tf where annotations are defined)
    value = {
        for epg in aci_application_epg.EPGs:
        epg["annotation"] => epg["id"]
    }
}