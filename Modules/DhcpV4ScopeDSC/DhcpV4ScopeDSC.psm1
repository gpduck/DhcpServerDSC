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
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ScopeId,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$Scope = Get-DhcpServerV4Scope -ScopeId $ScopeId -ErrorAction SilentlyContinue
	if($Scope) {
		$EnsureResult = "Present"
	} else {
		$EnsureResult = "Absent"
	}
	
	@{
		Ensure=$EnsureResult;
		Name=$Scope.Name;
		StartRange=$Scope.StartRange;
		EndRange=$Scope.EndRange;
		SubnetMask=$Scope.SubnetMask;
		Delay=$Scope.Delay;
		Description=$Scope.Description;
		LeaseDuration=$Scope.LeaseDuration;
		MaxBootpClients=$Scope.MaxBootpClients;
		NapEnable=$Scope.NapEnable;
		NapProfile=$Scope.NapProfile;
		State=$Scope.State;
		SuperscopeName=$Scope.SuperscopeName;
		Type=$Scope.Type;
	}
}

function Set-TargetResource {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ScopeId,
		
		[String]$Name,
		
		[Parameter(Mandatory=$true)]
		[System.Net.IPAddress]$StartRange,
		
		[Parameter(Mandatory=$true)]
		[System.Net.IPAddress]$EndRange,
		
		[Parameter(Mandatory=$true)]
		[System.Net.IPAddress]$SubnetMask,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present",
		
		[UInt16]$Delay,
		
		[String]$Description,
		
		[TimeSpan]$LeaseDuration,
		
		[UInt32]$MaxBootpClients,
		
		[Switch]$NapEnable,
		
		[String]$NapProfile,
		
		[ValidateSet("Active","Inactive")]
		[String]$State,
		
		[String]$SuperscopeName,
		
		[ValidateSet("Dhcp","Bootp","Both")]
		[String]$Type
	)
	$PSBoundParameters.Remove("Debug") > $null
	$PSBoundParameters.Remove("Verbose") > $null
	$Scope = Get-DhcpServerV4Scope -ScopeId $ScopeId -ErrorAction SilentlyContinue
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($Scope) {
			$PSBoundParameters.Remove("ScopeId") > $Null
			$UpdateParams = GetUpdateParams -Scope $Scope @PSBoundParameters
			
			if($UpdateParams.Count -gt 0) {
				Write-Debug "Updating resource $ScopeId with $($UpdateParams.Keys -join ', ')"
				Set-DhcpServerV4Scope -ScopeId $ScopeId @UpdateParams
			}
		} else {
			#Calculate the scope ID and make sure it is valid for $StartRange + $SubnetMask
			$PSBoundParameters.Remove("Ensure") > $null
			$PSBoundParameters.Remove("ScopeId") > $null
			try {
				Add-DhcpServerV4Scope @PSBoundParameters -ErrorAction Stop
			} catch {
				$ErrorParams = New-Object Text.StringBuilder
				$PSBoundParameters.Keys | %{
					$ErrorParams.Append("${_}: $($PSBoundParameters[$_]), ")
				}
				Write-Error "Failed to add scope $ScopeId with $($ErrorParams.ToString())"
			}
		}
	} else {
		#Ensure Absent, delete if exists
		if($Scope) {
			Remove-DhcpServerV4Scope -ScopeId $ScopeId
		}
	}
}

