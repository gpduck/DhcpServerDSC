<#
Copyright 2013 Chris Duck

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
#>

function Get-TargetResource {
	param(
	)
	
	$DnsSetting = Get-DhcpServerV4DnsSetting
	
	[PsCustomObject]@{
		DeleteDnsRROnLeaseExpiry = $DnsSetting.DeleteDnsRROnLeaseExpiry;
		DynamicUpdates = $DnsSetting.DynamicUpdates;
		NameProtection = $DnsSetting.NameProtection;
		UpdateDnsRRForOlderClients = $DnsSetting.UpdateDnsRRForOlderClients;
	}
}

function Set-TargetResource {
	param(
		[Bool]$DeleteDnsRROnLeaseExpiry,
		
		[ValidateSet("Always","Never","OnClientRequest")]
		[String]$DynamicUpdates,
		
		[Bool]$NameProtection,
		
		[Bool]$UpdateDnsRRForOlderClients
	)
	$DnsSetting = Get-DhcpServerV4DnsSetting
	if($DnsSetting) {
		$UpdateParams = GetUpdateParams -DnsSetting $DnsSetting @PSBoundParameters
		
		if($UpdateParams.Count -gt 0) {
			Write-Debug "Updating DNS settings $($UpdateParams.Keys -join ', ')"
			Set-DhcpServerV4DnsSetting @UpdateParams
		}
	} else {
		Write-Error "Unable to load DnsSettings on local DHCP server"
	}
}

function Test-TargetResource {
	param(
		[Bool]$DeleteDnsRROnLeaseExpiry,
		
		[ValidateSet("Always","Never","OnClientRequest")]
		[String]$DynamicUpdates,
		
		[Bool]$NameProtection,
		
		[Bool]$UpdateDnsRRForOlderClients
	)
	$DnsSetting = Get-DhcpServerV4DnsSetting
	if($DnsSetting) {
		$UpdateParams = GetUpdateParams -DnsSetting $DnsSetting @PSBoundParameters
		
		if($UpdateParams.Count -gt 0) {
			#Needs update
			return $false
		} else {
			#No updates needed
			return $true
		}
	} else {
		Write-Error "Unable to load DnsSettings on local DHCP server"
	}
}

function GetUpdateParams {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$DnsSetting,
		
		[Bool]$DeleteDnsRROnLeaseExpiry,
		
		[ValidateSet("Always","Never","OnClientRequest")]
		[String]$DynamicUpdates,
		
		[Bool]$NameProtection,
		
		[Bool]$UpdateDnsRRForOlderClients
	)
	$UpdateParams = @{}
	
	TestProperty -Object $DnsSetting -PropertyName "DeleteDnsRROnLeaseExpiry" -BoundParameters $PSBoundParameters -UpdateParams $UpdateParams
	TestProperty -Object $DnsSetting -PropertyName "DynamicUpdates" -BoundParameters $PSBoundParameters -UpdateParams $UpdateParams
	TestProperty -Object $DnsSetting -PropertyName "NameProtection" -BoundParameters $PSBoundParameters -UpdateParams $UpdateParams
	TestProperty -Object $DnsSetting -PropertyName "UpdateDnsRRForOlderClients" -BoundParameters $PSBoundParameters -UpdateParams $UpdateParams
	
	$UpdateParams
}
	
function TestProperty {
	param(
		$Object,
		$PropertyName,
		$BoundParameters,
		$UpdateParams
	)
	if($BoundParameters.ContainsKey($PropertyName) -and $Object."$PropertyName" -ne $BoundParameters[$PropertyName]) {
		$UpdateParams.Add($PropertyName, $BoundParameters[$PropertyName])
	}
}
