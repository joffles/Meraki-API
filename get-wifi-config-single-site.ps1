# Jof Keiter
# 3/23/2022

# This script pulls the wifi configuration for a single site

# Variables
    $APIKey  = "#KEY HERE"
    $orgID   = ""
    $networkID = ""
    $ssids = 0


# Get SSIDs for the site

    # Call API
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("X-Cisco-Meraki-API-Key", $APIkey)
        $headers.Add("Content-Type", "application/json")
    

    # Get data
        $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkID)/wireless/ssids" -Method 'GET' -Headers $headers

    # Save data to variable
        $ssids = $response

    # Return enabled SSIDs and info

        foreach ($ssid in $ssids) {
            if ($ssid.enabled -eq "True")  {
                write-output $ssid.name

                $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkid)/wireless/ssids/1/splash/settings" -Method 'GET' -Headers $headers
                $splash = $response | ConvertTo-Json
                #$splash | fl 

                $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkid)/wireless/ssids/$($ssid.number)/schedules" -Method 'GET' -Headers $headers
                $schedule = $response
                $schedule | fl 

                $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkid)/wireless/ssids/$($ssid.number)/trafficShaping/rules" -Method 'GET' -Headers $headers
                $trafficshaping = $response
                $trafficshaping | fl 

                Write-Output "*******************************************************************"
            }
        }

