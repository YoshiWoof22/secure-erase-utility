<# 
////////////////////////////////
PowerShell - Secure Erase Script
////////////////////////////////

Authors: Yannick Schweizer & Tim de Vries
Description: Script capable of securely erasing a given non-boot/non-system drive, done through a quick GUI.

Tools used:
- Testing: VMware Virtual Machine
- GUI Design: POSHGUI, VSCode
- Coding ISE: PS ISE, Notepad++ w. Addons

////////////////////////////////
#>


# Load assemblies for WinForms & WinShell
Add-Type -AssemblyName System.Windows.Forms
$wsh = New-Object -ComObject Wscript.Shell
[System.Windows.Forms.Application]::EnableVisualStyles()

# Because users tend to do things that aren't great (in this case, selecting drives that don't exist), we should suppress the error.
# Please comment the line if you need to debug the Script, should it no longer work:
$ErrorActionPreference= 'silentlycontinue'


# //////////////////////////////
# GUI - Drawing
# Start ////////////////////////


# GUI
$CoreForm                                             = New-Object system.Windows.Forms.Form
$CoreForm.ClientSize                                  = New-Object System.Drawing.Point(400,400)
$CoreForm.text                                        = "Secure Erase Tool"
$CoreForm.TopMost                                     = $false
$CoreForm.FormBorderStyle                             = 'FixedDialog'

$GetDiskButton                                        = New-Object system.Windows.Forms.Button
$GetDiskButton.text                                   = "Get Disks"
$GetDiskButton.width                                  = 120
$GetDiskButton.height                                 = 30
$GetDiskButton.location                               = New-Object System.Drawing.Point(30,30)
$GetDiskButton.Font                                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$QuitAppButton                                        = New-Object system.Windows.Forms.Button
$QuitAppButton.text                                   = "Quit App"
$QuitAppButton.width                                  = 120
$QuitAppButton.height                                 = 30
$QuitAppButton.location                               = New-Object System.Drawing.Point(260,30)
$QuitAppButton.Font                                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DiskListLabel                                        = New-Object system.Windows.Forms.Label
$DiskListLabel.text                                   = "Disk List:"
$DiskListLabel.AutoSize                               = $true
$DiskListLabel.width                                  = 25
$DiskListLabel.height                                 = 10
$DiskListLabel.location                               = New-Object System.Drawing.Point(30,70)
$DiskListLabel.Font                                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DiskTextBox                                          = New-Object system.Windows.Forms.TextBox
$DiskTextBox.multiline                                = $true
$DiskTextBox.width                                    = 350
$DiskTextBox.height                                   = 125
$DiskTextBox.readonly                                 = $true
$DiskTextBox.location                                 = New-Object System.Drawing.Point(30,90)
$DiskTextBox.Font                                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$DiskTextBox.Scrollbars                               = "Vertical"

$DiskNumberTextBox                                    = New-Object system.Windows.Forms.NumericUpDown 
$DiskNumberTextBox.width                              = 45
$DiskNumberTextBox.height                             = 30
$DiskNumberTextBox.location                           = New-Object System.Drawing.Point(140,242)
$DiskNumberTextBox.Font                               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$DiskNumberTextBox.Maximum                            = 255;
$DiskNumberTextBox.Minimum                            = 0;

$DiskSelectionLabel                                   = New-Object system.Windows.Forms.Label
$DiskSelectionLabel.text                              = "Select Disk:"
$DiskSelectionLabel.AutoSize                          = $true
$DiskSelectionLabel.width                             = 25
$DiskSelectionLabel.height                            = 10
$DiskSelectionLabel.location                          = New-Object System.Drawing.Point(50,245)
$DiskSelectionLabel.Font                              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DiskValidationButton                                 = New-Object system.Windows.Forms.Button
$DiskValidationButton.text                            = "Validate Disk"
$DiskValidationButton.width                           = 120
$DiskValidationButton.height                          = 25
$DiskValidationButton.location                        = New-Object System.Drawing.Point(215,241)
$DiskValidationButton.Font                            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DiskValidatedCheckBox                                = New-Object system.Windows.Forms.CheckBox
$DiskValidatedCheckBox.AutoSize                       = $false
$DiskValidatedCheckBox.width                          = 20
$DiskValidatedCheckBox.height                         = 20
$DiskValidatedCheckBox.location                       = New-Object System.Drawing.Point(310,269)
$DiskValidatedCheckBox.Font                           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$DiskValidatedCheckBox.Checked                        = $false
$DiskValidatedCheckBox.Enabled                        = $false

