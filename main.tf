provider "aci" {
  # cisco-aci user name
  username = ""
  # cisco-aci password
  password = ""
  # cisco-aci url
  url      = ""
  insecure = true
}

module "tier1" {
  source = "./modules/tier1"

  # VPC Protection Groups
  vpc_protection_groups = {
    group1 = {
      name  = "LEAF1-LEAF2-VPC"
      switch1 = "201"
      switch2 = "202"
      policy = "default"
      id  = "1"
    }
  }  

  # LLDP Interface Policies
  lldp_policies = {
    pol1 = {
      name = "LLDP-ON"
      receive = "enabled"
      transmit = "enabled"
    }
  }

  # CDP Interface Policies
  cdp_policies = {
    pol1 = {
      name = "CDP-ON"
      state = "enabled"
    }
    pol2 = {
      name = "CDP-OFF"
      state = "disabled"
    }
  }

  # LACP Interface Poicies. NOTE: "off" = Static On
  lacp_policies = {
    pol1 = {
      name = "LACP-ACTIVE"
      mode = "active"
    }
    pol2 = {
      name = "STATIC-ON"
      mode = "off"
    }
  }

  # VLAN pools
  vlan_pools = {
    pool1 = {
      name = "PHYS-VLAN-POOL"
      alloc_mode = "static"
    }
    pool2 = {
      name = "L3-VLAN-POOL"
      alloc_mode = "static"
    }
    pool3 = {
      name = "VMM-VLAN-POOL"
      alloc_mode = "dynamic"
    }
  }

  # Encapsulation (VLAN) blocks
  encap_blocks = {
    block1 = {
      pool = module.tier1.VLAN-Pools["PHYS-VLAN-POOL"]
      from = "vlan-2"
      to = "vlan-2"
    }
    block2 = {
      pool = module.tier1.VLAN-Pools["PHYS-VLAN-POOL"]
      from = "vlan-3"
      to = "vlan-3"
    }
  }

  # Physical Domains
  phydoms = {
    dom1 = {
      name = "PhyDom"
      vpool = module.tier1.VLAN-Pools["PHYS-VLAN-POOL"]
    }
  }

  # L3 Out Domains
  l3odoms = {
    dom1 = {
      name = "L3Out-Dom"
      vpool = module.tier1.VLAN-Pools["L3-VLAN-POOL"]
    }
  }

  # Physical AAEPs
  paaeps = {
    paaep1 = {
      name = "Physical-AAEP"
      domains = [module.tier1.PhyDoms["PhyDom"]]
    }
  }

  # L3 Out AAEPs
  l3oaaeps = {
    l3oaaep1 = {
      name = "L3Out-AAEP"
      domains = [module.tier1.L3ODoms["L3Out-Dom"]]
    }
  }
}

module "tier2" {
  source = "./modules/tier2"

  # Access Interface Policy Groups
  access_pol_grps = {
    polgrp1 = {
      name = "baremetal-access-w-cdp"
      aaep = module.tier1.Physical-AAEPs["Physical-AAEP"]
      cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
      lldp_pol = null
    }
    polgrp2 = {
      name = "baremetal-access"
      aaep = module.tier1.Physical-AAEPs["Physical-AAEP"]
      cdp_pol = null
      lldp_pol = module.tier1.LLDP-Policies["LLDP-ON"]
    }
  }

  # Port Channel & Virtual Port Channel Interface Policy Groups
  # Only difference between PC & VPC is type (link or node respectively)
  pc_pol_grps = {
    polgrp1 = {
      name = "L2-External-PC"
      type = "link"
      aaep = module.tier1.Physical-AAEPs["Physical-AAEP"]
      cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
      lldp_pol = null
      lacp_pol = module.tier1.LACP-Policies["STATIC-ON"]
    }
    polgrp2 = {
      name = "L3-External-VPC"
      type = "node"
      aaep = module.tier1.L3Out-AAEPs["L3Out-AAEP"]
      cdp_pol = null
      lldp_pol = module.tier1.LLDP-Policies["LLDP-ON"]
      lacp_pol = module.tier1.LACP-Policies["LACP-ACTIVE"]
    }
  }

  # Leaf Interface Profiles
  leaf_int_profiles = {
    profile1 = {
      name = "LEAF1-LEAF2-IntPro"
    }
    profile2 = {
      name = "LEAF3-LEAF4-IntPro"
    }
  }

