<#
.SYNOPSIS
    IT-ToolBox - Interactive Remote Management Utility

.DESCRIPTION
    Interactive script to manage services and apply fixes on remote computers.
    Current features:
    - Print Spooler service restart
    - Remote Desktop Services restart 
    - Adobe Acrobat DC sign-in fix (registry modification)
    - Advanced MSP Cleanup (disk space recovery from Windows Installer cache)
    - Remote Session Management (view and logoff user sessions)
    - Always shows interactive menu for operation selection (expandable for future features)
    - Prompts for computer name after operation selection
    - Connectivity testing, service status checking, and proper error handling
    - Compatible with PowerShell 5.1 and later

.EXAMPLE
    .\IT-ToolBox.ps1
    Shows interactive menu, then prompts for computer name

.EXAMPLE
    pwsh -File .\IT-ToolBox.ps1
    Run from any PowerShell version

.NOTES
    Author: IT Support Team
    Version: 5.1 - Added continuous operation loop (return to menu after each operation)
    Requires: PowerShell 5.1+, Administrative privileges for remote operations
    Workflow: Menu first → Operation selection → Computer name prompt → Execute → Continue/Exit choice
    Features: Continuous loop allows multiple operations without restarting script
#>

param(
    # No parameters needed - script will prompt for everything
)

