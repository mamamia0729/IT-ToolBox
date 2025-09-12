<#
.SYNOPSIS
    IT-ToolBox - Interactive Remote Management Utility

.DESCRIPTION
    Interactive script to manage services and apply fixes on remote computers.
    Current features:
    - Print Spooler service restart
    - Remote Desktop Services restart 
    - Adobe Acrobat DC sign-in fix (registry modification)
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
    Version: 3.2 - Optimized for single operation mode (better tracking)
    Requires: PowerShell 5.1+, Administrative privileges for remote operations
    Workflow: Menu first → Operation selection → Computer name prompt → Execute
    Future: Additional services/fixes can be easily added to the $availableServices array
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
    Write-Host "- Enter a single number (1, 2, or 3)" -ForegroundColor Gray
    Write-Host "- Enter 'Q' to quit without making changes" -ForegroundColor Gray
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    do {
        $selection = Read-Host "`nSelect operation to perform (1, 2, 3, or Q to quit)"
        
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
    })
    # TO ADD MORE SERVICES, add them here following this pattern:
    # ,(New-Object PSObject -Property @{
    #     Name = "ServiceName"           # Actual Windows service name or custom identifier
    #     DisplayName = "Display Name"   # User-friendly name
    #     Description = "What it does"   # Brief description
    #     Type = "Service"               # "Service" or "Registry" or "Custom"
    # })
)

# Step 1: Show operation selection menu
Write-Host "`nStep 1: Select operation to perform" -ForegroundColor Magenta
$servicesToRestart = Show-ServiceSelectionMenu -AvailableServices $availableServices

if ($servicesToRestart -eq $null -or $servicesToRestart.Count -eq 0) {
    Write-Host "No operation selected. Exiting." -ForegroundColor Yellow
    exit 0
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
    exit 0
}

# Step 4: Test connectivity
Write-Host "`nStep 4: Testing connectivity" -ForegroundColor Magenta
if (-not (Test-RemoteConnectivity -Computer $ComputerName)) {
    Write-Host "`nCannot connect to $ComputerName. Exiting." -ForegroundColor Red
    exit 1
}

# Step 5: Execute operations
Write-Host "`nStep 5: Executing operations" -ForegroundColor Magenta

# Separate services and registry operations
$services = $servicesToRestart | Where-Object { $_.Type -eq "Service" -or $_.Type -eq $null }
$registryOps = $servicesToRestart | Where-Object { $_.Type -eq "Registry" }

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

Write-Host "`nScript completed." -ForegroundColor Cyan

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

# Interactive Menu Options:
# - Enter a single number: 1, 2, or 3
# - Enter "Q" or "q" to quit without making changes
# - ONE operation at a time for better tracking and control
#>
