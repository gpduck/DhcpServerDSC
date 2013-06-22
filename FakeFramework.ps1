

function Configuration {
	param(
		$Name,
		$ScriptBlock
	)
	$ConfigTemplate = @"
	function Global:$Name {{
		param( `$ConfigurationData )
		`$StarNode = `$ConfigurationData.AllNodes | ?{{`$_.NodeName -eq "*"}}
		`$AllNodes = `$ConfigurationData.AllNodes | ?{{`$_.NodeName -ne "*"}} | %{{
			`$NamedNode = `$_
			if(`$StarNode) {{
				`$StarNode.Keys | ?{{`$_ -ne "NodeName"}} | %{{
					if(!`$NamedNode.ContainsKey(`$_)) {{
						`$NamedNode[`$_] = `$StarNode[`$_];
					}}
				}}
			}}
			`$NamedNode
		}}
		{0}
	}}
"@
	$ConfigScript = $ConfigTemplate -f $ScriptBlock.ToString()
	Invoke-Expression $ConfigScript
}

function Node {
	param(
		$NodeList,
		$ScriptBlock
	)
	$NodeList | ?{$_.NodeName -eq "$Env:ComputerName"} | %{
		$Node = $_
		Invoke-Expression $ScriptBlock.ToString()
	}
}

function WindowsFeature {
	param(
		$Name,
		$Parameters
	)
	#Do nothing
}

function DhcpV4SettingDSC {
	param(
		$Name,
		$Parameters
	)
	$Parameters.Remove("Requires") > $null
	
	$Provider = Import-Module DhcpSettingDSC -Force -AsCustomObject -ErrorAction Stop
	Write-Debug "[DSC Fake] Invoking DhcpSettingDSC on $Name"
	if(-not (&$Provider."Test-TargetResource".Script @Parameters) ) {
		&$Provider."Set-TargetResource".Script @Parameters
	}
}

function DhcpV4ClassDSC {
	param(
		$Name,
		$Parameters
	)
	$Parameters.Remove("Requires") > $null
	
	$Provider = Import-Module DhcpV4ClassDSC -Force -AsCustomObject -ErrorAction Stop
	Write-Debug "[DSC Fake] Invoking DhcpV4ClassDSC on $Name"
	if(-not (&$Provider."Test-TargetResource".Script @Parameters) ) {
		&$Provider."Set-TargetResource".Script @Parameters
	}
}

function DhcpV4OptionDefinitionDSC {
	param(
		$Name,
		$Parameters
	)
	$Parameters.Remove("Requires") > $null
	
	$Provider = Import-Module DhcpV4OptionDefinitionDSC -Force -AsCustomObject -ErrorAction Stop
	Write-Debug "[DSC Fake] Invoking DhcpV4OptionDefinitionDSC on $Name"
	if(-not (&$Provider."Test-TargetResource".Script @Parameters) ) {
		&$Provider."Set-TargetResource".Script @Parameters
	}
}

function DhcpV4OptionValueDSC {
	param(
		$Name,
		$Parameters
	)
	$Parameters.Remove("Requires") > $null
	
	$Provider = Import-Module DhcpV4OptionValueDSC -Force -AsCustomObject -ErrorAction Stop
	Write-Debug "[DSC Fake] Invoking DhcpV4OptionValueDSC on $Name"
	if(-not (&$Provider."Test-TargetResource".Script @Parameters) ) {
		&$Provider."Set-TargetResource".Script @Parameters
	}
}

function DhcpV4ScopeDSC {
	param(
		$Name,
		$Parameters
	)
	$Parameters.Remove("Requires") > $null
	
	$Provider = Import-Module DhcpV4ScopeDSC -Force -AsCustomObject -ErrorAction Stop
	Write-Debug "[DSC Fake] Invoking DhcpV4ScopeDSC on $Name"
	if(-not (&$Provider."Test-TargetResource".Script @Parameters) ) {
		&$Provider."Set-TargetResource".Script @Parameters
	}
}

function DhcpV6ScopeDSC {
	param(
		$Name,
		$Parameters
	)
	$Parameters.Remove("Requires") > $null
	
	$Provider = Import-Module DhcpV6ScopeDSC -Force -AsCustomObject -ErrorAction Stop
	Write-Debug "[DSC Fake] Invoking DhcpV6ScopeDSC on $Name"
	if(-not (&$Provider."Test-TargetResource".Script @Parameters) ) {
		&$Provider."Set-TargetResource".Script @Parameters
	}
}