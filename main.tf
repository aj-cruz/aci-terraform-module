
provider "aci" {
	username = "admin"
	password = ""
	url = ""
	insecure = true
}


module "tier1" {
	source = "./modules/tier1"

	vpc_protection_groups = {		
		group1 = {
			name = "LEAF1-LEAF2-VPC"
			switch1 = "201"
			switch2 = "202"
			policy = "default"
			id = "201"
		}
	}

	lldp_policies = {
		pol1 = {
			name = "LLDP-ON"
			receive = "enabled"
			transmit = "enabled"
		}
		pol2 = {
			name = "LLDP-OFF"
			receive = "disabled"
			transmit = "disabled"
		}
		pol3 = {
			name = "LLDP-RX"
			receive = "enabled"
			transmit = "disabled"
		}
		pol4 = {
			name = "LLDP-TX"
			receive = "disabled"
			transmit = "enabled"
		}
	}

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

	lacp_policies = {
		pol1 = {
			name = "LACP-ACTIVE"
			mode = "active"
		}
		pol2 = {
			name = "STATIC-ON"
			mode = "off"
		}
		pol3 = {
			name = "MAC-PIN"
			mode = "mac-pin"
		}
	}

	vlan_pools = {
		pol1 = {
			name = "Phys-VLAN-Pool"
			alloc_mode = "static"
		}
		pol2 = {
			name = "VMM-VLAN-Pool"
			alloc_mode = "dynamic"
		}
		pol3 = {
			name = "L3Out-VLAN-Pool"
			alloc_mode = "static"
		}
	}

	encap_blocks = {
		block1 = {
			pool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
			from = "vlan-2"
			to = "vlan-2"
		}
		block2 = {
			pool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
			from = "vlan-3"
			to = "vlan-3"
		}
		block3 = {
			pool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
			from = "vlan-4"
			to = "vlan-4"
		}
		block4 = {
			pool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
			from = "vlan-5"
			to = "vlan-5"
		}
		block5 = {
			pool = module.tier1.VLAN-Pools["VMM-VLAN-Pool"]
			from = "vlan-9"
			to = "vlan-15"
		}
		block6 = {
			pool = module.tier1.VLAN-Pools["L3Out-VLAN-Pool"]
			from = "vlan-20"
			to = "vlan-20"
		}
	}

	phydoms = {
		dom1 = {
			name = "Phys-Dom"
			vpool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
		}
	}

	l3odoms = {
		dom2 = {
			name = "L3Out-Dom"
			vpool = module.tier1.VLAN-Pools["L3Out-VLAN-Pool"]
		}
	}

  vmmdoms = {
		dom1 = {
			provider = "uni/vmmp-VMware"
      name = "VMM-Dom"
			vpool = module.tier1.VLAN-Pools["VMM-VLAN-Pool"]
      access_mode = "read-write"
		}
	}

	aaeps = {
		paaep1 = {
			name = "Phys-AAEP"
			domains = [module.tier1.PhyDoms["Phys-Dom"]]
		}
		paaep2 = {
			name = "VMM-AAEP"
			domains = [module.tier1.VMMDoms["VMM-Dom"]]
		}
		paaep3 = {
			name = "External-AAEP"
			domains = [module.tier1.PhyDoms["Phys-Dom"],module.tier1.L3ODoms["L3Out-Dom"]]
		}
	}
}


module "tier2" {
	source = "./modules/tier2"

	access_pol_grps = {
		polgrp1 = {
			name = "baremetal-access-cdp-on"
			aaep = module.tier1.AAEPs["Phys-AAEP"]
			cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
			lldp_pol = ""
		}
		polgrp2 = {
			name = "baremetal-access"
			aaep = module.tier1.AAEPs["Phys-AAEP"]
			cdp_pol = ""
			lldp_pol = ""
		}
		polgrp3 = {
			name = "L3Out-1"
			aaep = module.tier1.AAEPs["External-AAEP"]
			cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
			lldp_pol = ""
		}
		polgrp4 = {
			name = "L3Out-2"
			aaep = module.tier1.AAEPs["External-AAEP"]
			cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
			lldp_pol = ""
		}
		polgrp5 = {
			name = "L3Out-3"
			aaep = module.tier1.AAEPs["External-AAEP"]
			cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
			lldp_pol = ""
		}
		polgrp6 = {
			name = "L3Out-4"
			aaep = module.tier1.AAEPs["External-AAEP"]
			cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
			lldp_pol = ""
		}
	}

