
function Get-ParameterInfo {
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		$Command,
		
		[string]$CommandName
	)
	process {
		if($CommandName) {
			$Command = Get-Command -Name $CommandName
		}
		$Command.Parameters.Keys | ForEach-Object {
			$ParamName = $_
			$Metadata = $Command.Parameters[$ParamName]
			$Out = "" | Select Name,HasValidateNotNullOrEmpty,HasValidateNotNull,ValidateSet,IsCommon,IsMandatory,Type
			$Out.Name = $ParamName
			if($Metadata.ParameterType -eq "System.Management.Automation.SwitchParameter") {
				$Out.Type = "Switch"
			} else {
				$Out.Type = $Metadata.ParameterType
			}
			$Out.HasValidateNotNullOrEmpty = $false
			$Out.HasValidateNotNull = $false
			$Out.ValidateSet = @()
			$Metadata.Attributes | ForEach-Object {
				$Attribute = $_
				switch ($_.GetType().Fullname) {
					"System.Management.Automation.ValidateNotNullAttribute" {
						$Out.HasValidateNotNull = $true
					}
					"System.Management.Automation.ValidateNotNullOrEmptyAttribute" {
						$Out.HasValidateNotNullOrEmpty = $true
					}
					"System.Management.Automation.ValidateSetAttribute" {
						$Out.ValidateSet = $Attribute.ValidValues
					}
					"System.Management.Automation.ParameterAttribute" {
						$Out.IsCommon = $Attribute.ParameterSetName -eq "__AllParameterSets"
						$Out.IsMandatory = $Attribute.Mandatory
					}
				}
			}
			$Out
		}
	}
}

function ConvertTo-ParamBlock {
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		$ParameterInfo
	)
	process {
		if(!$ParameterInfo.IsCommon) {
			$ParameterTemplate = '[Parameter(Mandatory=${0})]'
			$ValidateSetTemplate = '[ValidateSet("{0}")]'
			$ValidateNotNull = "[ValidateNotNull()]"
			$ValidateNotNullOrEmpty = "[ValidateNotNullOrEmpty()]"
			$VariableTemplate = '[{0}]${1},'
			$Sb = New-Object Text.StringBuilder
			$Sb.AppendLine( ($ParameterTemplate -f $ParameterInfo.IsMandatory)) > $null
			if($ParameterInfo.HasValidateNotNull) {
				$Sb.AppendLine($ValidateNotNull) > $null
			}
			if($ParameterInfo.HasValidateNotNullOrEmpty) {
				$Sb.AppendLine($ValidateNotNullOrEmpty) > $null
			}
			if($ParameterInfo.ValidateSet) {
				$Sb.AppendLine( ($ValidateSetTemplate -f ($ParameterInfo.ValidateSet -join '","'))) > $null
			}
			$Sb.AppendLine( ($VariableTemplate -f $ParameterInfo.Type, $ParameterInfo.Name)) > $null
			$Sb.ToString()
		}
	}
}
		
		
#$i = 
Get-Command Set-DhcpServerV4OptionDefinition | Get-ParameterInfo | Convertto-paramblock