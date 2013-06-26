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
		[System.Net.IPAddress]$Prefix,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$Scope = Get-DhcpServerV6Scope -Prefix $Prefix -ErrorAction SilentlyContinue
	if($Scope) {
		$EnsureResult = "Present"
	} else {
		$EnsureResult = "Absent"
	}
	
	@{
		Ensure=$EnsureResult;
		Name=$Scope.Name;
		Prefix=$Scope.Prefix;
		Description=$Scope.Description;
		PreferredLifetime=$Scope.PreferredLifetime;
		Preference=$Scope.Preference;
		State=$Scope.State;
		T1=$Scope.T1;
		T2=$Scope.T2;
		ValidLifetime=$Scope.ValidLifetime;
	}
}

function Set-TargetResource {
	param(
		[System.String]$Description,

		[ValidateSet("Present","Absent")]
		[System.String]$Ensure = "Present",

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Name,

		[ValidateNotNullOrEmpty()]
		[System.UInt16]$Preference,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$Prefix,

		[ValidateSet("Active","Inactive")]
		[System.String]$State,

		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$PreferredLifetime,
		
		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$T1,
		
		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$T2,

		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$ValidLifetime
	)
	$Scope = Get-DhcpServerV6Scope -Prefix $Prefix -ErrorAction SilentlyContinue
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($Scope) {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			$UpdateParams = GetUpdateParams -Scope $Scope -BoundParameters $PSBoundParameters
			
			if($UpdateParams.Count -gt 0) {
				Write-Debug "Updating resource $Prefix with $($UpdateParams.Keys -join ', ')"
				Set-DhcpServerV6Scope -Prefix $Prefix @UpdateParams
			}
		} else {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			Write-Debug "Adding resource $Prefix with $($UpdateParams.Keys -join ', ')"
			Add-DhcpServerV6Scope @PsBoundParameters
		}
	} else {
		#Ensure Absent, delete if exists
		if($Scope) {
			Write-Debug "Removing resource $Prefix"
			Remove-DhcpServerV6Scope -Prefix $Prefix -Force -Confirm:$False
		}
	}
}

function Test-TargetResource {
	param(
		[System.String]$Description,

		[ValidateSet("Present","Absent")]
		[System.String]$Ensure = "Present",

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Name,

		[ValidateNotNullOrEmpty()]
		[System.UInt16]$Preference,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$Prefix,

		[ValidateSet("Active","Inactive")]
		[System.String]$State,

		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$PreferredLifetime,
		
		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$T1,
		
		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$T2,

		[ValidateNotNullOrEmpty()]
		[System.TimeSpan]$ValidLifetime
	)
	$Scope = Get-DhcpServerV6Scope -Prefix $Prefix -ErrorAction SilentlyContinue
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($Scope) {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			$UpdateParams = GetUpdateParams -Scope $Scope -BoundParameters $PSBoundParameters
			
			if($UpdateParams.Count -gt 0) {
				Write-Debug "Would update resource $Prefix with $($UpdateParams.Keys -join ', ')"
				$false
			} else {
				$true
			}
		} else {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			Write-Debug "Would add resource $Prefix with $($UpdateParams.Keys -join ', ')"
			$false
		}
	} else {
		#Ensure Absent, delete if exists
		if($Scope) {
			Write-Debug "Would remove resource $Prefix"
			$false
		} else {
			$true
		}
	}
}

function GetUpdateParams {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$Scope,
		
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$BoundParameters
	)
	$UpdateParams = @{}
	
	$BoundParameters.Keys | ForEach-Object {
		$ParameterName = $_
		if($Scope."$ParameterName" -ne $BoundParameters[$ParameterName]) {
			$UpdateParams.Add($ParameterName, $BoundParameters[$ParameterName])
		}
	}
	$UpdateParams
}
