# Jof Keiter
# 6/17/2022
# Update syslog, snmp and netflow configuration on MX devices


# Variables

$APIKey  = "#KEY HERE"
$orgID   = ""
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Cisco-Meraki-API-Key", "#KEY HERE")
$headers.Add("Content-Type", "application/json")
$BaseURL = "https://api.meraki.com/api/v1/"

$errorlog = $null
$count = $null

# Functions
    Function apicall {
        param (
            [string] $method,
            [string] $URL,
            [string] $body
        )

        $URL = $BaseURL+$URL

        if ($body -ne '') {
            Try {
                $script:response = Invoke-RestMethod $URL -Method $method -Headers $headers -Body $body
            
                } Catch {

                    $_
                        $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                        $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                        $streamReader.Close()
                }
            
                 
            $errorlog += "`n$($network.name)`n"
            $errorlog += $ErrResp 

         }
         else {

            Try {
                write-output "$($call)"
                $script:response = Invoke-RestMethod $URL -Method $method -Headers $headers
            
                } Catch {
                    $_
                        $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                        $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                        $streamReader.Close()
                }
            
                $errorlog += "`n$($network.name)`n"
                $errorlog += $ErrResp 
               
         }
    }


    # Get Networks 
        $URL = "organizations/$($orgid)/networks"
        apicall -method "GET" -URL $URL

        $networks = $response | Sort-Object -Property name
        

    foreach ($network in $networks) {
        $count++
        write-output "$($count)/$($networks.count)"

        $networkID = $network.id
        write-output $network.name
        
    # Configure syslog
        $URL = "networks/$($networkID)/syslogServers"
        $data = @{
            "servers"= @(
                @{
                    "host"= "192.168.11.33"
                    "port"= "514"
                    "roles"= @( 
                        "Appliance event log"
                        "Switch event log"
                        "Flows"
                        "URLs"
                        "Security events"
                )
                }
            )
        } | convertto-json -Depth 3
        apicall -URL $URL -method "PUT" -body $data
        write-output "Syslog configured for $($network.name)"

# Configure netflow
    $URL = "networks/$($networkID)/netflow"
    $data = @{
        "reportingEnabled" = "False"
       
    } | convertto-json

    apicall -URL $URL -method "PUT" -body $data
    write-output "Netflow configured for $($network.name)"

# Configure SNMP
    $URL = "networks/$($networkID)/snmp"
    $data = @{
        "access" = "community"
        "communityString"= "G3sa1T1sTheC00l3st"
    } | convertto-json

    apicall -URL $URL -method "PUT" -body $data
    write-output "SNMP configured for $($network.name)"

    }

    $errorlog