	pc_pol_grps = {
		polgrp1 = {
			name = "L2-External-VPC"
			type = "node"
			aaep = module.tier1.AAEPs["External-AAEP"]
			cdp_pol = module.tier1.CDP-Policies["CDP-ON"]
			lldp_pol = ""
			lacp_pol = module.tier1.LACP-Policies["LACP-ACTIVE"]
		}
	}

	leaf_int_profiles = {
		profile1 = {
			name = "Leaf1-IntPro"
		}
		profile2 = {
			name = "Leaf2-IntPro"
		}
		profile3 = {
			name = "Leaf3-IntPro"
		}
		profile4 = {
			name = "Leaf4-IntPro"
		}
		profile5 = {
			name = "Leaf5-IntPro"
		}
		profile6 = {
			name = "Leaf6-IntPro"
		}
		profile7 = {
			name = "Leaf7-IntPro"
		}
		profile8 = {
			name = "Leaf8-IntPro"
		}
	}

	access_port_selectors = {
		selector1 = {
			name = "Port1"
			block_name = "block1"
			int_pro = module.tier2.Leaf-IntPros["Leaf1-IntPro"]
			type = "range"
			int_grp = module.tier2.PCVPC-Pol-Grps["L2-External-VPC"]
			from = [1,1]
			to = [1,1]
		}
		selector2 = {
			name = "Port2"
			block_name = "block2"
			int_pro = module.tier2.Leaf-IntPros["Leaf1-IntPro"]
			type = "range"
			int_grp = module.tier2.PCVPC-Pol-Grps["L2-External-VPC"]
			from = [1,2]
			to = [1,2]
		}
		selector3 = {
			name = "Port3"
			block_name = "block3"
			int_pro = module.tier2.Leaf-IntPros["Leaf1-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-1"]
			from = [1,3]
			to = [1,3]
		}
		selector4 = {
			name = "Port4"
			block_name = "block4"
			int_pro = module.tier2.Leaf-IntPros["Leaf1-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-3"]
			from = [1,4]
			to = [1,4]
		}
		selector5 = {
			name = "Port1"
			block_name = "block5"
			int_pro = module.tier2.Leaf-IntPros["Leaf2-IntPro"]
			type = "range"
			int_grp = module.tier2.PCVPC-Pol-Grps["L2-External-VPC"]
			from = [1,1]
			to = [1,1]
		}
		selector6 = {
			name = "Port2"
			block_name = "block6"
			int_pro = module.tier2.Leaf-IntPros["Leaf2-IntPro"]
			type = "range"
			int_grp = module.tier2.PCVPC-Pol-Grps["L2-External-VPC"]
			from = [1,2]
			to = [1,2]
		}
		selector7 = {
			name = "Port3"
			block_name = "block7"
			int_pro = module.tier2.Leaf-IntPros["Leaf2-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-2"]
			from = [1,3]
			to = [1,3]
		}
		selector8 = {
			name = "Port4"
			block_name = "block8"
			int_pro = module.tier2.Leaf-IntPros["Leaf2-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-4"]
			from = [1,4]
			to = [1,4]
		}
	}

