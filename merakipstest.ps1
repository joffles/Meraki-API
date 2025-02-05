$APIKey = "#KEY HERE"
$orgID = ""
$network = ""
$headers = @{
    "X-Cisco-Meraki-API-Key" = $APIKey
}

#get organizations

   # Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/organizations" -Headers $Headers

#get networks

    #$request = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/organizations/$($orgID)/networks" -Headers $Headers

# get devices from $network

$response = Invoke-RestMethod 'https://api.meraki.com/api/v1/devices//switch/ports' -Method 'GET' -Headers $headers
$response | ConvertTo-Json

#format the output

    #$request #| ft id,organizationId,name,productTypes

