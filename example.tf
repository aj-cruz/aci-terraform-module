
# Cisco ACI Credentials
provider "aci" {
	username = "admin"
	password = "password"
	url = "https://"
	insecure = true
}

# Tier 1 configurations
# Low-level shared objects sch as interface policies, domains, aaeps, vlan pools
module "tier1" {
	source = "./modules/tier1"

	# VPC Protection Groups (Domains)
	vpc_protection_groups = {		
		group1 = {
			name = "LEAF1-LEAF2-VPC"
			switch1 = "201"
			switch2 = "202"
			policy = "default"
			id = "201"
		}
		group2 = {
			name = "LEAF3-LEAF4-VPC"
			switch1 = "203"
			switch2 = "204"
			policy = "default"
			id = "203"
		}
		group3 = {
			name = "LEAF5-LEAF6-VPC"
			switch1 = "205"
			switch2 = "206"
			policy = "default"
			id = "205"
		}
		group4 = {
			name = "LEAF7-LEAF8-VPC"
			switch1 = "207"
			switch2 = "208"
			policy = "default"
			id = "207"
		}
	}

	 # LLDP Interface Policies
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
		pol3 = {
			name = "MAC-PIN"
			mode = "mac-pin"
		}
	}

	# VLAN pools
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

	# Encapsulation (VLAN) blocks to add to VLAN pools
	encap_blocks = {
		block1 = {
			pool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
			from = "vlan-2"
			to = "vlan-10"
		}
		block2 = {
			pool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
			from = "vlan-101"
			to = "vlan-101"
		}
		block3 = {
			pool = module.tier1.VLAN-Pools["Phys-VLAN-Pool"]
			from = "vlan-201"
			to = "vlan-201"
		}
		block4 = {
			pool = module.tier1.VLAN-Pools["VMM-VLAN-Pool"]
			from = "vlan-1300"
			to = "vlan-1499"
		}
	}

	# Physical Domains
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

	# L3 Out Domains
	vmmdoms = {
		dom3 = {
			provider = "uni/vmmp-VMware"
			name = "ACI-DVS"
			vpool = module.tier1.VLAN-Pools["VMM-VLAN-Pool"]
			access_mode = "read-write"
		}
	}

	# Attachable Access Entity Profiles (AAEPs)
	aaeps = {
		aaep1 = {
			name = "Phys-AAEP"
			domains = [module.tier1.PhyDoms["Phys-Dom"]]
		}
		aaep2 = {
			name = "VMM-AAEP"
			domains = []
		}
		aaep3 = {
			name = "External-AAEP"
			domains = [module.tier1.PhyDoms["Phys-Dom"],module.tier1.L3ODoms["L3Out-Dom"]]
		}
	}
}

# Tier 2 Configuration
# Interface and Switch policies & profiles
module "tier2" {
	source = "./modules/tier2"

	# Access Interface Policy Groups
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

	# Port Channel & Virtual Port Channel Interface Policy Groups
  	# Only difference between PC & VPC is type (link or node respectively)
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

	# Leaf Interface Profiles
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

	# Access Port/Interface Selectors
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
			name = "Port11"
			block_name = "block3"
			int_pro = module.tier2.Leaf-IntPros["Leaf1-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-1"]
			from = [1,11]
			to = [1,11]
		}
		selector4 = {
			name = "Port12"
			block_name = "block4"
			int_pro = module.tier2.Leaf-IntPros["Leaf1-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-2"]
			from = [1,12]
			to = [1,12]
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
			name = "Port11"
			block_name = "block7"
			int_pro = module.tier2.Leaf-IntPros["Leaf2-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-3"]
			from = [1,11]
			to = [1,11]
		}
		selector8 = {
			name = "Port12"
			block_name = "block8"
			int_pro = module.tier2.Leaf-IntPros["Leaf2-IntPro"]
			type = "range"
			int_grp = module.tier2.Access-Pol-Grps["L3Out-4"]
			from = [1,12]
			to = [1,12]
		}
	}

	# Leaf Switch Profiles
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

	# Switch Profile Associations (bind leaf selectors & interface selector profiles to switch profiles)
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

# Tier 3 Configs
# All Tenant objects (tenants, VRFs, EPGs, etc.)
module "tier3" {
	source = "./modules/tier3"

