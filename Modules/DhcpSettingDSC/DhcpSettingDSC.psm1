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
	
	#Generic settings
	$AuditLog = Get-DhcpServerAuditLog
	$Setting = Get-DhcpServerSetting
	$Database = Get-DhcpServerDatabase
	
	#IpV4 Settings
	$V4DnsSetting = Get-DhcpServerV4DnsSetting
	$V4FilterList = Get-DhcpServerV4FilterList
	
	#IpV6 Settigns
	$V6DnsSetting = Get-DhcpServerV6DnsSetting
	
	
	[PsCustomObject]@{
		AuditLog_Enable = $AuditLog.Enable;
		AuditLog_Path = $AuditLog.Path;
		AuditLog_DiskCheckInterval = $AuditLog.DiskCheckInterval;
		AuditLog_MaxMBFileSize = $AuditLog.MaxMBFileSize;
		AuditLog_MinMBDiskSpace = $AuditLog.MinMBDiskSpace;
		
		Setting_ActivatePolicies = $Setting.ActivatePolicies;
		Setting_ConflictDetectionAttempts = $Setting.ConflictDetectionAttempts;
		Setting_NapEnabled = $Setting.NapEnabled;
		Setting_NpsUnreachableAction = $Setting.NpsUnreachableAction;
		
		Database_FileName = $Database.FileName;
		Database_BackupPath = $Database.BackupPath;
		Database_BackupInterval = $Database.BackupInterval;
		Database_CleanupInterval = $Database.CleanupInterval;
		
		V4DnsSetting_DeleteDnsRROnLeaseExpiry = $V4DnsSetting.DeleteDnsRROnLeaseExpiry;
		V4DnsSetting_DynamicUpdates = $V4DnsSetting.DynamicUpdates;
		V4DnsSetting_NameProtection = $V4DnsSetting.NameProtection;
		V4DnsSetting_UpdateDnsRRForOlderClients = $V4DnsSetting.UpdateDnsRRForOlderClients;
		
		V4FilterList_Allow = $V4FilterList.Allow;
		V4FilterList_Deny = $V4FilterList.Deny;
		
		V6DnsSetting_DynamicUpdates = $V6DnsSetting.DynamicUpdates;
		V6DnsSetting_DeleteDnsRROnLeaseExpiry = $V6DnsSetting.DeleteDnsRROnLeaseExpiry;
		V6DnsSetting_NameProtection = $V6DnsSetting.NameProtection;
	}
}

function Set-TargetResource {
	param(
		[System.UInt32]$AuditLog_DiskCheckInterval,
		
		[System.Boolean]$AuditLog_Enable,
		
		[System.UInt32]$AuditLog_MaxMBFileSize,
		
		[System.UInt32]$AuditLog_MinMBDiskSpace,
		
		[ValidateNotNullOrEmpty()]
		[System.String]$AuditLog_Path,
		
		[System.UInt32]$Database_BackupInterval,
		
		[ValidateNotNullOrEmpty()]
		[System.String]$Database_BackupPath,
		
		[System.UInt32]$Database_CleanupInterval,
		
		[ValidateNotNullOrEmpty()]
		[System.String]$Database_FileName,
		
		[System.Boolean]$Setting_ActivatePolicies,
		
		[System.UInt32]$Setting_ConflictDetectionAttempts,
		
		[System.Boolean]$Setting_NapEnabled,
		
		[ValidateSet("Full","Restricted","NoAccess")]
		[System.String]$Setting_NpsUnreachableAction,
		
		[System.Boolean]$V4DnsSetting_DeleteDnsRROnLeaseExpiry,
		
		[ValidateSet("Always","Never","OnClientRequest")]
		[System.String]$V4DnsSetting_DynamicUpdates,
		
		[System.Boolean]$V4DnsSetting_NameProtection,
		
		[System.Boolean]$V4DnsSetting_UpdateDnsRRForOlderClients,
		
		[System.Boolean]$V4FilterList_Allow,
		
		[System.Boolean]$V4FilterList_Deny,
		
		[System.Boolean]$V6DnsSetting_DeleteDnsRROnLeaseExpiry,
		
		[ValidateSet("Always","Never","OnClientRequest")]
		[System.String]$V6DnsSetting_DynamicUpdates,
		
		[System.Boolean]$V6DnsSetting_NameProtection
	)
	$Target = Get-TargetResource
	
	if($Target) {
		$UpdateParams = GetUpdateParams -BoundParameters $PsBoundParameters -TargetResource $Target
		
		if($UpdateParams.Count -gt 0) {
			$UpdateParams.Keys | Group-Object -Property { $_.Split("_")[0] } | ForEach-Object {
				$CmdletNoun = $_.Name
				$CmdletName = "Set-DhcpServer$CmdletNoun"
				$Cmdlet = Get-Command -Name $CmdletName
				$ParameterKeys = $_.Group
				
				if($Cmdlet) {
					$CmdletParams = @{}
					$ParameterKeys | ForEach-Object {
						$CmdletParams.Add($_.Split("_")[1], $UpdateParams[$_])
					}
					Write-Debug "Using $CmdletName to update $($ParameterKeys -join ', ')"
					$Warnings = ""
					&$Cmdlet @CmdletParams -WarningVariable Warnings
					if($Warnings -match "restart the DHCP server service") {
						Get-Service DHCPServer | Restart-Service -Force -Confirm:$False
					}
				} else {
					Write-Error "Unable to locate $CmdletName to update $($ParameterKeys -join ', ')"
				}
			}
		}
	} else {
		Write-Error "Unable to get DhpcSettings target object"
	}
}

