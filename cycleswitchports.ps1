
#get ports
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Cisco-Meraki-API-Key", "#KEY HERE")

    $response = Invoke-RestMethod 'https://api.meraki.com/api/v1/devices/$($serial)/switch/ports' -Method 'GET' -Headers $headers 
    $portdata = $response

    $response = 0

# get devices on individual port

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Cisco-Meraki-API-Key", "#KEY HERE")

$response = Invoke-RestMethod 'https://api.meraki.com/api/v1/devices/Q2$($serial)/clients' -Method 'GET' -Headers $headers

$clientdata = $response

$response | Where-Object {$_.switchport -eq "1"} | select-object -ExpandProperty ip 

#cycle ports

$headers = 0
$response = 0
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Cisco-Meraki-API-Key", "#KEY HERE")

$response = Invoke-RestMethod 'https://api.meraki.com/api/v1/devices/$($serial)/switch/ports' -Method 'GET' -Headers $headers
$response | Format-Table portid,vlan,poeenabled,enabled,name



# Create Data Tables

$vlan = 221

    $ClientAndPortinfo = @{}
    $ClientAndPortinfo = New-Object System.Data.Datatable
    $ClientAndPortinfo.Columns.Add("Port")
    $ClientAndPortinfo.Columns.Add("IP")
    $ClientAndPortinfo.Columns.Add("PortName")
    $ClientAndPortinfo.Columns.Add("ClientName")
    $ClientAndPortinfo.Columns.Add("vlan")
    $ClientAndPortinfo.Columns.Add("mac")

foreach ($port in $portdata) {

        $row = $ClientAndPortinfo.NewRow()
        $row.Port = $port.portId
        $row.PortName = $port.name
        $row.vlan = $port.vlan

    foreach ($client in $clientdata) {
        if (($port.portId -eq $client.switchport) -and ($client.vlan -eq $vlan) ) {
            $row.IP = $client.ip
            $row.ClientName = $client.ClientName
            $row.mac = $client.mac
        }else {
            #$row.ClientName = "Unavailable"
        }
    }

    $ClientAndPortinfo.Rows.Add($row)
    }



$ClientAndPortinfo | Out-GridView -Title "Meraki Switchport control" -OutputMode Single