# Function to test remote connectivity
function Test-RemoteConnectivity {
    param([string]$Computer)
    
    Write-Host "Testing connectivity to $Computer..." -ForegroundColor Yellow
    
    # Test ping (PS 5.1 compatible)
    try {
        $pingResult = Test-Connection -ComputerName $Computer -Count 2 -Quiet -ErrorAction Stop
        if ($pingResult) {
            Write-Host "[OK] Ping successful" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] Ping failed" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "[FAIL] Ping failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    
    # Test RPC/WMI connectivity
    try {
        $null = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
        Write-Host "[OK] WMI/RPC connectivity successful" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAIL] WMI/RPC connectivity failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to get service status via WMI
function Get-RemoteServiceStatus {
    param(
        [string]$Computer,
        [string]$ServiceName
    )
    
    try {
        $service = Get-WmiObject -Class Win32_Service -ComputerName $Computer -Filter "Name='$ServiceName'" -ErrorAction Stop
        return @{
            Name = $service.Name
            DisplayName = $service.DisplayName
            State = $service.State
            StartMode = $service.StartMode
        }
    } catch {
        Write-Host "Error getting service status for $ServiceName`: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to restart service using SC command
function Restart-RemoteService {
    param(
        [string]$Computer,
        [string]$ServiceName,
        [string]$DisplayName
    )
    
    Write-Host "`nRestarting $DisplayName on $Computer..." -ForegroundColor Cyan
    
    # Stop the service
    Write-Host "Stopping $DisplayName..." -ForegroundColor Yellow
    $stopResult = cmd /c "sc.exe \\$Computer stop $ServiceName 2>&1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Stop command sent successfully" -ForegroundColor Green
        
        # Wait for service to stop (check status)
        Write-Host "Waiting for service to stop..." -ForegroundColor Yellow
        $timeout = 30
        $elapsed = 0
        
        do {
            Start-Sleep -Seconds 2
            $elapsed += 2
            $status = cmd /c "sc.exe \\$Computer query $ServiceName 2>&1"
            
            if ($status -match "STOPPED") {
                Write-Host "[OK] Service stopped successfully" -ForegroundColor Green
                break
            }
            
            if ($elapsed -ge $timeout) {
                Write-Host "[WARN] Service stop timeout - proceeding with start" -ForegroundColor Yellow
                break
            }
        } while ($elapsed -lt $timeout)
        
    } else {
        Write-Host "[WARN] Stop command result: $stopResult" -ForegroundColor Yellow
    }
    
    # Start the service
    Write-Host "Starting $DisplayName..." -ForegroundColor Yellow
    $startResult = cmd /c "sc.exe \\$Computer start $ServiceName 2>&1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Start command sent successfully" -ForegroundColor Green
        
        # Wait for service to start
        Write-Host "Waiting for service to start..." -ForegroundColor Yellow
        $timeout = 30
        $elapsed = 0
        
        do {
            Start-Sleep -Seconds 2
            $elapsed += 2
            $status = cmd /c "sc.exe \\$Computer query $ServiceName 2>&1"
            
            if ($status -match "RUNNING") {
                Write-Host "[OK] Service started successfully" -ForegroundColor Green
                return $true
            }
            
            if ($elapsed -ge $timeout) {
                Write-Host "[WARN] Service start timeout" -ForegroundColor Yellow
                break
            }
        } while ($elapsed -lt $timeout)
        
    } else {
        Write-Host "[FAIL] Start command failed: $startResult" -ForegroundColor Red
        return $false
    }
    
    return $false
}

# Function to show service selection menu
function Show-ServiceSelectionMenu {
    param(
        [array]$AvailableServices
    )
    
    Write-Host "`nAvailable Operations:" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    # Show services without status (since we don't have computer name yet)
    for ($i = 0; $i -lt $AvailableServices.Count; $i++) {
        $service = $AvailableServices[$i]
        Write-Host "$($i + 1). $($service.DisplayName) ($($service.Name))" -ForegroundColor White
        Write-Host "   Description: $($service.Description)" -ForegroundColor Gray
    }
    
    Write-Host "`nOptions:" -ForegroundColor White
    Write-Host "Q. Quit" -ForegroundColor Yellow
    Write-Host "`nInstructions:" -ForegroundColor White
Write-Host "- Enter a single number (1, 2, 3, 4, or 5)" -ForegroundColor Gray
    Write-Host "- Enter 'Q' to quit without making changes" -ForegroundColor Gray
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    do {
        $selection = Read-Host "`nSelect operation to perform (1, 2, 3, 4, 5, or Q to quit)"
        
        # Handle empty or whitespace-only input (PS 5.1 compatible)
        if ($selection -eq $null -or $selection.Trim() -eq "") {
            Write-Host "Please enter a selection." -ForegroundColor Yellow
            continue
        }
        
        if ($selection -eq "Q" -or $selection -eq "q") {
            Write-Host "Operation cancelled by user." -ForegroundColor Yellow
            return $null
        }
        
        # Parse single number selection
        if ($selection -match "^[0-9]+$") {
            $index = [int]$selection - 1
            if ($index -ge 0 -and $index -lt $AvailableServices.Count) {
                # Return single selected service as array
                return @($AvailableServices[$index])
            } else {
                Write-Host "Invalid selection: $selection (valid range: 1-$($AvailableServices.Count))" -ForegroundColor Red
            }
        } else {
            Write-Host "Invalid input: '$selection'. Please enter a single number (1-$($AvailableServices.Count)) or 'Q' to quit." -ForegroundColor Red
        }
        
        Write-Host "Please try again." -ForegroundColor Yellow
        
    } while ($true)
}

# Function to manage remote user sessions
function Invoke-RemoteSessionManagement {
    param(
        [string]$Computer
    )
    
    Write-Host "`nStarting Remote Session Management on $Computer..." -ForegroundColor Cyan
    
    try {
        # Get current user sessions
        Write-Host "Retrieving active user sessions..." -ForegroundColor Yellow
        $qUserOutput = cmd /c "quser /server:$Computer 2>&1"
        
        if ($LASTEXITCODE -ne 0) {
            # Check if it's specifically "No User exists" (no sessions) vs actual error
            if ($qUserOutput -match "No User exists") {
                Write-Host "[INFO] No active user sessions found on $Computer" -ForegroundColor Green
                Write-Host "[INFO] This is normal for servers or workstations with no logged-in users" -ForegroundColor Yellow
                return $true
            } else {
                Write-Host "[FAIL] Cannot retrieve user sessions: $qUserOutput" -ForegroundColor Red
                return $false
            }
        }
        
        # Parse and display sessions
        $sessions = @()
        $lines = $qUserOutput -split "`n" | Where-Object { $_ -match "\S" }
        
        if ($lines.Count -le 1) {
            Write-Host "[INFO] No active user sessions found" -ForegroundColor Green
            return $true
        }
        
        Write-Host "`n[ACTIVE SESSIONS on $Computer]" -ForegroundColor White
        Write-Host ($lines[0]) -ForegroundColor Cyan  # Header
        
        for ($i = 1; $i -lt $lines.Count; $i++) {
            $line = $lines[$i].Trim()
            if ($line) {
                # Parse session info (basic parsing)
                $parts = $line -split "\s+", 6
                if ($parts.Count -ge 3) {
                    $sessionInfo = @{
                        Username = $parts[0]
                        SessionName = if ($parts[1] -match "^\d+$") { "" } else { $parts[1] }
                        ID = if ($parts[1] -match "^\d+$") { $parts[1] } else { $parts[2] }
                        State = if ($parts[1] -match "^\d+$") { $parts[2] } else { $parts[3] }
                        IdleTime = if ($parts[1] -match "^\d+$") { $parts[3] } else { $parts[4] }
                        LogonTime = if ($parts[1] -match "^\d+$") { ($parts[4..5] -join " ") } else { $parts[5] }
                        DisplayLine = $line
                        LineNumber = $i
                    }
                    $sessions += $sessionInfo
                }
                
                # Color code based on state and idle time
                $color = "White"
                if ($line -match "Disc") { $color = "Yellow" }  # Disconnected
                if ($line -match "\d+\+") { $color = "Red" }     # Very old (days+)
                
                Write-Host "$i. $line" -ForegroundColor $color
            }
        }
        
        # Session management options
        Write-Host "`n[SESSION MANAGEMENT OPTIONS]" -ForegroundColor Cyan
        Write-Host "1. Auto-cleanup stale sessions (disconnected 1+ days)" -ForegroundColor White
        Write-Host "2. Manually select sessions to logoff" -ForegroundColor White
        Write-Host "3. View only (no changes)" -ForegroundColor White
        Write-Host "Q. Return to main menu" -ForegroundColor Yellow
        
        do {
            $choice = Read-Host "`nSelect option (1, 2, 3, or Q)"
            
            if ($choice -eq "Q" -or $choice -eq "q") {
                Write-Host "[INFO] Session management cancelled" -ForegroundColor Yellow
                return $true
            }
            
            if ($choice -eq "1") {
                # Auto-cleanup stale sessions
                $staleSessions = $sessions | Where-Object { 
                    $_.State -eq "Disc" -and $_.IdleTime -match "\d+\+" 
                }
                
                if ($staleSessions.Count -gt 0) {
                    Write-Host "`n[STALE SESSIONS FOUND]" -ForegroundColor Yellow
                    Write-Host "These may cause account lockouts due to cached credentials!" -ForegroundColor Yellow
                    
                    foreach ($stale in $staleSessions) {
                        Write-Host "  User: $($stale.Username), ID: $($stale.ID), Idle: $($stale.IdleTime)" -ForegroundColor Red
                    }
                    
                    $cleanup = Read-Host "`nLogoff $($staleSessions.Count) stale session(s)? (Y/N)"
                    if ($cleanup -eq "Y" -or $cleanup -eq "y") {
                        foreach ($stale in $staleSessions) {
                            Write-Host "Logging off session ID $($stale.ID) (User: $($stale.Username))..." -ForegroundColor Yellow
                            $logoffResult = cmd /c "logoff $($stale.ID) /server:$Computer 2>&1"
                            
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "[SUCCESS] Logged off session ID $($stale.ID)" -ForegroundColor Green
                            } else {
                                Write-Host "[WARN] Failed to logoff session ID $($stale.ID): $logoffResult" -ForegroundColor Yellow
                            }
                        }
                    } else {
                        Write-Host "[INFO] Stale session cleanup cancelled" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "`n[SUCCESS] No stale sessions found - all sessions are current" -ForegroundColor Green
                }
                break
            }
            
            if ($choice -eq "2") {
                # Manual session selection
                Write-Host "`n[MANUAL SESSION SELECTION]" -ForegroundColor Cyan
                Write-Host "Available sessions:" -ForegroundColor White
                
                # Show numbered sessions for selection
                for ($i = 0; $i -lt $sessions.Count; $i++) {
                    $session = $sessions[$i]
                    $color = "White"
                    if ($session.State -eq "Disc") { $color = "Yellow" }
                    if ($session.IdleTime -match "\d+\+") { $color = "Red" }
                    
                    Write-Host "$($i + 1). User: $($session.Username), ID: $($session.ID), State: $($session.State), Idle: $($session.IdleTime)" -ForegroundColor $color
                }
                
                do {
                    $selection = Read-Host "`nEnter session number(s) to logoff (comma-separated, or 'C' to cancel)"
                    
                    if ($selection -eq "C" -or $selection -eq "c") {
                        Write-Host "[INFO] Manual session selection cancelled" -ForegroundColor Yellow
                        break
                    }
                    
                    # Parse selection
                    $selectedNumbers = @()
                    try {
                        $parts = $selection -split "," | ForEach-Object { $_.Trim() }
                        foreach ($part in $parts) {
                            if ($part -match "^\d+$") {
                                $num = [int]$part
                                if ($num -ge 1 -and $num -le $sessions.Count) {
                                    $selectedNumbers += ($num - 1)  # Convert to 0-based index
                                } else {
                                    throw "Number $num is out of range (1-$($sessions.Count))"
                                }
                            } else {
                                throw "Invalid input: '$part'"
                            }
                        }
                    } catch {
                        Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
                        Write-Host "Please enter valid session numbers (1-$($sessions.Count)) separated by commas" -ForegroundColor Yellow
                        continue
                    }
                    
                    if ($selectedNumbers.Count -eq 0) {
                        Write-Host "[ERROR] No valid sessions selected" -ForegroundColor Red
                        continue
                    }
                    
                    # Show selected sessions for confirmation
                    Write-Host "`n[SELECTED SESSIONS FOR LOGOFF]" -ForegroundColor Yellow
                    $selectedSessions = @()
                    foreach ($index in $selectedNumbers) {
                        $session = $sessions[$index]
                        $selectedSessions += $session
                        Write-Host "  User: $($session.Username), ID: $($session.ID), State: $($session.State)" -ForegroundColor Red
                    }
                    
                    $confirm = Read-Host "`nProceed to logoff $($selectedSessions.Count) session(s)? (Y/N)"
                    if ($confirm -eq "Y" -or $confirm -eq "y") {
                        foreach ($session in $selectedSessions) {
                            Write-Host "Logging off session ID $($session.ID) (User: $($session.Username))..." -ForegroundColor Yellow
                            $logoffResult = cmd /c "logoff $($session.ID) /server:$Computer 2>&1"
                            
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "[SUCCESS] Logged off session ID $($session.ID)" -ForegroundColor Green
                            } else {
                                Write-Host "[WARN] Failed to logoff session ID $($session.ID): $logoffResult" -ForegroundColor Yellow
                            }
                        }
                    } else {
                        Write-Host "[INFO] Manual session logoff cancelled" -ForegroundColor Yellow
                    }
                    
                    break
                    
                } while ($true)
                
                break
            }
            
            if ($choice -eq "3") {
                # View only
                Write-Host "`n[INFO] View-only mode - no changes made" -ForegroundColor Green
                break
            }
            
            Write-Host "[ERROR] Invalid choice: $choice. Please enter 1, 2, 3, or Q" -ForegroundColor Red
            
        } while ($true)
        
        # Show updated session list if any logoffs were performed
        if ($choice -eq "1" -or $choice -eq "2") {
            Write-Host "`n[UPDATED SESSION LIST]" -ForegroundColor Cyan
            $updatedOutput = cmd /c "quser /server:$Computer 2>&1"
            if ($LASTEXITCODE -eq 0) {
                Write-Host $updatedOutput -ForegroundColor White
            } else {
                Write-Host "No active sessions remaining" -ForegroundColor Green
            }
        }
        
        return $true
        
    } catch {
        Write-Host "[FAIL] Error during session management: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to run Advanced MSP Cleanup
function Invoke-AdvancedMSPCleanup {
    param(
        [string]$Computer
    )
    
    Write-Host "`nStarting Advanced MSP Cleanup on $Computer..." -ForegroundColor Cyan
    
    # Test administrative share access first
    $installerPath = "\\$Computer\C$\Windows\Installer"
    if (-not (Test-Path $installerPath)) {
        Write-Host "[FAIL] Cannot access Windows Installer path: $installerPath" -ForegroundColor Red
        Write-Host "[INFO] Ensure administrative shares are enabled and accessible" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "[OK] Administrative share access confirmed" -ForegroundColor Green
    
    try {
        # Analyze current MSP files
        Write-Host "Analyzing MSP files (this may take a moment)..." -ForegroundColor Yellow
        $allMspFiles = Get-ChildItem $installerPath -Filter "*.msp" -ErrorAction Stop
        $oldDate = (Get-Date).AddDays(-7)  # 7-day aggressive cleanup
        $targetFiles = $allMspFiles | Where-Object {$_.LastWriteTime -lt $oldDate} | Sort-Object Length -Descending
        
        $analysis = @{
            TotalMSPFiles = $allMspFiles.Count
            TotalMSPSizeGB = [math]::Round(($allMspFiles | Measure-Object Length -Sum).Sum/1GB, 2)
            TargetFiles = $targetFiles.Count
            TargetSizeGB = if ($targetFiles) { [math]::Round(($targetFiles | Measure-Object Length -Sum).Sum/1GB, 2) } else { 0 }
        }
        
        Write-Host "[ANALYSIS] Total MSP files: $($analysis.TotalMSPFiles) ($($analysis.TotalMSPSizeGB) GB)" -ForegroundColor White
        Write-Host "[ANALYSIS] Files older than 7 days: $($analysis.TargetFiles) ($($analysis.TargetSizeGB) GB)" -ForegroundColor White
        
        if ($analysis.TargetFiles -eq 0) {
            Write-Host "[SUCCESS] No cleanup needed - all MSP files are recent" -ForegroundColor Green
            return $true
        }
        
        # Confirm cleanup
        Write-Host ""
        $cleanup = Read-Host "Proceed with cleanup of $($analysis.TargetFiles) files ($($analysis.TargetSizeGB) GB)? (Y/N)"
        if ($cleanup -ne "Y" -and $cleanup -ne "y") {
            Write-Host "[INFO] MSP cleanup cancelled by user" -ForegroundColor Yellow
            return $true
        }
        
        # Perform cleanup
        Write-Host "`n[INFO] Starting MSP file cleanup..." -ForegroundColor Cyan
        $deletedCount = 0
        $deletedSize = 0
        
        foreach ($file in $targetFiles) {
            try {
                Remove-Item $file.FullName -Force -ErrorAction Stop
                $deletedSize += $file.Length
                $deletedCount++
                
                if ($deletedCount % 25 -eq 0) {
                    $freedGB = [math]::Round($deletedSize/1GB, 2)
                    Write-Host "[PROGRESS] Deleted $deletedCount files, freed ${freedGB} GB" -ForegroundColor Green
                }
            } catch {
                Write-Host "[WARN] Could not delete $($file.Name): $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        $finalFreedGB = [math]::Round($deletedSize/1GB, 2)
        Write-Host ""
        Write-Host "[SUCCESS] MSP Cleanup completed!" -ForegroundColor Green
        Write-Host "[SUCCESS] Files deleted: $deletedCount" -ForegroundColor Green
        Write-Host "[SUCCESS] Space freed: ${finalFreedGB} GB" -ForegroundColor Green
        
        return $true
        
    } catch {
        Write-Host "[FAIL] Error during MSP cleanup: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to apply Adobe Acrobat DC registry fix
function Set-AdobeRegistryFix {
    param(
        [string]$Computer
    )
    
    Write-Host "`nApplying Adobe Acrobat DC Sign-in Fix on $Computer..." -ForegroundColor Cyan
    
    try {
        # Define the registry path and value
        $regPath = "SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown"
        $name = "bIsSCReducedModeEnforcedEx"
        $value = 1
        $type = "DWORD"
        
        # Connect to remote registry
        Write-Host "Connecting to remote registry..." -ForegroundColor Yellow
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $Computer)
        
        if ($reg -eq $null) {
            Write-Host "[FAIL] Unable to connect to remote registry on $Computer" -ForegroundColor Red
            return $false
        }
        
        Write-Host "[OK] Connected to remote registry" -ForegroundColor Green
        
        # Create the registry key if it doesn't exist
        Write-Host "Creating registry key structure..." -ForegroundColor Yellow
        $key = $reg.OpenSubKey($regPath, $true)
        
        if ($key -eq $null) {
            # Key doesn't exist, create it
            $key = $reg.CreateSubKey($regPath)
            Write-Host "[OK] Created registry key: HKLM\$regPath" -ForegroundColor Green
        } else {
            Write-Host "[OK] Registry key already exists" -ForegroundColor Green
        }
        
        # Set the registry value
        Write-Host "Setting registry value: $name = $value" -ForegroundColor Yellow
        $key.SetValue($name, $value, [Microsoft.Win32.RegistryValueKind]::DWord)
        Write-Host "[OK] Registry value set successfully" -ForegroundColor Green
        
        # Verify the value was set
        $currentValue = $key.GetValue($name)
        if ($currentValue -eq $value) {
            Write-Host "[OK] Verified: $name = $currentValue" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Verification failed: Expected $value, got $currentValue" -ForegroundColor Yellow
        }
        
        # Clean up
        $key.Close()
        $reg.Close()
        
        Write-Host "[SUCCESS] Adobe Acrobat DC sign-in fix applied successfully" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "[FAIL] Error applying Adobe registry fix: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to show service status before and after
function Show-ServiceStatus {
    param(
        [string]$Computer,
        [string[]]$Services
    )
    
    Write-Host "`nService Status on $Computer`:" -ForegroundColor Cyan
    Write-Host ("=" * 50)
    
    foreach ($serviceName in $Services) {
        $status = Get-RemoteServiceStatus -Computer $Computer -ServiceName $serviceName
        if ($status) {
            if ($status.State -eq "Running") {
                $statusColor = "Green"
                $statusPrefix = "[RUNNING]"
            } else {
                $statusColor = "Red"
                $statusPrefix = "[STOPPED]"
            }
            Write-Host "$statusPrefix $($status.DisplayName) ($($status.Name))" -ForegroundColor $statusColor
        }
    }
    Write-Host ""
}

# Main script execution
Write-Host "IT-ToolBox - Remote Management Utility" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Your Complete IT Support Toolkit" -ForegroundColor White

# Define available services (expandable list for future features)
# TO ADD NEW SERVICES: Copy the pattern below and add to this array
$availableServices = @(
    (New-Object PSObject -Property @{
        Name = "Spooler"
        DisplayName = "Print Spooler"
        Description = "Manages print jobs and printer communication"
        Type = "Service"
    }),
    (New-Object PSObject -Property @{
        Name = "TermService"
        DisplayName = "Remote Desktop Services"
        Description = "Enables Remote Desktop connections"
        Type = "Service"
    }),
    (New-Object PSObject -Property @{
        Name = "AdobeFix"
        DisplayName = "Adobe Acrobat DC Sign-in Fix"
        Description = "Applies registry fix to stop Adobe Acrobat DC sign-in prompts"
        Type = "Registry"
    }),
    (New-Object PSObject -Property @{
        Name = "MSPCleanup"
        DisplayName = "Advanced MSP Cleanup"
        Description = "Cleans up old MSP files from Windows Installer cache (can recover 100+ GB)"
        Type = "Custom"
    }),
    (New-Object PSObject -Property @{
        Name = "SessionManagement"
        DisplayName = "Remote Session Management"
        Description = "View active user sessions and logoff stale sessions (prevents account lockouts)"
        Type = "Custom"
    })
    # TO ADD MORE SERVICES, add them here following this pattern:
    # ,(New-Object PSObject -Property @{
    #     Name = "ServiceName"           # Actual Windows service name or custom identifier
    #     DisplayName = "Display Name"   # User-friendly name
    #     Description = "What it does"   # Brief description
    #     Type = "Service"               # "Service" or "Registry" or "Custom"
    # })
)

# Main execution loop
do {
    # Step 1: Show operation selection menu
    Write-Host "`nStep 1: Select operation to perform" -ForegroundColor Magenta
    $servicesToRestart = Show-ServiceSelectionMenu -AvailableServices $availableServices
    
    if ($servicesToRestart -eq $null -or $servicesToRestart.Count -eq 0) {
        Write-Host "Exiting IT-ToolBox. Thank you!" -ForegroundColor Cyan
        break
    }
    
    Write-Host "`nSelected operation:" -ForegroundColor Green
    Write-Host "  - $($servicesToRestart[0].DisplayName) ($($servicesToRestart[0].Name))" -ForegroundColor White
    
    # Step 2: Get computer name
    Write-Host "`nStep 2: Specify target computer" -ForegroundColor Magenta
    do {
        $ComputerName = Read-Host "Enter the target computer name or IP address"
        
        if ($ComputerName -eq $null -or $ComputerName.Trim() -eq "") {
            Write-Host "Please enter a valid computer name or IP address." -ForegroundColor Red
            continue
        }
        
        break
    } while ($true)
    
    Write-Host "`nTarget Computer: $ComputerName" -ForegroundColor White
    
    # Step 3: Confirm before proceeding
    Write-Host "`nStep 3: Final confirmation" -ForegroundColor Magenta
    $confirmation = Read-Host "Proceed with '$($servicesToRestart[0].DisplayName)' on '$ComputerName'? (Y/N)"
    if ($confirmation -ne "Y" -and $confirmation -ne "y") {
        Write-Host "Operation cancelled by user." -ForegroundColor Yellow
        continue
    }
    
    # Step 4: Test connectivity
    Write-Host "`nStep 4: Testing connectivity" -ForegroundColor Magenta
    if (-not (Test-RemoteConnectivity -Computer $ComputerName)) {
        Write-Host "`nCannot connect to $ComputerName." -ForegroundColor Red
        
        Write-Host "`n[CONTINUE OPTIONS]" -ForegroundColor Yellow
        $continueChoice = Read-Host "Return to main menu? (Y/N)"
        if ($continueChoice -eq "Y" -or $continueChoice -eq "y") {
            continue
        } else {
            Write-Host "Exiting IT-ToolBox. Thank you!" -ForegroundColor Cyan
            break
        }
    }
    
    # Step 5: Execute operations
    Write-Host "`nStep 5: Executing operations" -ForegroundColor Magenta
    
    # Separate services, registry operations, and custom operations
    $services = $servicesToRestart | Where-Object { $_.Type -eq "Service" -or $_.Type -eq $null }
    $registryOps = $servicesToRestart | Where-Object { $_.Type -eq "Registry" }
    $customOps = $servicesToRestart | Where-Object { $_.Type -eq "Custom" }
    
    # Show initial service status (if any services selected)
    if ($services.Count -gt 0) {
        $serviceNames = $services | ForEach-Object { $_.Name }
        Show-ServiceStatus -Computer $ComputerName -Services $serviceNames
    }
    
    # Execute registry operations first
    foreach ($regOp in $registryOps) {
        if ($regOp.Name -eq "AdobeFix") {
            $success = Set-AdobeRegistryFix -Computer $ComputerName
            
            if ($success) {
                Write-Host "[SUCCESS] $($regOp.DisplayName) applied successfully" -ForegroundColor Green
            } else {
                Write-Host "[FAILED] Failed to apply $($regOp.DisplayName)" -ForegroundColor Red
            }
        }
    }
    
    # Execute custom operations
    foreach ($customOp in $customOps) {
        if ($customOp.Name -eq "MSPCleanup") {
            $success = Invoke-AdvancedMSPCleanup -Computer $ComputerName
            
            if ($success) {
                Write-Host "[SUCCESS] $($customOp.DisplayName) completed successfully" -ForegroundColor Green
            } else {
                Write-Host "[FAILED] Failed to complete $($customOp.DisplayName)" -ForegroundColor Red
            }
        }
        elseif ($customOp.Name -eq "SessionManagement") {
            $success = Invoke-RemoteSessionManagement -Computer $ComputerName
            
            if ($success) {
                Write-Host "[SUCCESS] $($customOp.DisplayName) completed successfully" -ForegroundColor Green
            } else {
                Write-Host "[FAILED] Failed to complete $($customOp.DisplayName)" -ForegroundColor Red
            }
        }
    }
    
    # Execute service restarts
    foreach ($service in $services) {
        $success = Restart-RemoteService -Computer $ComputerName -ServiceName $service.Name -DisplayName $service.DisplayName
        
        if ($success) {
            Write-Host "[SUCCESS] $($service.DisplayName) restarted successfully" -ForegroundColor Green
        } else {
            Write-Host "[FAILED] Failed to restart $($service.DisplayName)" -ForegroundColor Red
        }
    }
    
    # Show final service status (if any services were restarted)
    if ($services.Count -gt 0) {
        Write-Host ("`n" + ("=" * 50))
        Write-Host "Final Status Check:" -ForegroundColor Cyan
        Show-ServiceStatus -Computer $ComputerName -Services $serviceNames
    }
    
    Write-Host "`nOperation completed." -ForegroundColor Cyan
    
    # Ask user if they want to continue
    Write-Host "`n[CONTINUE OPTIONS]" -ForegroundColor Yellow
    Write-Host "1. Return to main menu (perform another operation)" -ForegroundColor White
    Write-Host "2. Exit IT-ToolBox" -ForegroundColor White
    
    do {
        $continueChoice = Read-Host "`nSelect option (1 or 2)"
        
        if ($continueChoice -eq "1") {
            Write-Host "`nReturning to main menu..." -ForegroundColor Green
            Write-Host ("=" * 60) -ForegroundColor Cyan
            break
        } elseif ($continueChoice -eq "2") {
            Write-Host "`nExiting IT-ToolBox. Thank you!" -ForegroundColor Cyan
            exit 0
        } else {
            Write-Host "Invalid choice. Please enter 1 or 2." -ForegroundColor Red
        }
    } while ($true)
    
} while ($true)

# Usage examples (commented out)
<#
Usage Examples:

# Simply run the script - no parameters needed!
.\IT-ToolBox.ps1

# From PowerShell Core
pwsh -File .\IT-ToolBox.ps1

# From Command Prompt
powershell.exe -File .\IT-ToolBox.ps1

# Workflow:
# Step 1: Script shows interactive menu with available operations
# Step 2: User selects ONE operation (1, 2, 3, or Q to quit)
# Step 3: Script prompts for target computer name/IP
# Step 4: User confirms the operation
# Step 5: Script tests connectivity and executes the selected operation

# Available Operations:
# 1. Print Spooler (service restart)
# 2. Remote Desktop Services (service restart)
# 3. Adobe Acrobat DC Sign-in Fix (registry modification)
# 4. Advanced MSP Cleanup (disk space recovery from Windows Installer cache)
# 5. Remote Session Management (view and logoff user sessions)

# Interactive Menu Options:
# - Enter a single number: 1, 2, 3, 4, or 5
# - Enter "Q" or "q" to quit without making changes
# - ONE operation at a time for better tracking and control
#>
