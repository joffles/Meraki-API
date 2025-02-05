# Variables

    $APIKey = "#KEY HERE"
    $orgID = "382706"
    $network = "L_707628091450591654"
    $serial = "Q2KW-QAUA-AJ4P"

# Build Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Cisco-Meraki-API-Key", $APIKey)





#get switch info


$response = Invoke-RestMethod 'https://api.meraki.com/api/v1/devices/Q2KW-QAUA-AJ4P/switch/ports/4' -Method 'GET' -Headers $headers
$response | Format-Table portId,vlan,poeEnabled,name 

