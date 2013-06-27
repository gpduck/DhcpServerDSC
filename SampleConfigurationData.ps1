@(
	@{
		NodeName = "localhost";
		ServerLeaseDuration = (New-TimeSpan -Days 15);
		ClientLeaseDuration = (New-TimeSpan -Hours 12);
		#Thx goog!
		PublicDnsServers = "8.8.8.8","8.8.4.4";
		ProdDnsServers = "10.1.0.10","10.1.0.11";
		LabDnsServers = "10.2.0.10","10.2.0.11";
		WinsServers = "10.1.0.10","10.1.0.11";
		WinsNodeType = "0x08";
		DnsDomain = "internal.contoso.com";
		NtpServer = "10.1.0.10";
		
		#Region Classes
			Classes = @(
				@{
					Name = "iPXE";
					Value = "iPXE";
					"Type" = "User";
					Description = "User class for iPXE";
				}, @{
					Name = "MSUCClient";
					"Type" = "Vendor";
					Value = "MS-UC-Client";
					Description = "UC Vendor Class Id";
				}
			);
		#EndRegion Classes
		
		#Region Options
			Options = @(
				@{
					Name = "UCSipServer";
					OptionId = 120;
					"Type" = "BinaryData";
					Description = "Sip Server Fqdn";
				}, @{
					Name = "UCIdentifier";
					OptionId = 1;
					"Type" = "BinaryData";
					VendorClass = "MSUCClient";
					Description = "UC Identifier";
				}
			);
		#EndRegion Options
		
		#Region UserScopes
			UserScopes = @(
				@{
					ScopeId = "10.0.101.0";
					Name = 'HQ - 1st Floor';
					StartRange = "10.0.101.100";
					EndRange = "10.0.101.200";
					SubnetMask = "255.255.255.0";
					DnsKey = "ProdDnsServers";
					Options = @(
						#Router
						@{ OptionId = 3; Value = "10.0.101.1"; }
					)
				}, @{
					ScopeId = "10.0.102.0";
					Name = "HQ - 2nd Floor";
					StartRange = "10.0.102.100";
					EndRange = "10.0.102.200";
					SubnetMask = "255.255.255.0";
					DnsKey = "ProdDnsServers";
					Options = @(
						#Router
						@{ OptionId = 3; Value = "10.0.102.1"; }
					)
				}, @{
					ScopeId = "10.0.200.0";
					Name = 'HQ - Wireless';
					StartRange = "10.0.200.100";
					EndRange = "10.0.201.254";
					SubnetMask = "255.255.254.0";
					DnsKey = "PublicDnsServers";
					Options = @(
						#Router
						@{ OptionId = 3; Value = "10.0.200.1"; }
					)
				}
			);
		#EndRegion UserScopes
		
		#Region ServerScopes
			ServerScopes = @(
				@{
					ScopeId = "10.1.0.0";
					Name = 'Domain Controllers and Stuff';
					Description = 'Its not like these can use DHCP anyway';
					StartRange = "10.1.0.100";
					EndRange = "10.1.0.105"
					SubnetMask = "255.255.255.0";
					Options = @(
						#Router
						@{ OptionId = 3; Value = "10.1.0.1"; }
					)
				}, @{
					ScopeId = "10.1.1.0";
					Name = 'Databases go here';
					StartRange = "10.1.1.100";
					EndRange = "10.1.1.150";
					SubnetMask = "255.255.255.0";
					Options = @(
						#Router
						@{ OptionId = 3; Value = "10.1.1.1"; }
					)
				}, @{
					ScopeId = "10.1.2.0";
					Name = 'Tier two is app I think';
					StartRange = "10.1.2.100";
					EndRange = "10.1.2.200";
					SubnetMask = "255.255.255.0";
					Options = @(
						#Router
						@{ OptionId = 3; Value = "10.1.2.1"; }
					)
				}, @{
					ScopeId = "10.1.4.0";
					Name = 'And three would be web';
					Description = 'Apparently we have a lot of these';
					StartRange = "10.1.4.100";
					EndRange = "10.1.5.200";
					SubnetMask = "255.255.254.0";
					Options = @(
						#Router
						@{ OptionId = 3; Value = "10.1.4.1"; },
						#And why not a PXE server
						@{ OptionId = 66; Value = "10.1.0.10"; },
						#And a file to boot
						@{ OptionId = 67; Value = "\boot\x64\wdsnbp.com"; }
					)
				}
			);
		#EndRegion ServerScopes
	}
);