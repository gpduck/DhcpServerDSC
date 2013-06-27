@(
	@{
		AuditLog_Enable = $True;
		AuditLog_Path = "C:\Windows\system32\dhcp";
		AuditLog_DiskCheckInterval = 50;
		AuditLog_MaxMBFileSize = 70;
		AuditLog_MinMBDiskSpace = 20;
		Setting_ActivatePolicies = $True;
		Setting_ConflictDetectionAttempts = 0;
		Setting_NapEnabled = $False;
		Setting_NpsUnreachableAction = "Full";
		Database_FileName = "C:\Windows\system32\dhcp\dhcp.mdb";
		Database_BackupPath = "C:\Windows\system32\dhcp\backup";
		Database_BackupInterval = 60;
		Database_CleanupInterval = 60;
		V4DnsSetting_DeleteDnsRROnLeaseExpiry = $True;
		V4DnsSetting_DynamicUpdates = "Always";
		V4DnsSetting_NameProtection = $False;
		V4DnsSetting_UpdateDnsRRForOlderClients = $True;
		V4FilterList_Allow = $False;
		V4FilterList_Deny = $False;
		V6DnsSetting_DynamicUpdates = "OnClientRequest";
		V6DnsSetting_DeleteDnsRROnLeaseExpiry = $True;
		V6DnsSetting_NameProtection = $False;
	}
)
