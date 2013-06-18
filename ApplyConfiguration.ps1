	param(
		$ProviderName,
		$Configuration
	)
	$Provider = Import-Module $ProviderName -Force -AsCustomObject -ErrorAction Stop
	
	$ProviderMethods = Get-Member -InputObject $Provider -MemberType Methods | Select-Object -ExpandProperty Name
	if($ProviderMethods -notcontains "Test-TargetResource") {
		Write-Error "$ProviderName must implement Test-TargetResource"
		return
	}
	if($ProviderMethods -notcontains "Get-TargetResource") {
		Write-Error "$ProviderName must implement Get-TargetResource"
		return
	}
	if($ProviderMethods -notcontains "Set-TargetResource") {
		Write-Error "$ProviderName must implement Set-TargetResource"
		return
	}
	
	if(-not (&$Provider."Test-TargetResource".Script @Configuration) ) {
		&$Provider."Set-TargetResource".Script @Configuration
	}