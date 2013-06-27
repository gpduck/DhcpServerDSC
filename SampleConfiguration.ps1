Configuration DhcpServers {
	Node "localhost" {
		WindowsFeature Dhcp {
			Ensure = "Present";
			Name = "DHCP";
		}
		
		WindowsFeature "Rsat-Dhcp" {
			Ensure = "Present";
			Name = "RSAT-DHCP";
			Requires = "[WindowsFeature]Dhcp";
		}
		
		DhcpSettingDSC DhcpSettings {
			Setting_ConflictDetectionAttempts = 1;
			V4DnsSetting_DynamicUpdates = "Always";
			V4DnsSetting_UpdateDnsRRForOlderClients = $true;
			Requires = "[WindowsFeature]Rsat-Dhcp";
		}
		
		$Node.Classes | ForEach-Object {
			$ClassInfo = $_
			DhcpV4ClassDSC $ClassInfo.Name {
				Ensure = "Present";
				Name = $ClassInfo.Name;
				Value = $ClassInfo.Value;
				Type = $ClassInfo.Type;
				Description = $ClassInfo.Description;
				Requires = "[DhcpSettingDSC]DhcpSettings";
			}
		}
		
		$Node.Options | ForEach-Object {
			$OptionInfo = $_
			DhcpV4OptionDefinitionDSC $OptionInfo.Name {
				Ensure = "Present";
				Name = $OptionInfo.Name;
				OptionId = $OptionInfo.OptionId;
				Type = $OptionInfo.Type;
				VendorClass = $OptionInfo.VendorClass;
				Description = $OptionInfo.Description;
				Requires = ($Node.Classes | %{ "[DhcpV4ClassDSC]$($_.Name)" })
			}
		}
		
		$Node.UserScopes | ForEach-Object {
			$ScopeData = $_
			#Create the scope
			DhcpV4ScopeDSC $ScopeData.ScopeId {
				Ensure = "Present";
				ScopeId = $ScopeData.ScopeId;
				StartRange = $ScopeData.StartRange;
				EndRange = $ScopeData.EndRange;
				SubnetMask = $ScopeData.SubnetMask;
				Name = $ScopeData.Name;
				Description = $ScopeData.Description;
				LeaseDuration = $Node.ClientLeaseDuration.ToString();
				SuperscopeName = "Users";
				Requires = "[WindowsFeature]Rsat-Dhcp";
			}
			
			#Configure DNS Server option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_6" {
				Ensure = "Present";
				OptionId = 6;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node[$ScopeData.DnsKey];
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure DnsDomain option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_15" {
				Ensure = "Present";
				OptionId = 15;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.DnsDomain;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure WinsServer option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_44" {
				Ensure = "Present";
				OptionId = 44;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.WinsServers;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure Wins Node Type option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_46" {
				Ensure = "Present";
				OptionId = 46;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.WinsNodeType;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure scope specific options
			$ScopeData.Options | %{
				$OptionData = $_
				DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_$($OptionData.OptionId)" {
					Ensure = "Present";
					OptionId = $OptionData.OptionId;
					ScopeId = $ScopeData.ScopeId;
					Value = $OptionData.Value;
					VendorClass = $OptionData.VendorClass;
					UserClass = $OptionData.UserClass;
					PolicyName = "";
					ReservedIP = "";
					Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
				}
			}
		}
		
		$Node.ServerScopes | ForEach-Object {
			$ScopeData = $_
			#Create the scope
			DhcpV4ScopeDSC $ScopeData.ScopeId {
				Ensure = "Present";
				ScopeId = $ScopeData.ScopeId;
				StartRange = $ScopeData.StartRange;
				EndRange = $ScopeData.EndRange;
				SubnetMask = $ScopeData.SubnetMask;
				Name = $ScopeData.Name;
				Description = $ScopeData.Description;
				LeaseDuration = $Node.ServerLeaseDuration.ToString();
				SuperscopeName = "Servers";
				Requires = "[WindowsFeature]Rsat-Dhcp";
			}

			#Configure NTP on our servers
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_4" {
				Ensure = "Present";
				OptionId = 4;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.NtpServer;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure DNS Server option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_6" {
				Ensure = "Present";
				OptionId = 6;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.ProdDnsServers;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure DnsDomain option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_15" {
				Ensure = "Present";
				OptionId = 15;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.DnsDomain;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure WinsServer option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_44" {
				Ensure = "Present";
				OptionId = 44;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.WinsServers;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure Wins Node Type option
			DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_46" {
				Ensure = "Present";
				OptionId = 46;
				ScopeId = $ScopeData.ScopeId;
				Value = $Node.WinsNodeType;
				PolicyName = "";
				ReservedIP = "";
				VendorClass = "";
				UserClass = "";
				Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
			}
			
			#Configure scope specific options
			$ScopeData.Options | %{
				$OptionData = $_
				DhcpV4OptionValueDSC "$($ScopeData.ScopeId)_$($OptionData.OptionId)" {
					Ensure = "Present";
					OptionId = $OptionData.OptionId;
					ScopeId = $ScopeData.ScopeId;
					Value = $OptionData.Value;
					VendorClass = $OptionData.VendorClass;
					UserClass = $OptionData.UserClass;
					PolicyName = "";
					ReservedIP = "";
					Requires = "[DhcpV4ScopeDSC]$($ScopeData.ScopeId)";
				}
			}
		}
		
		#Someone keeps adding a 4th floor, but we don't have one, so we want to make sure it gets deleted
		DhcpV4ScopeDSC "PhantomFloor" {
			Ensure = "Absent";
			ScopeId = "10.0.104.0";
			#These are required for the module, but not used to actually remove the scope (so they don't have to match what is defined)
			StartRange = "10.0.104.100";
			EndRange = "10.0.104.101";
			SubnetMask = "255.255.255.0";
			Requires = "[WindowsFeature]Rsat-Dhcp";
		}
	}
}
