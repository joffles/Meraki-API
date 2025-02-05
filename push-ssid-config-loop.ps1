# Jof Keiter
# 3/23/2022

# This script sets the wifi configuration for multiple sites

# Use ID 0 for Penny and ID 1 for TM-WIFI

# Variables

    $APIKey  = "#KEY HERE"
    $orgID   = ""
    $networkID = ""
    $header = "X-Cisco-Meraki-API-Key: $($APIkey)"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Cisco-Meraki-API-Key", "#KEY HERE")
    $headers.Add("Content-Type", "application/json")

# Define SSID Configs

    $pennyssid = "{`n     `"name`":`"Penny`",`n    `"enabled`":true,`n    `"splashPage`":`"Click-through splash page`",`n    `"ssidAdminAccessible`":false,`n    `"authMode`":`"open`",`n    `"ipAssignmentMode`":`"Layer 3 roaming`",`n    `"useVlanTagging`":true,`n    `"defaultVlanId`":667,`n    `"adminSplashUrl`":`"`",`n    `"splashTimeout`":`"1440 minutes`",`n    `"walledGardenEnabled`":false,`n    `"minBitrate`":11,`n    `"bandSelection`":`"Dual band operation`",`n    `"perClientBandwidthLimitUp`":25600,`n    `"perClientBandwidthLimitDown`":25600,`n    `"perSsidBandwidthLimitUp`":102400,`n    `"perSsidBandwidthLimitDown`":102400,`n    `"mandatoryDhcpEnabled`":false,`n    `"visible`":true,`n    `"availableOnAllAps`":true,`n    `"availabilityTags`":[],`n    `"speedBurst`":{`"enabled`":false}`n}"
    $tmwifissid = "{`n     `"name`":  `"TM-WIFI`",`n    `"enabled`":  true,`n    `"splashPage`":  `"None`",`n    `"ssidAdminAccessible`":  false,`n    `"authMode`":  `"8021x-radius`",`n    `"dot11w`":  {`n                   `"enabled`":  false,`n                   `"required`":  false`n               },`n    `"dot11r`":  {`n                   `"enabled`":  false,`n                   `"adaptive`":  false`n               },`n    `"encryptionMode`":  `"wpa`",`n    `"wpaEncryptionMode`":  `"WPA2 only`",`n    `"radiusServers`":  [`n        {`n            `"host`": `"13.90.229.234`",`n            `"port`": 10198,`n            `"secret`" :  `"RG92T2ItPz05OS1oJmIlYn0mXip8bWY`"`n                }`n            ],`n    `"radiusAccountingEnabled`":  true,`n    `"radiusAccountingServers`":  [`n        {`n            `"host`": `"13.90.229.234`",`n            `"port`": 10199,`n            `"secret`" :  `"RG92T2ItPz05OS1oJmIlYn0mXip8bWY`"`n                }`n            ],`n    `"radiusTestingEnabled`":  false,`n    `"radiusServerTimeout`":  1,`n    `"radiusServerAttemptsLimit`":  3,`n    `"radiusFallbackEnabled`":  false,`n    `"radiusAccountingInterimInterval`":  600,`n    `"radiusProxyEnabled`":  false,`n    `"radiusCoaEnabled`":  false,`n    `"radiusCalledStationId`":  `"`$NODE_MAC`$:`$VAP_NAME`$`",`n    `"radiusAuthenticationNasId`":  `"`$NODE_MAC`$:`$VAP_NUM`$`",`n    `"radiusAttributeForGroupPolicies`":  `"Filter-Id`",`n    `"radiusFailoverPolicy`":  `"Deny Access`",`n    `"radiusLoadBalancingPolicy`":  `"Round robin`",`n    `"ipAssignmentMode`":  `"Layer 3 roaming`",`n    `"useVlanTagging`":  true,`n    `"defaultVlanId`":  666,`n    `"radiusOverride`":  false,`n    `"minBitrate`":  11,`n    `"bandSelection`":  `"Dual band operation`",`n    `"perClientBandwidthLimitUp`":  51200,`n    `"perClientBandwidthLimitDown`":  51200,`n    `"perSsidBandwidthLimitUp`":  256000,`n    `"perSsidBandwidthLimitDown`":  256000,`n    `"mandatoryDhcpEnabled`":  false,`n    `"visible`":  false,`n    `"availableOnAllAps`":  true,`n    `"availabilityTags`":  [`n`n                         ],`n    `"speedBurst`":  {`n                       `"enabled`":  false`n                   }`n}"
    
# Define splash page config
  
    $pennysplash = "{`n    `"useSplashUrl`": false,`n    `"splashTimeout`": 1440,`n    `"useRedirectUrl`": false,`n    `"welcomeMessage`": `"Guest wireless Internet service for GESA Credit Union members.`",`n    `"splashLogo`": {`n        `"md5`": `"17017dbf473e3d29e705f56b2d1dc735`",`n        `"extension`": `"jpg`"`n    },`n    `"blockAllTrafficBeforeSignOn`": true,`n    `"controllerDisconnectionBehavior`": `"default`",`n    `"allowSimultaneousLogins`": true,`n    `"guestSponsorship`": {`n        `"durationInMinutes`": 1440,`n        `"guestCanRequestTimeframe`": false`n    },`n    `"billing`": {`n        `"freeAccess`": {`n            `"enabled`": false,`n            `"durationInMinutes`": 20`n        },`n        `"prepaidAccessFastLoginEnabled`": false`n    }`n}"

# Loop

    foreach ($network in $networkstoupdate) {
        # Push SSID/Splash Config. Note: Try/catch routines are needed to capture errors
        # Penny
        Try {
            # SSID Config
                $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($network.id)/wireless/ssids/0" -Method 'PUT' -Headers $headers -Body $pennyssid
                write-output $response

            # Splash Config
                $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($network.id)/wireless/ssids/0/splash/settings" -Method 'PUT' -Headers $headers -Body $pennysplash -Verbose
                $response | ConvertTo-Json

            } Catch {
                    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                    $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                    $streamReader.Close()
            }

        write-output $ErrResp

    # TMWIFI
        Try {
            # SSID Config
                $response = Invoke-RestMethod "https://api.meraki.com/api/v1/networks/$($networkid)/wireless/ssids/1" -Method 'PUT' -Headers $headers -Body $tmwifissid
                write-output $response

            } Catch {
                    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                    $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                    $streamReader.Close()
            }

        write-output $ErrResp


    }

    
  # add firewall rules
  # disable traffic shaping
  # penny schedule