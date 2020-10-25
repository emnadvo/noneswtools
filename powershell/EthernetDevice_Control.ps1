#Disable  all network adapter
#$Computer = "."
#$net = Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $computer
#$netenabled = $net | where {$_.IPenabled}
#foreach ($NetCard in $netenabled) {
#    "Releasing lease on: {0}" -f $netcard.caption
# $netcard.ReleaseDHCPLease()
#}

#Enable all network adapter
#$Computer = "."
#$net = Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $computer
#$netenabled = $net | where {$_.IPenabled}
#foreach ($NetCard in $netenabled) {
#    "Renewing lease on: {0}" -f $netcard.caption
# $netcard.RenewDHCPLease()
}

#$Computer = "."
#$net = Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $computer
#$netenabled = $net | where {$_.IPenabled}
#foreach($NetCard in $netenabled) {
#    "IP: {0}" -f $netcard.IPAddress
#    "Adapter  name: {0}" -f $netcard.ServiceName
#    "Other: {0}" -f $netcard.Description
#    }


#Disable
$Computer = "."
$net = Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $computer
$netenabled = $net | where {$_.IPenabled}
foreach($NetCard in $netenabled) {
    if($netcard.ServiceName.Contains('rt640x64'))
    {
        "Adapter {0} disabled." -f $NetCard.Description
        $netcard.ReleaseDHCPLease()
    }
}


#Enable
$Computer = "."
$net = Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $computer
$netenabled = $net | where {$_.IPenabled}
foreach($NetCard in $netenabled) {
    if($netcard.ServiceName.Contains('rt640x64'))
    {
        "Adapter {0} disabled." -f $NetCard.Description
        $netcard.RenewDHCPLease()
    }
}