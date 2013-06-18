@(
	@{
		DeleteDnsRROnLeaseExpiry = $true;
		DynamicUpdates = "Always" # "Always|Never|OnClientRequest"
		NameProtection = $false;
		UpdateDnsRRForOlderClients = $true;
	}
)