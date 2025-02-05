# Variables

    $APIKey = "#KEY HERE"
    $orgID = ""
    $network = ""
    $serial = ""

# Build Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Cisco-Meraki-API-Key", $APIKey)





#get switch info


$response = Invoke-RestMethod 'https://api.meraki.com/api/v1/devices/$($serial)/switch/ports/4' -Method 'GET' -Headers $headers
$response | Format-Table portId,vlan,poeEnabled,name 