	# Tenants
	tenants = {
		tenant1 = {
			name = "AJLAB-Prod"
		}
	}

	# VRFs
	VRFs = {
		vrf1 = {
			name = "Prod-VRF"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
			enforcement = "enforced"
			preferred_group = "enabled"
		}
		vrf2 = {
			name = "Dev-VRF"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
			enforcement = "enforced"
			preferred_group = "disabled"
		}
	}

	# L3Outs
	L3Os = {
		l3o1 = {
			tenant_dn      = module.tier3.Tenants["AJLAB-Prod"]
			description    = ""
			name           = "Prod-OSPF-L3Out"
			rtctrl 		   = "export"
			domain 		   = module.tier1.L3ODoms["L3Out-Dom"]
			vrf			   = module.tier3.VRFs["AJLAB-Prod/Prod-VRF"]
			epg_name	   = "Prod-OSPF-L3Out-EPG"
			pref_gr_memb   = "exclude"
		}
		l3o2 = {
			tenant_dn      = module.tier3.Tenants["AJLAB-Prod"]
			description    = ""
			name           = "Dev-OSPF-L3Out"
			rtctrl 		   = "export"
			domain 		   = module.tier1.L3ODoms["L3Out-Dom"]
			vrf			   = module.tier3.VRFs["AJLAB-Prod/Dev-VRF"]
			epg_name	   = "Dev-OSPF-L3Out-EPG"
			pref_gr_memb   = "include"
		}
	}

	# Bridge Domains
	BDs = {
		bd1 = {
			name = "Web-BD"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
			vrf_dn = module.tier3.VRFs["AJLAB-Prod/Prod-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd2 = {
			name = "App-BD"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
			vrf_dn = module.tier3.VRFs["AJLAB-Prod/Prod-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd3 = {
			name = "DB-BD"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
			vrf_dn = module.tier3.VRFs["AJLAB-Prod/Prod-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd4 = {
			name = "Dev-Web-BD"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
			vrf_dn = module.tier3.VRFs["AJLAB-Prod/Dev-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
		bd5 = {
			name = "Dev-App-BD"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
			vrf_dn = module.tier3.VRFs["AJLAB-Prod/Dev-VRF"]
			arp_flood = "yes"
			L2_unknown_unicast = "flood"
		}
	}

	# Application Profiles
	app_profiles = {
		app1 = {
			name = "Production-Network"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
		}
		app2 = {
			name = "Dev-Network"
			tenant_dn = module.tier3.Tenants["AJLAB-Prod"]
		}
	}

	# Endpoint Groups
	EPGs = {
		epg1 = {
			name = "Web-EPG"
			annotation = "AJLAB-Prod-Production-Network-Web-EPG"
			application_dn = module.tier3.App-Profiles["AJLAB-Prod/Production-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["AJLAB-Prod/Web-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"],module.tier1.VMMDoms["ACI-DVS"]]
		}
		epg2 = {
			name = "App-EPG"
			annotation = "AJLAB-Prod-Production-Network-App-EPG"
			application_dn = module.tier3.App-Profiles["AJLAB-Prod/Production-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["AJLAB-Prod/App-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"],module.tier1.VMMDoms["ACI-DVS"]]
		}
		epg3 = {
			name = "DB-EPG"
			annotation = "AJLAB-Prod-Production-Network-DB-EPG"
			application_dn = module.tier3.App-Profiles["AJLAB-Prod/Production-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["AJLAB-Prod/DB-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"],module.tier1.VMMDoms["ACI-DVS"]]
		}
		epg4 = {
			name = "Web-EPG"
			annotation = "AJLAB-Prod-Dev-Network-Web-EPG"
			application_dn = module.tier3.App-Profiles["AJLAB-Prod/Dev-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["AJLAB-Prod/Web-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"],module.tier1.VMMDoms["ACI-DVS"]]
		}
		epg5 = {
			name = "App-EPG"
			annotation = "AJLAB-Prod-Dev-Network-App-EPG"
			application_dn = module.tier3.App-Profiles["AJLAB-Prod/Dev-Network"]
			bridge_domain_dn = module.tier3.Bridge-Domains["AJLAB-Prod/App-BD"]
			pref_gr_memb = "exclude"
			domain_dn_list = [module.tier1.PhyDoms["Phys-Dom"],module.tier1.VMMDoms["ACI-DVS"]]
		}
	}

}