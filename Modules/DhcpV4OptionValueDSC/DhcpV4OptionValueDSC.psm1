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
		[Parameter(Mandatory=$True)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.UInt32]$OptionId,
		
		[Parameter(Mandatory=$False)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ScopeId,
		
		[Parameter(Mandatory=$False)]
		[System.String]$PolicyName,
		
		[Parameter(Mandatory=$False)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ReservedIP,
		
		[Parameter(Mandatory=$False)]
		[System.String]$VendorClass,
		
		[Parameter(Mandatory=$False)]
		[System.String]$UserClass,

		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$PSBoundParameters.Remove("Ensure") > $null
	$OptionValue = Get-DhcpServerV4OptionValue @PsBoundParameters -ErrorAction SilentlyContinue
	if($OptionValue) {
		$EnsureResult = "Present"
	} else {
		$EnsureResult = "Absent"
	}
	
	[PsCustomObject]@{
		Ensure=$EnsureResult;
		OptionId=$OptionValue.OptionId;
		Value=$OptionValue.Value;
		UserClass=$OptionValue.UserClass;
		VendorClass=$OptionValue.VendorClass;
		PolicyName=$OptionValue.PolicyName;
	}
}

function Set-TargetResource {
	param(
		[Parameter(Mandatory=$False)]
		[System.String]$PolicyName,

		[Parameter(Mandatory=$False)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ReservedIP,

		[Parameter(Mandatory=$False)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ScopeId,

		[Parameter(Mandatory=$False)]
		[System.String]$UserClass,

		[Parameter(Mandatory=$False)]
		[System.String]$VendorClass,

		[Parameter(Mandatory=$True)]
		[System.String[]]$Value,

		[Parameter(Mandatory=$True)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.UInt32]$OptionId,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$PSBoundParameters.Remove("Ensure") > $null
	$PSBoundParameters.Remove("Value") > $null
	$OptionValue = Get-DhcpServerV4OptionValue @PSBoundParameters -ErrorAction SilentlyContinue
	
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($OptionValue) {
			if(ArraysAreEqual -A $OptionValue.Value -B $Value) {
				#do nothing
			} else {
				Write-Debug "Updating option $OptionId with value(s) $($Value -join ', ')"
				Set-DhcpServerV4OptionValue -Value $Value @PSBoundParameters
			}
		} else {
			Write-Debug "Adding option $OptionId with value(s) $($Value -join ', ')"
			Set-DhcpServerV4OptionValue -Value $Value @PSBoundParameters
		}
	} else {
		if($OptionValue) {
			Write-Debug "Removing option $OptionId"
			Remove-DhcpServerV4OptionValue @PSBoundParameters
		}
	}
}

function Test-TargetResource {
	param(
		[Parameter(Mandatory=$False)]
		[System.String]$PolicyName,

		[Parameter(Mandatory=$False)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ReservedIP,

		[Parameter(Mandatory=$False)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.Net.IPAddress]$ScopeId,

		[Parameter(Mandatory=$False)]
		[System.String]$UserClass,

		[Parameter(Mandatory=$False)]
		[System.String]$VendorClass,

		[Parameter(Mandatory=$True)]
		[System.String[]]$Value,

		[Parameter(Mandatory=$True)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.UInt32]$OptionId,
		
		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$PSBoundParameters.Remove("Ensure") > $null
	$PSBoundParameters.Remove("Value") > $null
	$OptionValue = Get-DhcpServerV4OptionValue @PSBoundParameters -ErrorAction SilentlyContinue
	
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($OptionValue) {
			if(ArraysAreEqual -A $OptionValue.Value -B $Value) {
				$True
			} else {
				Write-Debug "Would update option $OptionId with value(s) $($Value -join ', ')"
				$False
			}
		} else {
			Write-Debug "Would add option $OptionId with value(s) $($Value -join ', ')"
			$false
		}
	} else {
		if($OptionValue) {
			Write-Debug "Would remove option $OptionId"
			$false
		} else {
			$true
		}
	}
}

function ArraysAreEqual {
	param(
		[Object[]]$A,
		[Object[]]$B
	)
	if($A.Length -eq $B.Length) {
		for($i=0; $i -lt $A.Length; $i++) {
			if($A[$i] -ne $B[$i]) {
				return $false
			}
		}
		return $true
	} else {
		return $false
	}
}