	leaf_switch_profiles = {
		profile1 = {
			name = "Leaf1-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf1-IntPro"]]
		}
		profile2 = {
			name = "Leaf2-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf2-IntPro"]]
		}
		profile3 = {
			name = "Leaf3-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf3-IntPro"]]
		}
		profile4 = {
			name = "Leaf4-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf4-IntPro"]]
		}
		profile5 = {
			name = "Leaf5-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf5-IntPro"]]
		}
		profile6 = {
			name = "Leaf6-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf6-IntPro"]]
		}
		profile7 = {
			name = "Leaf7-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf7-IntPro"]]
		}
		profile8 = {
			name = "Leaf8-SwPro"
			int_selector_profile_dn_list = [module.tier2.Leaf-IntPros["Leaf8-IntPro"]]
		}
	}

	switch_associations = {
		association1 = {
			name = "Leaf1"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf1-SwPro"]
			type = "range"
		}
		association2 = {
			name = "Leaf2"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf2-SwPro"]
			type = "range"
		}
		association3 = {
			name = "Leaf3"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf3-SwPro"]
			type = "range"
		}
		association4 = {
			name = "Leaf4"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf4-SwPro"]
			type = "range"
		}
		association5 = {
			name = "Leaf5"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf5-SwPro"]
			type = "range"
		}
		association6 = {
			name = "Leaf6"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf6-SwPro"]
			type = "range"
		}
		association7 = {
			name = "Leaf7"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf7-SwPro"]
			type = "range"
		}
		association8 = {
			name = "Leaf8"
			leaf_pro_dn = module.tier2.Leaf-SWPros["Leaf8-SwPro"]
			type = "range"
		}
	}

}


module "tier3" {
	source = "./modules/tier3"

	tenants = {
		tenant1 = {
			name = "Tenant1"
		}
		tenant2 = {
			name = "Tenant2"
		}
	}

	VRFs = {
		vrf1 = {
			name = "Prod-VRF"
			tenant_dn = module.tier3.Tenants["Tenant1"]
			enforcement = "enforced"
			preferred_group = "disabled"
		}
		vrf2 = {
			name = "Prod-VRF"
			tenant_dn = module.tier3.Tenants["Tenant2"]
			enforcement = "enforced"
			preferred_group = "disabled"
		}
		vrf3 = {
			name = "Dev-VRF"
			tenant_dn = module.tier3.Tenants["Tenant2"]
			enforcement = "enforced"
			preferred_group = "disabled"
		}
	}

	BDs = {
		bd1 = {
			name = "Web-BD"
			tenant_dn = module.tier3.Tenants["Tenant1"]
			vrf_dn = module.tier3.VRFs["Tenant1/Prod-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd2 = {
			name = "App-BD"
			tenant_dn = module.tier3.Tenants["Tenant1"]
			vrf_dn = module.tier3.VRFs["Tenant1/Prod-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd3 = {
			name = "DB-BD"
			tenant_dn = module.tier3.Tenants["Tenant1"]
			vrf_dn = module.tier3.VRFs["Tenant1/Prod-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd4 = {
			name = "Web-BD"
			tenant_dn = module.tier3.Tenants["Tenant2"]
			vrf_dn = module.tier3.VRFs["Tenant2/Prod-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd5 = {
			name = "DevWeb-BD"
			tenant_dn = module.tier3.Tenants["Tenant2"]
			vrf_dn = module.tier3.VRFs["Tenant2/Dev-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
	}

	app_profiles = {
		app1 = {
			name = "Production-Network"
			tenant_dn = module.tier3.Tenants["Tenant1"]
		}
		app2 = {
			name = "Dev-Network"
			tenant_dn = module.tier3.Tenants["Tenant2"]
		}
	}

	EPGs = {
		epg1 = {
			name = "Web-EPG"
			annotation = "Tenant1-Production-Network-Web-EPG"
			application_dn = module.tier3.App-Profiles["Tenant1/Production-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["Tenant1/Web-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"],]
		}
		epg2 = {
			name = "App-EPG"
			annotation = "Tenant1-Production-Network-App-EPG"
			application_dn = module.tier3.App-Profiles["Tenant1/Production-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["Tenant1/App-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"]]
		}
		epg3 = {
			name = "DB-EPG"
			annotation = "Tenant1-Production-Network-DB-EPG"
			application_dn = module.tier3.App-Profiles["Tenant1/Production-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["Tenant1/DB-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"]]
		}
		epg4 = {
			name = "Web-EPG"
			annotation = "Tenant2-Dev-Network-Web-EPG"
			application_dn = module.tier3.App-Profiles["Tenant2/Dev-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["Tenant2/Web-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"]]
		}
	}

}

