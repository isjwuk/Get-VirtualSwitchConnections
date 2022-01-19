# Get-VirtualSwitchConnections

![PowerShell](https://img.shields.io/badge/-PowerShell-blue)
[![PowerCLI](https://img.shields.io/badge/-PowerCLI-yellow)](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.esxi.install.doc/GUID-F02D0C2D-B226-4908-9E5C-2E783D41FE2D.html)

PowerShell/ PowerCLI to identify physical switch ports that VMware ESXi Virtual Switches are connected to, as reported by LLDP. Useful for checking patching of a vSphere environment.

This function returns a table containing the hostname(s), vmnic IDs, virtual distributed switch ids, physical switch name (or MAC address if that's not reported) and port identifiers, and the visible VLAN tags.

## Example Output
```
HostName                Device SwitchName        SwitchPort VirtualSwitch VLANs
--------                ------ ----------        ---------- ------------- -----
myesxihost1.example.com vmnic0 MY-SWITCH-01-B    1/1/1      vDS-Data01    1 3 6 78
myesxihost1.example.com vmnic1 MY-SWITCH-01-A    1/1/2      vDS-Data02    2 4 75 76
myesxihost2.example.com vmnic4 00:01:02:03:04:05 4:19       vDS-Data01    1 3 6 78
```
