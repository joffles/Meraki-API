# Meraki Port Controller
# Jof Keiter
# 1/24/2022

# This script provides a GUI for security staff to powercycle switch ports to reset unresponsive PoE security cameras

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

    Function switchportinfo {
        param (
            [string] $SWserial
        )

        # Build the REST URL
            $RESTurl = "https://api.meraki.com/api/v1/devices/$SWSerial/clients"

        # Call the Meraki API
           merakiAPIcall -merakiAPIkey #KEY HERE

        # Get the data
            $response = Invoke-RestMethod $RESTurl -Method 'GET' -Headers $headers
    }

    Function switchportList {
        param (
            [string] $SWserial,
            [int] $vlan
        )

        # Set allowed vlan
            $script:allowedvlan = $vlan

        # Clear any old values
            $portdata = $null
            $clientdata = $null
            $ClientAndPortinfo = $null
            $script:UPortName = $null
            $body = $null
            $PortinfoTable.DataSource = $null
            $PortinfoTable.Rows.Clear()

        # Call the Meraki API
            merakiAPIcall -merakiAPIkey #KEY HERE

        # Build the REST URL
            $RESTurlClient              = "https://api.meraki.com/api/v1/devices/$SWSerial/clients"
            $RESTurlData                = "https://api.meraki.com/api/v1/devices/$SWSerial/switch/ports"

            $clientdata                 = Invoke-RestMethod $RESTurlClient -Method 'GET' -Headers $headers
            $portdata                   = Invoke-RestMethod $RESTurlData -Method 'GET' -Headers $headers 

        # Get the data

            # Create Data Tables
                $ClientAndPortinfo = @{}
                $ClientAndPortinfo = New-Object System.Data.Datatable
                $ClientAndPortinfo.Columns.Add("Port")
                $ClientAndPortinfo.Columns.Add("IP")
                $ClientAndPortinfo.Columns.Add("PortName")
                $ClientAndPortinfo.Columns.Add("vlan")
                $ClientAndPortinfo.Columns.Add("mac")

                # Loop through data and merge
                    foreach ($port in $portdata) {
                        $row = $ClientAndPortinfo.NewRow()
                        $row.Port = $port.portId
                        $row.PortName = $port.name
                        $row.vlan = $port.vlan

                        foreach ($client in $clientdata) {
                            if (($port.portId -eq $client.switchport)  ) {
                                $row.IP = $client.ip
                                $row.mac = $client.mac
                            }
                    }

                    # Add row to the table
                        $ClientAndPortinfo.Rows.Add($row)
                    }
                
                # Build the data table
                    $PortinfoTable.ColumnHeadersVisible = $true
                    $PortinfoTable.ColumnCount = 5
                    $PortinfoTable.columns[0].Name = "Port"
                    $PortinfoTable.columns[1].Name = "Port Description"
                    $PortinfoTable.columns[2].Name = "IP"
                    $PortinfoTable.columns[3].Name = "MAC"
                    $PortinfoTable.columns[4].Name = "vlan"   

                # Formatting
                    $PortinfoTable.columns[0].Width = 60
                    $PortinfoTable.columns[1].Width = 250
                    $PortinfoTable.columns[2].Width = 100
                    $PortinfoTable.columns[3].Width = 190
                    $PortinfoTable.columns[4].Width = 60
                    $PortinfoTable.ColumnHeadersHeight = 40
                    $PortinfoTable.RowTemplate.Height = 30

                # Merge data into one table
                    foreach ($row in $ClientAndPortinfo){
                        $row = @( 
                            $row.port, 
                            $row.PortName , 
                            $row.IP, 
                            $row.mac,
                            $row.vlan
                            )
                        
                            # Add rows to table
                                $PortinfoTable.Rows.Add($row)
                    }
    }

    Function UpdatePortInfo {
        param (
            [string]  $SWSerial,
            [string]  $UPortNumber,
            [string]  $UPortName,
            [string]  $vlan
            #[boolean] $UPortEnabled,
            #[string]  $UPortType,
            #[string]  $UPortVlan,
            #[string]  $UPortAllowedVlans,
            #[boolean] $UPortPoe,
            #[string]  $UPortAccessPolicyType,
            #[int]     $UPortAccessPolicyNumber
        )
        
        # Meraki API Call

            merakiAPIcall -merakiAPIkey #KEY HERE

        # Build Body
            
            $body = @{
                "name" = $UPortName

            } | ConvertTo-Json

        # Other updatable values to be used later
            
           # `n    `"enabled`": `"$($UPortEnabled)`",
           # `n    `"type`": `"$($UPortType)`",
           # `n    `"vlan`": `"$($UPortVlan)`",
           # `n    `"allowedVlans`": `"$($UPortAllowedVlans)`",
           # `n    `"poeEnabled`": `"$($UPortPoe)`",
           # `n    `"accessPolicyType`": `"$($UPortAccessPolicyType)`",
           # `n    `"accessPolicyNumber`": `"$($UPortAccessPolicyNumber)`",
             

        # Build REST URL
            $RESTUrl = "https://api.meraki.com/api/v1/devices/$SWSerial/switch/ports/$($UPortNUmber)"

             # Execute   
             ExecuteWithRestrictions -portToModify $UPortNumber -vlan $vlan -method PUT -action updateport

        # Clear variables
            $UPortName = $null
            $body = $null
            $cmd = $null
            $RESTUrl = $null
    }

    Function switchports {
        param (
            [string] $SWserial
        )
        
        # Build the REST URL
            $RESTurl = "https://api.meraki.com/api/v1/devices/$SWSerial/switch/ports/"

        # Call the Meraki API
            merakiAPIcall -merakiAPIkey #KEY HERE
        
        # Get the data
            $response = Invoke-RestMethod $ReSTurl -Method 'GET' -Headers $headers
            $response | Format-Table portid,vlan
        }

    Function cycleport {
        param (
            [string] $SWserial,
            [string] $portToCycle,
            [string] $vlan
        )
      
        # Set Error Action Preference for Try/Catch routine
            $ErrorActionPreference = "stop"

        # Meraki API Call

            merakiAPIcall -merakiAPIkey #KEY HERE

        # Add body of the POST
            $bodyformatted = "{`n    `"ports`": [`"$($portToCycle)`"]`n}"
            $script:body          = $bodyformatted
            
        # Build the REST URL
            $script:RESTurl = "https://api.meraki.com/api/v1/devices/$SWSerial/switch/ports/cycle"

        # Execute   
            ExecuteWithRestrictions -portToModify $portToCycle -vlan $vlan -method POST -action cycleport     
    }   
    
    Function ExecuteWithRestrictions {
        param (
            [string] $portToModify,
            [string] $vlan,
            [string] $method,
            [string] $action
        )

        # Set Error Action Preference for Try/Catch routine
            $ErrorActionPreference = "stop"

        # Execute   
        try {
            if ($vlan -eq $allowedvlan) {
                $cmd = Invoke-RestMethod $RESTurl -Method $method -Headers $headers -Body $body

                 # Change terminal output for selected action
                    if ($action -eq "cycleport") {
                        $Termoutput.Text = "Port $($portToModify) on vlan $($vlan) has been successfully cycled"
                    }

                    if ($action -eq "updateport") {
                        $Termoutput.Text = "Port $($portToModify) values updated"
                    }
                 $Termoutput.Refresh()
            }
            else { 
                write-error "Error! You are only authorized to make changes to ports on vlan $($allowedvlan), not $($vlan)"}
        }
        catch {
             $Termoutput.Text = $_
             $Termoutput.Refresh()
        }

    }

    Function switchchooser{

        $Form.Controls.Add($Button2)
                $Form.Controls.Remove($PortinfoTable)
                $Button2.text = "LOADING"
                $Button2.refresh()
                $SwitchChosen = $switches | Where-Object Name -eq $listBox.SelectedItem
                $PortLabelTop.Text = $SwitchChosen.devname
                $Form.Controls.Add($PortLabelTop)

            # Logic for Switch selection functions
                $script:swserial = $SwitchChosen.serial

            # call switchportlist function
                switchportList -SWserial $swserial -vlan 10         

            # Refresh objects
                $Form.Controls.Add($PortinfoTable)
                $PortinfoTable.refresh()
                $PortLabelTop.Refresh()
                $Button2.text = "Select"
                $Button2.refresh()
    
    }

# Variables

    # Switches

        $switchescsv = ".\cameraswitches.csv"

# Build forms

    # Add necessary .net dependencies
        Add-Type -AssemblyName System.Windows.Forms
    
    # Draw the main form
        $Form                       = New-Object system.Windows.Forms.Form
        $Form.ClientSize            = '1200,800'
        $Form.text                  = "Meraki Port Controller"
        $Form.TopMost               = $false
        $Form.StartPosition         = "CenterScreen"
        $Form.BackColor             = "white"

    # Textbox 1 label
        $textbox1Label              = New-object System.Windows.Forms.Label
        $textbox1Label.text         = "Enter API Key"
        $textbox1Label.Font         = "Calibri, 12"
        $textbox1Label.width        = 150
        $textbox1Label.Height       = 20
        $textbox1Label.Location     = New-Object System.Drawing.Point (30,30)     

    # Textbox 1
        $textbox1                   = New-object System.Windows.Forms.TextBox
        $textbox1.Width             = 300
        $textbox1.Height            = 50
        $textbox1.Location          = New-object System.Drawing.Point (170,30)
    
    # Textbox 2
        $textbox2                   = New-object System.Windows.Forms.TextBox
        $textbox2.Width             = 280
        $textbox2.Height            = 110
        $textbox2.Location          = New-object System.Drawing.Point (770,184)
        $textbox2.Font              = "Calibri, 16"

    # Terminal Output

        $termOutput                 = New-object System.Windows.Forms.RichTextBox
        $termOutput.Width           = 410
        $termOutput.Height          = 380
        $termOutput.Location        = New-object system.drawing.point (770,230)

    # Dropdown Label
        $dropdownLabel              = New-object System.Windows.Forms.Label
        $dropdownLabel.text         = "Choose device"
        $dropdownLabel.Font         = "Calibri, 12"
        $dropdownLabel.width        = 150
        $dropdownLabel.Height       = 20
        $dropdownLabel.Location     = New-Object System.Drawing.Point (30,60)
        
    # Add dropdown list for device chooser
        $listBox                    = New-Object System.Windows.Forms.ComboBox
        $listBox.Location           = New-Object System.Drawing.Point(170,60)
        $listBox.Size               = New-Object System.Drawing.Size(300,20)
        $listBox.Height             = 20
        $listbox.dropdownheight     = 500
   
    # Port Label Top
        $PortLabelTop               = New-object System.Windows.Forms.Label
        $PortLabelTop.text          = "$($SWChosen.devname) Ports"
        $PortLabelTop.width         = 350
        $PortLabelTop.Height        = 20
        $PortLabelTop.Location      = New-Object System.Drawing.Point (30,100)

    # Select Port
        $SelectPortLabel            = New-object System.Windows.Forms.Label
        $SelectPortLabel.text       = "Select port to cyle"
        $SelectPortLabel.width      = 350
        $SelectPortLabel.Height     = 20
        $SelectPortLabel.Location   = New-Object System.Drawing.Point (700,250)
    
    # Port Info Table
        $PortinfoTable              = New-object System.Windows.Forms.DataGridView
        $PortinfoTable.Width        = 720
        $PortinfoTable.Height       = 500
        $PortinfoTable.Location     = New-Object System.Drawing.Point (30,130)
        $PortinfoTable.Font         = "Calibri, 12"
        $PortinfoTable.BackColor    = "white"
        $PortinfoTable.ReadOnly     = $true
        $PortinfoTable.SelectionMode = "FullRowSelect"
        $PortinfoTable.MultiSelect = $false
        $PortinfoTable.AllowUserToResizeColumns = $false
        $PortinfoTable.AllowUserToResizeRows = $false


    # Button 1
        $Button1                    = New-Object system.Windows.Forms.Button
        $Button1.text               = "Submit"
        $Button1.width              = 70
        $Button1.height             = 20
        $Button1.enabled            = $true
        $Button1.location           = New-Object System.Drawing.Point(480,30)

    # Button 2
        $Button2                    = New-Object system.Windows.Forms.Button
        $Button2.text               = "Select"
        $Button2.width              = 200
        $Button2.height             = 40
        $Button2.BackColor          = "green"
        $Button2.enabled            = $true
        $Button2.location           = New-Object System.Drawing.Point(770,130)
        $Button2.Font               = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::bold)
        $Button2.ForeColor          = "white"

    # Button 3
        $Button3                    = New-Object system.Windows.Forms.Button
        $Button3.width              = 200
        $Button3.height             = 40
        $Button3.BackColor          = "red"
        $Button3.enabled            = $true
        $Button3.location           = New-Object System.Drawing.Point(980,130)
        $Button3.Font               = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::bold)
        $Button3.ForeColor          = "white"

     # Button 4
        $Button4                    = New-Object system.Windows.Forms.Button
        $Button4.text               = "Change Port Desc"
        $Button4.width              = 200
        $Button4.height             = 40
        $Button4.BackColor          = "orange"
        $Button4.enabled            = $true
        $Button4.location           = New-Object System.Drawing.Point(770,180)
        $Button4.Font               = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::bold)
        $Button4.ForeColor          = "white"

    # Button 5
        $Button5                    = New-Object system.Windows.Forms.Button
        $Button5.text               = "Submit"
        $Button5.width              = 120
        $Button5.height             = 40
        $Button5.BackColor          = "orange"
        $Button5.enabled            = $true
        $Button5.location           = New-Object System.Drawing.Point(1060,180)
        $Button5.Font               = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::bold)
        $Button5.ForeColor          = "white"

    # Create the picturebox
        $img                        = [System.Drawing.Image]::Fromfile("\\gesa\netlogon\DNA\DNALauncher\gesalogo.png")
        $pictureBox                 = new-object Windows.Forms.PictureBox
        $pictureBox.Width           = 400
        $pictureBox.Height          = 200
        $pictureBox.Image           = $img
        $pictureBox.Location        = New-Object System.Drawing.Point(800,600)

    # Build the form
        $Form.Controls.Add($textbox1)
        $Form.Controls.Add($listBox)
        $Form.Controls.Add($picturebox)
        $Form.Controls.AddRange(@($textbox1Label,$dropdownLabel))
        $Form.controls.AddRange(@($Button1))

    # Add switches to dropdown list

        $switches = Import-Csv $switchescsv | sort -Property name
        
        foreach ($switch in $switches) {
            [void] $listBox.Items.Add($switch.name)
        }
        
    # Tables

        # Populate the form based on chosen switch
            $listBox.Add_SelectedValueChanged({switchchooser})

    # Selected Cell
        $Button2.Add_Click{
            $Form.Controls.Remove($button3)
            $Form.Controls.Remove($button4)
            $Form.Controls.Remove($button5)
            $Form.Controls.Remove($textbox2)
            $selectedRow            = $PortinfoTable.CurrentRow.Cells["Port"].Value.ToString()
            $selectedRowVlan        = $PortinfoTable.CurrentRow.Cells["vlan"].Value.ToString()
            $script:portToCycle     = $selectedRow
            $script:portToCycleVlan = $selectedRowVlan
            $script:portselected    = $selectedRow
            $script:portselectedVlan= $selectedRowVlan
            $SelectPortLabel.text   = "Port $($selectedRow)  selected"  
            $Button3.text           = "Cycle Port $($selectedRow) Now"
            $Form.Controls.Add($Button3)
            $Form.Controls.Add($Button4)
            $Form.controls.remove($textbox2)
            $textbox2.text = $null
            $button3.Enabled = $true
        }
        
        $Button3.Add_Click{
            $Form.Controls.Add($Termoutput)
            cycleport -SWserial $swserial -portToCycle $portToCycle -vlan $portToCycleVlan
            $button3.Enabled = $false
        }

        $Button4.Add_Click{
            $Form.controls.remove($button4)
            $Form.controls.Add($textbox2)
            $Form.controls.Add($button5)
        }

        $Button5.Add_Click{
            $Form.Controls.Remove($button3)
            $Form.Controls.Remove($button4)
            $Form.Controls.Remove($button5)
            $Form.Controls.Remove($textbox2)
            $Button2.text = "RELOADING"
            $Button2.refresh()
            $UPortName = $textbox2.text
            UpdatePortInfo -SWSerial $swserial -UPortNumber $portselected -UPortName $UPortName -vlan $portselectedVlan
            switchchooser
            $Form.Controls.Add($PortinfoTable)
            $Button2.text = "Select"
            $Button2.refresh()

        }

    # Show the form
        [void]$Form.ShowDialog()