function Test-TargetResource {
	param(
		[System.UInt32]$AuditLog_DiskCheckInterval,
		
		[System.Boolean]$AuditLog_Enable,
		
		[System.UInt32]$AuditLog_MaxMBFileSize,
		
		[System.UInt32]$AuditLog_MinMBDiskSpace,
		
		[ValidateNotNullOrEmpty()]
		[System.String]$AuditLog_Path,
		
		[System.UInt32]$Database_BackupInterval,
		
		[ValidateNotNullOrEmpty()]
		[System.String]$Database_BackupPath,
		
		[System.UInt32]$Database_CleanupInterval,
		
		[ValidateNotNullOrEmpty()]
		[System.String]$Database_FileName,
		
		[System.Boolean]$Setting_ActivatePolicies,
		
		[System.UInt32]$Setting_ConflictDetectionAttempts,
		
		[System.Boolean]$Setting_NapEnabled,
		
		[ValidateSet("Full","Restricted","NoAccess")]
		[System.String]$Setting_NpsUnreachableAction,
		
		[System.Boolean]$V4DnsSetting_DeleteDnsRROnLeaseExpiry,
		
		[ValidateSet("Always","Never","OnClientRequest")]
		[System.String]$V4DnsSetting_DynamicUpdates,
		
		[System.Boolean]$V4DnsSetting_NameProtection,
		
		[System.Boolean]$V4DnsSetting_UpdateDnsRRForOlderClients,
		
		[System.Boolean]$V4FilterList_Allow,
		
		[System.Boolean]$V4FilterList_Deny,
		
		[System.Boolean]$V6DnsSetting_DeleteDnsRROnLeaseExpiry,
		
		[ValidateSet("Always","Never","OnClientRequest")]
		[System.String]$V6DnsSetting_DynamicUpdates,
		
		[System.Boolean]$V6DnsSetting_NameProtection
	)
	$Target = Get-TargetResource
	
	if($Target) {
		$UpdateParams = GetUpdateParams -BoundParameters $PsBoundParameters -TargetResource $Target
		
		if($UpdateParams.Count -gt 0) {
			$false
		} else {
			$true
		}
	} else {
		Write-Error "Unable to get DhpcSettings target object"
	}
}

function GetUpdateParams {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$BoundParameters,
		
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$TargetResource		
	)
	$UpdateParams = @{}
	$BoundParameters.Keys | Foreach-Object {
		$PropertyName = $_
		if($TargetResource."$PropertyName" -ne $BoundParameters[$PropertyName]) {
			$UpdateParams.Add($PropertyName, $BoundParameters[$PropertyName])
		}
	}
	$UpdateParams
}
