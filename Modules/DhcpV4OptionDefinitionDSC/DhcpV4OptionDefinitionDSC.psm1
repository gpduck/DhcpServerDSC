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
		[System.String]$VendorClass,

		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$PSBoundParameters.Remove("Debug") > $null
	$PSBoundParameters.Remove("Verbose") > $null
	$PSBoundParameters.Remove("Ensure") > $null
	$OptionDef = Get-DhcpServerV4OptionDefinition @PsBoundParameters -ErrorAction SilentlyContinue
	if($OptionDef) {
		$EnsureResult = "Present"
	} else {
		$EnsureResult = "Absent"
	}
	
	@{
		Ensure=$EnsureResult;
		OptionId=$OptionDef.OptionId;
		Name=$OptionDef.Name;
		Description=$OptionDef.Description;
		Type=$OptionDef.Type;
		MultiValued=$OptionDef.MultiValued;
		DefaultValue=$OptionDef.DefaultValue;
		VendorClass=$OptionDef.VendorClass;
	}
}

function Set-TargetResource {
	param(
		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Name,

		[Parameter(Mandatory=$False)]
		[System.String]$Description,

		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.UInt32]$OptionId,

		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[ValidateSet("Byte","Word","DWord","DWordDWord","IPv4Address","String","BinaryData","EncapsulatedData")]
		[System.String]$Type,

		[Parameter(Mandatory=$False)]
		[ValidateNotNullOrEmpty()]
		[Switch]$MultiValued,

		[Parameter(Mandatory=$False)]
		[System.String]$VendorClass,

		[Parameter(Mandatory=$False)]
		[System.String[]]$DefaultValue,

		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$PSBoundParameters.Remove("Debug") > $null
	$PSBoundParameters.Remove("Verbose") > $null
	$PSBoundParameters.Remove("Ensure") > $null
	$OptionDef = Get-DhcpServerV4OptionDefinition -OptionId $OptionId -VendorClass $VendorClass -ErrorAction SilentlyContinue
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($OptionDef) {
			$NeedToAdd = $false
			#Test the things we can't fix with set first, if they don't match we'll have to remove/add
			if($OptionDef.Type -ne $Type) {
				$NeedToAdd = $true
			}
			if($OptionDef.MultiValued -ne $MultiValued) {
				$NeedToAdd = $true
			}
			if($NeedToAdd) {
				Write-Debug "Remove/add optiondef $VendorClass\$OptionId to change Type or MultiValued"
				Remove-DhcpServerV4OptionDefinition -OptionId $OptionId -VendorClass $VendorClass
				#This by definition will take care of the remaining properties, no need to test
				Add-DhcpServerV4OptionDefinition @PSBoundParameters
			} else {
				$PSBoundParameters.Remove("MultiValued") > $null
				$PSBoundParameters.Remove("Type") > $null
				$UpdateParams = GetUpdateParams -Def $OptionDef -BoundParameters $PSBoundParameters
				
				if($UpdateParams.Count -gt 0) {
					Write-Debug "Updating optiondef $VendorClass\$OptionDef with $($UpdateParams.Keys -join ', ')"
					Set-DhcpServerV4OptionDefinition -OptionId $OptionId -VendorClass $VendorClass @UpdateParams
				}
			}
		} else {
			Write-Debug "Adding optiondef $VendorClass\$OptionId"
			Add-DhcpServerV4OptionDefinition @PSBoundParameters
		}
	} else {
		if($OptionDef) {
			Write-Debug "Removing optiondef $VendorClass\$OptionId"
			Remove-DhcpServerV4OptionDefinition -OptionId $OptionId -VendorClass $VendorClass
		}
	}
}

function Test-TargetResource {
	param(
		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.String]$Name,

		[Parameter(Mandatory=$False)]
		[System.String]$Description,

		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.UInt32]$OptionId,

		[Parameter(Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[ValidateSet("Byte","Word","DWord","DWordDWord","IPv4Address","String","BinaryData","EncapsulatedData")]
		[System.String]$Type,

		[Parameter(Mandatory=$False)]
		[ValidateNotNullOrEmpty()]
		[Switch]$MultiValued,

		[Parameter(Mandatory=$False)]
		[System.String]$VendorClass,

		[Parameter(Mandatory=$False)]
		[System.String[]]$DefaultValue,

		[ValidateSet("Present","Absent")]
		[String]$Ensure = "Present"
	)
	$PSBoundParameters.Remove("Debug") > $null
	$PSBoundParameters.Remove("Verbose") > $null
	$PSBoundParameters.Remove("Ensure") > $null
	$OptionDef = Get-DhcpServerV4OptionDefinition -OptionId $OptionId -VendorClass $VendorClass -ErrorAction SilentlyContinue
	if($Ensure -eq "Present") {
		#Ensure Present, create or update as needed
		if($OptionDef) {
			$NeedToAdd = $false
			#Test the things we can't fix with set first, if they don't match we'll have to remove/add
			if($OptionDef.Type -ne $Type) {
				$NeedToAdd = $true
			}
			if($OptionDef.MultiValued -ne $MultiValued) {
				$NeedToAdd = $true
			}
			if($NeedToAdd) {
				Write-Debug "Would remove/add optiondef $VendorClass\$OptionId to change Type or MultiValued"
				$false
			} else {
				$PSBoundParameters.Remove("MultiValued") > $null
				$PSBoundParameters.Remove("Type") > $null
				$UpdateParams = GetUpdateParams -Def $OptionDef -BoundParameters $PSBoundParameters
				
				if($UpdateParams.Count -gt 0) {
					Write-Debug "Would update optiondef $VendorClass\$OptionDef with $($UpdateParams.Keys -join ', ')"
					$false
				} else {
					$true
				}
			}
		} else {
			Write-Debug "Would add optiondef $VendorClass\$OptionId"
			$false
		}
	} else {
		if($OptionDef) {
			Write-Debug "Would remove optiondef $VendorClass\$OptionId"
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

function GetUpdateParams {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$Def,
		
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$BoundParameters
	)
	$UpdateParams = @{}
	
	$BoundParameters.Keys | ForEach-Object {
		$ParameterName = $_
		if($ParameterName -eq "DefaultValue") {
			#use array comparison for DefaultValue parameter
			if( -not (ArraysAreEqual -A $Def.DefaultValue -B $BoundParameters["DefaultValue"]) ) {
				$UpdateParams.Add($ParameterName, $BoundParameters[$ParameterName])
			}
		} else {
			if($Def."$ParameterName" -ne $BoundParameters[$ParameterName]) {
				$UpdateParams.Add($ParameterName, $BoundParameters[$ParameterName])
			}
		}
	}
	$UpdateParams
}