function Test-TargetResource {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ScopeId,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present",
		
		[String]$Name,
		
		[System.Net.IPAddress]$StartRange,
		
		[System.Net.IPAddress]$EndRange,
		
		[System.Net.IPAddress]$SubnetMask,
		
		[UInt16]$Delay,
		
		[String]$Description,
		
		[TimeSpan]$LeaseDuration,
		
		[UInt32]$MaxBootpClients,
		
		[Switch]$NapEnable,
		
		[String]$NapProfile,
		
		[ValidateSet("Active","Inactive")]
		[String]$State,
		
		[String]$SuperscopeName,
		
		[ValidateSet("Dhcp","Bootp","Both")]
		[String]$Type
	)
	$PSBoundParameters.Remove("Debug") > $null
	$PSBoundParameters.Remove("Verbose") > $null
	$Scope = Get-DhcpServerV4Scope -ScopeId $ScopeId -ErrorAction SilentlyContinue
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($Scope) {
			$PSBoundParameters.Remove("ScopeId") > $Null
			$UpdateParams = GetUpdateParams -Scope $Scope @PSBoundParameters
			
			if($UpdateParams.Count -gt 0) {
				return $false
			} else {
				return $true
			}
		} else {
			return $false
		}
	} else {
		#Ensure Absent, delete if exists
		if($Scope) {
			return $false
		} else {
			return $true
		}
	}
}

function GetUpdateParams {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$Scope,
		
		[String]$Name,
		
		[Parameter(Mandatory=$true)]
		[System.Net.IPAddress]$StartRange,
		
		[Parameter(Mandatory=$true)]
		[System.Net.IPAddress]$EndRange,
		
		[Parameter(Mandatory=$true)]
		[System.Net.IPAddress]$SubnetMask,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present",
		
		[UInt16]$Delay,
		
		[String]$Description,
		
		[TimeSpan]$LeaseDuration,
		
		[UInt32]$MaxBootpClients,
		
		[Switch]$NapEnable,
		
		[String]$NapProfile,
		
		[ValidateSet("Active","Inactive")]
		[String]$State,
		
		[String]$SuperscopeName,
		
		[ValidateSet("Dhcp","Bootp","Both")]
		[String]$Type = "Dhcp"
	)
	$UpdateParams = @{}
	if($PSBoundParameters.ContainsKey("Name") -and $Scope.Name -ne $Name) {
		$UpdateParams.Add("Name", $Name)
	}
	
	#Start and end ranges must be specified together
	if( ($PSBoundParameters.ContainsKey("StartRange") -and $Scope.StartRange -ne $StartRange) -or
			($PSBoundParameters.ContainsKey("EndRange") -and $Scope.EndRange -ne $EndRange)
		) {
		$UpdateParams.Add("StartRange", $StartRange)
		$UpdateParams.Add("EndRange", $EndRange)
	}
	
	if($PSBoundParameters.ContainsKey("SubnetMask") -and $Scope.SubnetMask -ne $SubnetMask) {
		Write-Warning "Subnet mask cannot be changed without recreating scope, not sure what to do here..."
	}
	
	if($PSBoundParameters.ContainsKey("Delay") -and $Scope.Delay -ne $Delay) {
		$UpdateParams.Add("Delay", $Delay)
	}
	
	if($PSBoundParameters.ContainsKey("Description") -and $Scope.Description -ne $Description) {
		$UpdateParams.Add("Description", $Description)
	}
	
	if($PSBoundParameters.ContainsKey("LeaseDuration") -and $Scope.LeaseDuration -ne $LeaseDuration) {
		$UpdateParams.Add("LeaseDuration", $LeaseDuration)
	}
	
	if($PSBoundParameters.ContainsKey("MaxBootpClients") -and $Scope.MaxBootpClients -ne $MaxBootpClients) {
		$UpdateParams.Add("MaxBootpClients", $MaxBootpClients)
	}
	
	if($PSBoundParameters.ContainsKey("NapEnable") -and $Scope.NapEnable -ne $NapEnable) {
		$UpdateParams.Add("NapEnable", $NapEnable)
	}
	
	if($PSBoundParameters.ContainsKey("State") -and $Scope.State -ne $State) {
		$UpdateParams.Add("State", $State)
	}
	
	if($PSBoundParameters.ContainsKey("SuperscopeName") -and $Scope.SuperscopeName -ne $SuperscopeName) {
		$UpdateParams.Add("SuperscopeName", $SuperscopeName)
	}
	
	if($PSBoundParameters.ContainsKey("Type") -and $Scope.Type -ne $Type) {
		$UpdateParams.Add("Type", $Type)
	}
	
	$UpdateParams
}
