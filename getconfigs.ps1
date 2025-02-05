# Jof Keiter
# 3/23/2022

# This script pulls the wifi configuration for all sites

# Variables
    $APIKey  = "#KEY HERE"
    $orgID   = ""
# Functions

    Function merakiAPIcall {
        param (
            [string] $merakiAPIkey
        )

        # Clear headers
            $headers = $null

        # Build headers
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("X-Cisco-Meraki-API-Key", $merakiAPIkey)
        $headers.Add("Content-Type", "application/json")

    }

# get all networks

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Cisco-Meraki-API-Key", $APIKey)

    $response = Invoke-RestMethod "https://api.meraki.com/api/v1/organizations/$($orgid)/networks" -Method 'GET' -Headers $headers
    $response 

    $networks = $response | Sort-Object -Property name

# get all devices

    $response = Invoke-RestMethod "https://api.meraki.com/api/v1/organizations/$($orgid)/networks"  -Method 'GET' -Headers $headers
    $response | ConvertTo-Json

# Loop through networks

    foreach ($network in $networks) {
        #write-output "Network $($network.name) has id $($network.id)"

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("X-Cisco-Meraki-API-Key", $APIKey)
    
        $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($network.id)/appliance/vlans" -Method 'GET' -Headers $headers
        $vlans = $response 
        write-output ""
        write-output ""
        write-output "$($network.name) VLANS:"
        $vlans | select-object id,subnet,name | ft

        #foreach ($vlan in $vlans) {
           # $vlan | select-object id,subnet,name | ft
            #Write-Output "Name: $($vlan.name)"
           # write-output "ID:  $($vlan.id)"
            #write-output "Subnet: $($vlan.subnet)"
       # }
    }

# get all vlans

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Cisco-Meraki-API-Key", $APIKey)

    $response = Invoke-RestMethod 'https://api.meraki.com/api/v1/networks//appliance/vlans' -Method 'GET' -Headers $headers
    $response | ConvertTo-Json

# get all wireless configuration

    # get ssids

        foreach ($network in $networks) {

            if ($network.name -like "*Wireless*") {

                $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
                $headers.Add("X-Cisco-Meraki-API-Key", $APIKey)
            
                $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($network.id)/wireless/ssids" -Method 'GET' -Headers $headers

                $SSIDs = $response
                write-output "" | Out-File wifi.txt -append
                write-output "******************************" | Out-File wifi.txt -append
                write-output "" | Out-File wifi.txt -append
                write-output "$($network.name) SSIDs: " | Out-File wifi.txt -append
                
                foreach ($ssid in $SSIDs) {
                    if ($ssid.enabled -eq "True")  {
                        $ssid | fl | Out-File wifi.txt -append
                    }
                }
            }
        } 

    # get firewall/traffic shaping rules
    foreach ($network in $networks) {
        $filename = "site001.txt"

        if ($network.name -like "*Wireless*") {

            write-output "" | Out-File $filename -append

            write-output "******************************" | Out-File $filename -append
            write-output "" | Out-File $filename -append
            write-output "$($network.name) SSIDs: " | Out-File $filename -append

            foreach ($SSID in $SSIDs) {
                if ($ssid.enabled -eq "True")  {
                    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
                    $headers.Add("X-Cisco-Meraki-API-Key", $APIKey)

                    write-output "$($ssid.name) Splash Settings: " | Out-File $filename -append
                    #$ssidnum = $ssid.number
                    
                    # TEMP USE
                        $networkid = "L_707628091450592890"
                        $ssidnum = "0"

                    $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkid)/wireless/ssids/$($ssidnum)/splash/settings" -Method 'GET' -Headers $headers
                    $splash = $response
                    $splash | fl | Out-File $filename -append

                    write-output "$($ssid.name) Schedule: " | Out-File $filename -append

                    $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkid)/wireless/ssids/$($ssidnum)/schedules" -Method 'GET' -Headers $headers
                    $schedule = $response
                    $schedule | fl | Out-File $filename -append

                    $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkid)/wireless/ssids/$($ssidnum)/trafficShaping/rules" -Method 'GET' -Headers $headers
                    $response | ConvertTo-Json
                    $tsrules = $response
                    write-output "$($ssid.name) Rules: " | Out-File $filename -append
                    $tsrules | fl | Out-File $filename -append
                }

            }
                             
        }
    }

    # get splash page config


    # get SSID availability $