$DiskValidationLabel                                  = New-Object system.Windows.Forms.Label
$DiskValidationLabel.text                             = "Disk Validated:"
$DiskValidationLabel.AutoSize                         = $true
$DiskValidationLabel.width                            = 50
$DiskValidationLabel.height                           = 10
$DiskValidationLabel.location                         = New-Object System.Drawing.Point(215,270)
$DiskValidationLabel.Font                             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DiskEraseButton                                      = New-Object system.Windows.Forms.Button
$DiskEraseButton.text                                 = "Please select/validate a Disk to proceed..."
$DiskEraseButton.Enabled                              = $false
$DiskEraseButton.width                                = 340
$DiskEraseButton.height                               = 50
$DiskEraseButton.location                             = New-Object System.Drawing.Point(30,315)
$DiskEraseButton.Font                                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ShutdownLabel                                        = New-Object system.Windows.Forms.Label
$ShutdownLabel.text                                   = "Shutdown:"
$ShutdownLabel.AutoSize                               = $true
$ShutdownLabel.width                                  = 25
$ShutdownLabel.height                                 = 10
$ShutdownLabel.location                               = New-Object System.Drawing.Point(50,270)
$ShutdownLabel.Font                                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ShutdownCheckBox                                     = New-Object system.Windows.Forms.CheckBox
$ShutdownCheckBox.AutoSize                            = $false
$ShutdownCheckBox.width                               = 20
$ShutdownCheckBox.height                              = 20
$ShutdownCheckBox.location                            = New-Object System.Drawing.Point(155,269)
$ShutdownCheckBox.Font                                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$ShutdownCheckBox.Checked                             = $false

$DiskEraseLabel                                       = New-Object system.Windows.Forms.Label
$DiskEraseLabel.text                                  = "Erase Disk:"
$DiskEraseLabel.AutoSize                              = $true
$DiskEraseLabel.width                                 = 25
$DiskEraseLabel.height                                = 10
$DiskEraseLabel.location                              = New-Object System.Drawing.Point(50,245)
$DiskEraseLabel.Font                                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$EraseProgressBar                                     = New-Object system.Windows.Forms.ProgressBar
$EraseProgressBar.width                               = 219
$EraseProgressBar.height                              = 20
$EraseProgressBar.location                            = New-Object System.Drawing.Point(150,370)
$EraseProgressBar.Style                               = "Marquee"
$EraseProgressBar.MarqueeAnimationSpeed               = 40
$EraseProgressBar.Visible                             = $false

$ProgressLabel                                        = New-Object system.Windows.Forms.Label
$ProgressLabel.text                                   = "Erase in progress..."
$ProgressLabel.AutoSize                               = $true
$ProgressLabel.width                                  = 40
$ProgressLabel.height                                 = 10
$ProgressLabel.location                               = New-Object System.Drawing.Point(30,371)
$ProgressLabel.Font                                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$ProgressLabel.Visible                                = $false

# Add all GUI-Components to the GUI
$CoreForm.controls.AddRange(
@(
$GetDiskButton,
$QuitAppButton,
$DiskListLabel,
$DiskTextBox,
$DiskNumberTextBox,
$DiskSelectionLabel,
$DiskValidationButton,
$DiskEraseButton,
$ShutdownLabel,
$ShutdownCheckBox,
$DiskValidatedCheckBox,
$DiskValidationLabel,
$DiskEraseLabel,
$EraseProgressBar,
$ProgressLabel
))

# End //////////////////////////

# //////////////////////////////
# GUI - Actions & Functions
# Start ////////////////////////

[string[]]$DiskName = ( Get-Disk $DiskNumberTextBox.Value.ToString()).FriendlyName

$QuitAppButton.Add_Click({
    
    # Close Script
    [System.Environment]::Exit(0)

})

$GetDiskButton.Add_Click({
    
    #Get disks, sort them by Number, Format & adjust property names, and then convert to a string for the DiskTextBox
    $DiskList = Get-Disk | Sort-Object -Property Number | Format-List Number, @{Name="Disk Name";Expression={($_.friendlyname)}}, @{Name="Disk Status";Expression={($_.operationalstatus)}}, @{Name="System Drive:";Expression={($_.issystem)}}, @{Name="Bootable Drive:";Expression={($_.isboot)}}, @{Name="S.M.A.R.T.";Expression={($_.healthstatus)}}, @{Name="Total Capacity (GB)";Expression={([math]::round($_.size/1gb, 2))}} | Out-String
    $DiskTextBox.Text = "$DiskList"

    $GetDiskButton.text = "Refresh Disks"

})

