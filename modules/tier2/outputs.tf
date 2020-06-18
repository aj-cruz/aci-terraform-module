output "Access-Pol-Grps" {
    value = {
        for pol in aci_leaf_access_port_policy_group.Access-PolGrp:
        pol["name"] => pol["id"]
    }
}

output "PCVPC-Pol-Grps" {
    value = {
        for pol in aci_pcvpc_interface_policy_group.PCVPC-PolGrp:
        pol["name"] => pol["id"]
    }
}

output "Leaf-IntPros" {
    value = {
        for profile in aci_leaf_interface_profile.Profiles:
        profile["name"] => profile["id"]
    }
}

output "Leaf-SWPros" {
    value = {
        for profile in aci_leaf_profile.Profiles:
        profile["name"] => profile["id"]
    }
}