  # Access Port/Interface Selectors
  access_port_selectors = {
    selector1 = {
      name = "Port1"
      block_name = "block1"
      int_pro = module.tier2.Leaf-IntPros["LEAF1-LEAF2-IntPro"]
      type = "range"
      int_grp = module.tier2.Access-Pol-Grps["baremetal-access"]
      from = [1,1]
      to = [1,1]
    }
    selector2 = {
      name = "Port2"
      block_name = "block2"
      int_pro = module.tier2.Leaf-IntPros["LEAF1-LEAF2-IntPro"]
      type = "range"
      int_grp = null
      from = [1,2]
      to = [1,2]
    }
    selector3 = {
      name = "Port3"
      block_name = "block3"
      int_pro = module.tier2.Leaf-IntPros["LEAF1-LEAF2-IntPro"]
      type = "range"
      int_grp = null
      from = [1,3]
      to = [1,3]
    }
    selector4 = {
      name = "Port1"
      block_name = "block4"
      int_pro = module.tier2.Leaf-IntPros["LEAF3-LEAF4-IntPro"]
      type = "range"
      int_grp = null
      from = [1,1]
      to = [1,1]
          }
    selector5 = {
      name = "Port2"
      block_name = "block5"
      int_pro = module.tier2.Leaf-IntPros["LEAF3-LEAF4-IntPro"]
      type = "range"
      int_grp = null
      from = [1,2]
      to = [1,2]
    }
    selector6 = {
      name = "Port3"
      block_name = "block6"
      int_pro = module.tier2.Leaf-IntPros["LEAF3-LEAF4-IntPro"]
      type = "range"
      int_grp = null
      from = [1,3]
      to = [1,3]
    }
  }

  # Leaf Switch Profiles
  leaf_switch_profiles = {
    profile1 = {
      name = "LEAF1-LEAF2-SWPRO"
      int_selector_profile_dn_list = [
        module.tier2.Leaf-IntPros["LEAF1-LEAF2-IntPro"]
      ]
    }
    profile2 = {
      name = "LEAF3-LEAF4-SWPRO"
      int_selector_profile_dn_list = [
        module.tier2.Leaf-IntPros["LEAF3-LEAF4-IntPro"]
      ]
    }
  }

  # Switch Profile Associations (leaf selectors, interface selector profiles)
  switch_associations = {
    association1 = {
      name = "LEAF1-LEAF2"      
      leaf_pro_dn = module.tier2.Leaf-SWPros["LEAF1-LEAF2-SWPRO"]
      type = "range"
    }
    association2 = {
      name = "LEAF3-LEAF4"      
      leaf_pro_dn = module.tier2.Leaf-SWPros["LEAF3-LEAF4-SWPRO"]
      type = "range"
    }
  }
}

module "tier3" {
  source = "./modules/tier3"

  # Tenants
  tenants = {
    tenant1 = {
      name = "TENANT1"
    }
    tenant2 = {
      name = "TENANT2"
    }
  }

  # VRFs
  VRFs = {
    vrf1 = {
      name = "PROD-VRF"
      tenant_dn = module.tier3.Tenants["TENANT1"]
      enforcement = "enforced"
      preferred_group = "enabled"
    }
    vrf2 = {
      name = "DEV-VRF"
      tenant_dn = module.tier3.Tenants["TENANT1"]
      enforcement = "enforced"
      preferred_group = "disabled"
    }
    vrf3 = {
      name = "PROD-VRF"
      tenant_dn = module.tier3.Tenants["TENANT2"]
      enforcement = "unenforced"
      preferred_group = "disabled"
    }
  }

  # Bridge Domains
  # NOTE: If L2_unkown_unicast is set to "flood" you need to also set arp_flood to "yes"
  BDs = {
    bd1 = {
      name = "VLAN5-BD"
      tenant_dn = module.tier3.Tenants["TENANT1"]
      vrf_dn = module.tier3.VRFs["TENANT1/PROD-VRF"]
      arp_flood = "no"
      L2_unknown_unicast = "proxy"
    }
    bd2 = {
      name = "VLAN9-BD"
      tenant_dn = module.tier3.Tenants["TENANT1"]
      vrf_dn = null
      arp_flood = "yes"
      L2_unknown_unicast = "flood"
    }
    bd3 = {
      name = "VLAN2-BD"
      tenant_dn = module.tier3.Tenants["TENANT2"]
      vrf_dn = module.tier3.VRFs["TENANT2/PROD-VRF"]
      arp_flood = "yes"
      L2_unknown_unicast = "proxy"
    }
  }
}

// output "log" {
//   value = module.tier3.VRFs["TENANT1/PROD-VRF"]
// }