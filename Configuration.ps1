@(
	@{
		#Required
		ScopeId = "10.10.10.0";
		StartRange = "10.10.10.50";
		EndRange = "10.10.10.225";
		SubnetMask = "255.255.255.0";
		
		#Optional
		Ensure = "Present"; # "Present|Absent"
		Name = "Fake 10 Subnet";
		Description = "Just testing my DSC provider";
		LeaseDuration = (New-TimeSpan -Days 3);
		
		#These can also be specified:
		
		#Delay = 16;
		#MaxBootpClients = 42;
		#NapEnable = $true;
		#NapProfile = "SomeProfile";
		#State = "Inactive"; # "Active|Inactive"
		#SuperscopeName = "SomeSuperscope"; #Must already exist though
		#Type = "Dhcp"; # "Dhcp|Bootp|Both"
	},
	@{
		#Required
		ScopeId = "10.10.20.0";
		StartRange = "10.10.20.50";
		EndRange = "10.10.20.225";
		SubnetMask = "255.255.255.0";
		
		#Optional
		Ensure = "Present"; # "Present|Absent"
		Name = "Fake 20 Subnet";
		Description = "Just testing my DSC provider";
		LeaseDuration = (New-TimeSpan -Days 30);
		
		#These can also be specified:
		
		#Delay = 16;
		#MaxBootpClients = 42;
		#NapEnable = $true;
		#NapProfile = "SomeProfile";
		#State = "Inactive"; # "Active|Inactive"
		#SuperscopeName = "SomeSuperscope"; #Must already exist though
		#Type = "Dhcp"; # "Dhcp|Bootp|Both"
	}
)