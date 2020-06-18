This module was built using the following versions:
Terraform 0.12.26
Terraform aci provider version 0.3.0 (https://github.com/terraform-providers/terraform-provider-aci)
Cisco ACI 4.2(3q)

The ACI configuration is split into three modules called Tier1, Tier2, & Tier3.
Tier1 represents the low-level fabric configurations such as:
-VPC domains (protection groups)
-Interface Policies
-VLAN Pools
-Domains (physica, external, VMM)
-AAEPs

Tier2 represents Switch configurations such as:
-Switch profiles
-Interface profiles
-Interface Policy Groups

Tier3 represents Tenant configurations such as:
-Tenants
-VRFs
-Bridge Domains
-L3Outs
-Application Profiles
-EPGs