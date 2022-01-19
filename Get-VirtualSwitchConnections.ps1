<#
.SYNOPSIS
    Identify Physical Switch Ports that ESXi Virtual Switches are connected to.
.DESCRIPTION
    Identify Physical Switch Ports that ESXi Virtual Switches are connected to. 
    Designed to work with switches which advertise the System Name and Port number via LLDP, or alternatively will return the chassis ID.

    Required PowerCLI
    Connect to vCenter with Connect-VIServer before proceeding

    Only works with NICs connected to Distributed Switches as vSphere does not show LLDP info on standard switched.
.EXAMPLE
    #Return all known Switch Ports in the environment.
    Get-VirtualSwitchConnections
.EXAMPLE
    #Return all known switch ports for a single ESXi host
    Get-VirtualSwitchConnections -HostName myESXiHost.example.com
#>
function Get-VirtualSwitchConnections {
    param(
      #Name of ESXi Host
      [Parameter(Mandatory=$false)]
      [string]
      $HostName
      )
#Check for vCenter Connection      
if (!($Global:DefaultVIServer -and $Global:DefaultVIServer[0].isconnected)){throw "Connect to vCenter first with Connect-VIServer"}

#If Host Not Provided then Get All Hosts
if ($HostName)
{
    $VMHosts=Get-VMHost($HostName)
}else{
    $VMHosts=Get-VMHost
}

#Check each pNIC on each Host in turn
@(Foreach ($VMHost in ($VMHosts | Sort-Object -Property Name)){
	$NetworkSystem=Get-View -id ($VMHost).ExtensionData.Configmanager.Networksystem
	@(Foreach ($PNIC in $NetworkSystem.Networkconfig.pnic)
		{$Device=$NetworkSystem.QueryNetworkHint($pNIC.device)
        
        	#Get the Switch Name, if not the Chassis ID
        	$SwitchName=($Device.LLDPInfo.Parameter| Where-Object {$_.key -eq "System Name"}).Value
        	if (!($SwitchName)){
        	    $SwitchName=$Device.LLDPInfo.ChassisID
        	}

        	#Get the Port Number. A couple of methods again here.
        	$SwitchPort=($Device.LLDPInfo.Parameter| Where-Object {$_.key -eq "Port Description"}).Value
        	if (!($SwitchPort)){
        	    $SwitchPort=$Device.LLDPInfo.PortId
        	}

		$Device | Select-Object @{N="HostName";E={$VMHost.Name}}, `
			Device, `
			@{N="SwitchName";E={$SwitchName}}, `
			@{N="SwitchPort";E={$SwitchPort}}, `
            @{N="VirtualSwitch";E={($NetworkSystem.NetworkInfo.ProxySwitch | Where-Object {$_.Pnic -contains ($NetworkSystem.NetworkInfo.pnic | Where-Object {$_.Device -eq $pnic.device}).Key}).DvSName}}, `
            @{N="VLANs";E={([string]($Device.Subnet.VlanID | sort-object))}}
	}) | Where-Object {$_.Device -ne "vusb0"} # We don't care about the USB Connections
}) | Where-Object {$_.SwitchName } # And remove any blanks
}
