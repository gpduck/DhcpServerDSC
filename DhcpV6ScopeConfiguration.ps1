@(
	@{
		#Required
		Prefix = "fd88:74e0::";
		Name = "Fake 74e0 Subnet";
		
		#Optional
		Ensure = "Present"; # [ValidateSet("Present","Absent")]
		Description = "Testing DSC Provider";
		Preference = 1;
		State = "Inactive"; # [ValidateSet("Active","Inactive")]
		PreferredLifetime = (New-TimeSpan -Hours 8 -Minutes 8);
		#T1 = (New-Timespan -Days 4 -Hours 4 -Minutes 4);
		#T2 = (New-Timespan -Days 6 -Hours 5 -Minutes 4);
		#ValidLifetime = (New-Timespan -Days 12 -Hours 12);
	},
	@{
		#Required
		Prefix = "fd88:1111::";
		Name = "Fake 1111 Subnet";
		
		#Optional
		Ensure = "Present"; # [ValidateSet("Present","Absent")]
		Description = "Testing DSC Provider";
		Preference = 2;
		State = "Inactive"; # [ValidateSet("Active","Inactive")]
		PreferredLifetime = (New-TimeSpan -days 8 -Hours 8 -Minutes 8);
		T1 = (New-Timespan -Days 4 );
		T2 = (New-Timespan -Days 7 -Hours 5 );
		ValidLifetime = (New-Timespan -Days 12 -Hours 12);
	}
)
