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
		[String]$Name,
		
		[Parameter(Mandatory=$true)]
		[ValidateSet("Vendor","User")]
		[String]$Type,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$Class = Get-DhcpServerV4Class -Name $Name -Type $Type -ErrorAction SilentlyContinue
	if($Class) {
		$EnsureResult = "Present"
	} else {
		$EnsureResult = "Absent"
	}
	
	@{
		Ensure=$EnsureResult;
		Name=$Class.Name;
		Type=$Class.Type;
		Value=$Class.AsciiData;
		Description=$Class.Description;
	}
}

function Set-TargetResource {
	param(
		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Name,

		[Parameter(Mandatory=$True)]
		[ValidateSet("Vendor","User")]
		[System.String]$Type,

		[Parameter(Mandatory=$False)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Value,

		[Parameter(Mandatory=$False)]
		[System.String]$Description,

		[ValidateSet("Present","Absent")]
		[System.String]$Ensure = "Present"
	)
	$PSBoundParameters.Remove("Debug") > $null
	$PSBoundParameters.Remove("Verbose") > $null
	$Class = Get-DhcpServerV4Class -Name $Name -Type $Type -ErrorAction SilentlyContinue
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($Class) {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			$UpdateParams = GetUpdateParams -Class $Class -BoundParameters $PSBoundParameters
			
			if($UpdateParams.Count -gt 0) {
				Write-Debug "Updating $Type class $Name with $($UpdateParams.Keys -join ', ')"
				Set-DhcpServerV4Class -Name $Name -Type $Type @UpdateParams
			}
		} else {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			#Value is really called -Data, so remove it from splatting
			$PSBoundParameters.Remove("Value") > $null
			Write-Debug "Adding $Type class $Name with $($UpdateParams.Keys -join ', ')"
			Add-DhcpServerV4Class -Data $Value @PsBoundParameters
		}
	} else {
		#Ensure Absent, delete if exists
		if($Class) {
			Write-Debug "Removing $Type class $Name"
			Remove-DhcpServerV4Class -Name $Name -Type $Type -Confirm:$False
		}
	}
}

function Test-TargetResource {
	param(
		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Name,

		[Parameter(Mandatory=$True)]
		[ValidateSet("Vendor","User")]
		[System.String]$Type,

		[Parameter(Mandatory=$False)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Value,

		[Parameter(Mandatory=$False)]
		[System.String]$Description,

		[ValidateSet("Present","Absent")]
		[System.String]$Ensure = "Present"
	)
	$Class = Get-DhcpServerV4Class -Name $Name -Type $Type -ErrorAction SilentlyContinue
	$PSBoundParameters.Remove("Debug") > $null
	$PSBoundParameters.Remove("Verbose") > $null
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($Class) {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			$UpdateParams = GetUpdateParams -Class $Class -BoundParameters $PSBoundParameters
			
			if($UpdateParams.Count -gt 0) {
				Write-Debug "Would update $Type class $Name with $($UpdateParams.Keys -join ', ')"
				$False
			} else {
				$True
			}
		} else {
			#Remove ensure as it's not a scope property
			$PSBoundParameters.Remove("Ensure") > $null
			Write-Debug "Would add $Type class $Name with $($UpdateParams.Keys -join ', ')"
			$false
		}
	} else {
		#Ensure Absent, delete if exists
		if($Class) {
			Write-Debug "Would remove $Type class $Name"
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
		$Class,
		
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$BoundParameters
	)
	$UpdateParams = @{}
	
	$BoundParameters.Keys | ForEach-Object {
		$ParameterName = $_
		if($ParameterName -eq "Value") {
			$ClassParameterName = "AsciiData"
		} else {
			$ClassParameterName = $ParameterName
		}
		if($Class."$ClassParameterName" -ne $BoundParameters[$ParameterName]) {
			$UpdateParams.Add($ParameterName, $BoundParameters[$ParameterName])
		}
	}
	$UpdateParams
}