$DiskValidationButton.Add_Click({

    # Get all disks & their numeric IDs
    $AvailableDisk = Get-Disk | Select-Object -Property Number -ExcludeProperty FriendlyName, SerialNumber, HealthStatus, OperationalStatus,TotalSize, PartitionStyle  | Where-Object Number –Ge 0
    
    # Get all disks that have Windows installed on them (usually just one disk)
    $SystemDisk = Get-Disk $DiskNumberTextBox.Value.ToString() | Select-Object -Property IsSystem


    if ($AvailableDiskNumbers -notmatch $DiskNumberTextBox.Value -and $SystemDisk -match $false)  {  
        # ^ Check if selected disk exists in the system and is NOT the System Drive
      
        # Enable the button and mark the disk as valid
        $DiskEraseButton.Enabled         = $true
        $DiskValidatedCheckBox.Checked   = $true

        # Set the Erase Button's text to show the selected disk name
        [string[]]$DiskName = ( Get-Disk $DiskNumberTextBox.Value.ToString()).FriendlyName
        $DiskEraseButton.text              = "< ! > Erase Disk " + $DiskNumberTextBox.Value.ToString() + " < ! >`n`r($DiskName)"

    } else {
        
        # Redundant: Disable the button and mark the disk as invalid
        $DiskEraseButton.Enabled         = $false
        $DiskValidatedCheckBox.Checked   = $false
        $DiskEraseButton.text = "Please select/validate a Disk to proceed..."

        # Popup: Disk is invalid, choose another disk
        $wsh.Popup("Error: Disk " + $DiskNumberTextBox.Value.ToString() + " is invalid.`r`Please choose another disk...",0,"Secure Erase Tool // Error ",0+48)

    }

})

$DiskEraseButton.Add_Click({
    
    # Popup: Final confirmation for deleting the selected disk.
    $ErasePopupResult = $wsh.Popup("Are you sure you want to completely erase all partition data on Disk " + $DiskNumberTextBox.Value.ToString() + " (" + $DiskName + ")?`r`nThis CANNOT be undone!",0,"Secure Erase Tool // Confirmation ",1+48)
    
    #write-host $ErasePopupResult
    
    if ($ErasePopupResult -eq 1) {
    # 1 = OK
    # 2 = Cancel
        
        # Button & GUI-Management to prevent tampering
        $DiskValidationButton.Enabled    = $false
        $DiskEraseButton.Enabled         = $false
        $DiskValidatedCheckBox.Checked   = $true
        $ShutdownCheckBox.Enabled        = $false      
        $DiskNumberTextBox.Enabled       = $false

        # Enable the progress bar
        $EraseProgressBar.Visible        = $true
        $ProgressLabel.Visible           = $true

        # Set button text to reflect status
        $DiskEraseButton.text            = "< ! > Disk " + $DiskNumberTextBox.Value.ToString() + " - Secure Erase started... < ! >`n`r($DiskName)"
        
        # Popup: Non-Production Environment Information. This is purely for testing.
        $wsh.Popup("For safety & demonstration reasons, Disk " + $DiskNumberTextBox.Value.ToString() + " (" + $DiskName + ") will NOT be deleted. In a production environment, the data WILL be deleted",0,"Secure Erase Tool // Info ",0+64)
    
    }

    if ($ShutdownCheckBox.Checked -eq $true) {

        # Popup: Inform user of system shutdown
        $wsh.Popup("The system will automatically shut down once " + $DiskName + " has been erased. Press OK to continue.",0,"Secure Erase Tool // Info ",0+64)

        # Delete the disk, but schedule as a background job. Once its done, shutdown the system. Uncomment for full functionality.

        # $DeleteJob = Start-Job { Clear-Disk -Number $DiskNumberTextBox -RemoveData -RemoveOEM }
        # Wait-Job = $DeleteJob

        # Stop-Computer -ComputerName localhost -Force

    } else {
    
        # Delete the disk, but schedule as a background job. Uncomment for full functionality.

        # $DeleteJob = Start-Job { Clear-Disk -Number $DiskNumberTextBox -RemoveData -RemoveOEM }
        # Wait-Job = $DeleteJob

    }

})

# End //////////////////////////

# //////////////////////////////
# GUI - Initialization
# Start ////////////////////////

[void]$CoreForm.ShowDialog()

# End //////////////////////////
