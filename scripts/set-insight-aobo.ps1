################
<#
.SYNOPSIS
    Assigns the 'Owner' Azure Role Assignment to the relevant Insight regional foreign security groups that is needed for Admin on Behalf Of (AOBO)

.DESCRIPTION
Assigns the 'Owner' Azure Role Assignment to the relevant Insight regional foreign security groups that is needed for Admin on Behalf Of (AOBO)

.PARAMETER FilePath
    Optional path to a .txt or .csv file containing subscription IDs. 
    For .txt files: one subscription ID per line
    For .csv files: subscription IDs should be in a column named 'SubscriptionId' or 'Id'

.PARAMETER Region
    Optional parameter to specify the region (AU, NZ, HK, or SG). If not provided, user will be prompted to choose.

.PARAMETER Verbose
    Enable verbose output for detailed logging

.EXAMPLE
    ./set-aobo-au.ps1
    Prompts for region selection and assigns role permissions for all accessible subscriptions.

.EXAMPLE
    ./set-insight-aobo.ps1 -FilePath ./subs.txt -region 'AU'
    Uses the AU region for role assignments for all subscriptions listed in the text file

.EXAMPLE
    ./set-insight-aobo.ps1 -FilePath './subs.csv' -Region 'SG' -Verbose
    Uses the AU region for role assignments for all subscriptions listed in the text file
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$FilePath,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('AU', 'NZ', 'HK', 'SG')]
    [string]$Region,

    [Parameter(Mandatory = $false, HelpMessage = 'Skip interactive confirmation')]
    [switch]$Force
)

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# =============================
# Constants / Configuration
# =============================
$RoleDefinitionName = 'Owner'
$GuidPattern        = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'

# Ordered regional object IDs for the Insight foreign security groups (order matters for menu display)
$objectIds = [ordered]@{
    AU = @{ ObjectId = 'b1d52de1-30aa-48de-9220-c93f9b6c5711'; Description = 'Insight AU' }
    NZ = @{ ObjectId = '118aa420-89ee-4264-a34a-b400dd7422be'; Description = 'Insight NZ' }
    HK = @{ ObjectId = '46eed55b-7edc-4dd1-a092-f038877ac393'; Description = 'Insight HK' }
    SG = @{ ObjectId = 'ecdc3e3a-7b29-4300-b92b-14d0f3739ab9'; Description = 'Insight SG' }
}

try {
    Write-Host "Starting Admin on Behalf of (AOBO) Role Assignment script..." -ForegroundColor Green
    
    # Region selection logic (interactive if not specified)
    if (-not $Region) {
        Write-Host "`nPlease select the location for your Azure CSP Subscriptions:" -ForegroundColor Yellow
        $index = 1
        foreach ($key in $objectIds.Keys) {
            $info = $objectIds[$key]
            Write-Host ("{0}. {1} - Object ID: {2}" -f $index, $key, $info.ObjectId) -ForegroundColor White
            $index++
        }
        do {
            $selection = Read-Host ("`nEnter your choice (1-{0})" -f $objectIds.Count)
            if ($selection -as [int]) {
                $selIndex = [int]$selection
                if ($selIndex -ge 1 -and $selIndex -le $objectIds.Count) {
                    $Region = $objectIds.Keys[$selIndex - 1]
                } else {
                    Write-Host "Invalid selection. Please enter a number between 1 and $($objectIds.Count)." -ForegroundColor Red
                }
            } else {
                Write-Host "Invalid selection. Enter a numeric value." -ForegroundColor Red
            }
        } while ([string]::IsNullOrWhiteSpace($Region))
    }
    
    # Set the object ID based on region selection
    $selectedObjectId = $objectIds[$Region]
    $objectIdVar = $selectedObjectId.ObjectId
    $regionDescription = $selectedObjectId.Description
    
    Write-Host "`nSelected region: $regionDescription" -ForegroundColor Green
    Write-Host "Using Object ID: $objectIdVar" -ForegroundColor Green
    
    # Check if Azure PowerShell module is available
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        throw "Azure PowerShell module (Az.Accounts) is not installed. Please install it using: Install-Module -Name Az -Force"
    }
    
    # Check if user is logged into Azure
    $context = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $context) {
        throw "Not logged into Azure. Please run 'Connect-AzAccount' first."
    }
    
    Write-Host "Connected to Azure as: $($context.Account.Id)" -ForegroundColor Yellow
    
    # Initialize subscriptions array
    $subscriptions = @()
    
    if ($FilePath) {
        # Validate file exists
        if (-not (Test-Path $FilePath)) {
            throw "File not found: $FilePath"
        }
        
        Write-Host "Importing subscriptions from file: $FilePath" -ForegroundColor Yellow
        
        $fileExtension = [System.IO.Path]::GetExtension($FilePath).ToLower()
        
        switch ($fileExtension) {
            ".txt" {
                # Read subscription IDs from text file (one per line)
                $subscriptionIds = Get-Content $FilePath | Where-Object { $_.Trim() -ne "" }
                
                foreach ($subId in $subscriptionIds) {
                    $subId = $subId.Trim()
                    if ($subId -match $GuidPattern) {
                        try {
                            $subscription = Get-AzSubscription -SubscriptionId $subId -ErrorAction SilentlyContinue
                            if ($subscription) {
                                $subscriptions += $subscription
                                Write-Verbose "Added subscription: $($subscription.Name) ($subId)"
                            } else {
                                Write-Warning "Subscription not found or not accessible: $subId"
                            }
                        } catch {
                            Write-Warning "Error accessing subscription $subId : $($_.Exception.Message)"
                        }
                    } else {
                        Write-Warning "Invalid subscription ID format: $subId"
                    }
                }
            }
            ".csv" {
                # Read subscription IDs from CSV file
                try {
                    $csvData = Import-Csv $FilePath
                    
                    # Try to find subscription ID column (case insensitive)
                    $subIdColumn = $null
                    $headers = $csvData[0].PSObject.Properties.Name
                    
                    foreach ($header in $headers) {
                        if ($header -match "^(subscription|sub).*id$|^id$") {
                            $subIdColumn = $header
                            break
                        }
                    }
                    
                    if (-not $subIdColumn) {
                        throw "CSV file must contain a column named 'SubscriptionId', 'SubId', or 'Id'"
                    }
                    
                    Write-Verbose "Using column '$subIdColumn' for subscription IDs"
                    
                    foreach ($row in $csvData) {
                        $subId = $row.$subIdColumn
                        if ($subId) {
                            $subId = $subId.Trim()
                            if ($subId -match $GuidPattern) {
                                try {
                                    $subscription = Get-AzSubscription -SubscriptionId $subId -ErrorAction SilentlyContinue
                                    if ($subscription) {
                                        $subscriptions += $subscription
                                        Write-Verbose "Added subscription: $($subscription.Name) ($subId)"
                                    } else {
                                        Write-Warning "Subscription not found or not accessible: $subId"
                                    }
                                } catch {
                                    Write-Warning "Error accessing subscription $subId : $($_.Exception.Message)"
                                }
                            } else {
                                Write-Warning "Invalid subscription ID format: $subId"
                            }
                        }
                    }
                } catch {
                    throw "Error reading CSV file: $($_.Exception.Message)"
                }
            }
            default {
                throw "Unsupported file format. Please use .txt or .csv files only."
            }
        }
        
        if ($subscriptions.Count -eq 0) {
            throw "No valid subscriptions found in the specified file."
        }
        
        Write-Host "Successfully imported $($subscriptions.Count) subscription(s) from file" -ForegroundColor Green
    } else {
        # Get all accessible subscriptions
        Write-Host "No file specified, retrieving all accessible subscriptions..." -ForegroundColor Yellow
        
        try {
            $subscriptions = Get-AzSubscription
            Write-Host "Found $($subscriptions.Count) accessible subscription(s)" -ForegroundColor Green
        } catch {
            throw "Error retrieving subscriptions: $($_.Exception.Message)"
        }
    }
    
    # =============================
    # Preview & Confirmation (UX Safety)
    # =============================
    $total = $subscriptions.Count
    $sampleSize = if ($total -gt 10) { 10 } else { $total }
    $sampleSubs = $subscriptions | Select-Object -First $sampleSize | Select-Object @{n='Name';e={$_.Name}}, @{n='SubscriptionId';e={$_.Id}}

    Write-Host "`nPreview of planned operation:" -ForegroundColor Cyan
    Write-Host (" Region            : {0}" -f $regionDescription)
    Write-Host (" Role              : {0}" -f $RoleDefinitionName)
    Write-Host (" Object ID         : {0}" -f $objectIdVar)
    Write-Host (" Total Subscriptions: {0}" -f $total)
    if ($total -gt 0) {
        Write-Host (" Sample ({0} shown):" -f $sampleSize)
        $sampleSubs | Format-Table -AutoSize | Out-String | Write-Host
    }

    $proceed = $true
    if (-not $Force) {
        # Simple Y/N confirmation
        do {
            $answer = Read-Host "Proceed with role assignment? (Y/N)"
        } while ($answer -notmatch '^[YyNn]$')
        if ($answer -match '^[Nn]$') { 
            Write-Host 'Operation cancelled by user before making any changes.' -ForegroundColor Yellow
            return
        }
    } else {
        Write-Host 'Force specified: skipping interactive confirmation.' -ForegroundColor Yellow
    }

    # Process each subscription
    $successCount = 0
    $errorCount = 0
    $skippedCount = 0
    $disabledCount = 0
    
    Write-Host "`nStarting role assignments..." -ForegroundColor Green
    
    $i = 0
    foreach ($sub in $subscriptions) {
        $i++
        $percent = if ($total -gt 0) { [math]::Round(($i / $total) * 100,2) } else { 100 }
        Write-Progress -Activity "Assigning $RoleDefinitionName role" -Status "Processing $i of $total" -PercentComplete $percent -CurrentOperation $sub.Id
        try {
            Write-Host "Processing subscription: $($sub.Name) ($($sub.Id))" -ForegroundColor Cyan
            
            # Check if subscription is in a disabled state
            if ($sub.State -eq 'Disabled') {
                Write-Warning "Skipping disabled subscription: $($sub.Name) ($($sub.Id))"
                $disabledCount++
                continue
            }
            
            # Check if subscription is in an active state
            if ($sub.State -ne 'Active') {
                Write-Warning "Skipping subscription in '$($sub.State)' state: $($sub.Name) ($($sub.Id))"
                $skippedCount++
                continue
            }
            
            # Check if role assignment already exists
            $scopeVar = "/subscriptions/$($sub.Id)"
            $existingAssignment = Get-AzRoleAssignment -ObjectId $objectIdVar -Scope $scopeVar -RoleDefinitionName $RoleDefinitionName -ErrorAction SilentlyContinue
            
            if ($existingAssignment) {
                Write-Warning "Role assignment already exists for subscription: $($sub.Name)"
                $skippedCount++
                continue
            }
            
            # Create new role assignment
            $roleAssignment = New-AzRoleAssignment -ObjectId $objectIdVar -RoleDefinitionName $RoleDefinitionName -Scope $scopeVar -ObjectType "ForeignGroup"
            
            if ($roleAssignment) {
                Write-Host "✓ Successfully assigned Owner role for subscription: $($sub.Name)" -ForegroundColor Green
                $successCount++
            } else {
                Write-Warning "Role assignment creation returned null for subscription: $($sub.Name)"
                $errorCount++
            }
            
        } catch {
            Write-Error "✗ Failed to assign role for subscription $($sub.Name): $($_.Exception.Message)"
            $errorCount++
        }
    }
    
    Write-Progress -Activity "Assigning $RoleDefinitionName role" -Completed

    # Summary
    Write-Host "`n--- Summary ---" -ForegroundColor Magenta
    Write-Host "Region: $regionDescription" -ForegroundColor White
    Write-Host "Object ID: $objectIdVar" -ForegroundColor White
    Write-Host "Total subscriptions processed: $($subscriptions.Count)" -ForegroundColor White
    Write-Host "Successful assignments: $successCount" -ForegroundColor Green
    Write-Host "Skipped (already assigned): $skippedCount" -ForegroundColor Yellow
    Write-Host "Disabled/Other states skipped: $disabledCount" -ForegroundColor Gray
    Write-Host "Errors: $errorCount" -ForegroundColor Red
    
    if ($errorCount -eq 0) {
        Write-Host "`nScript completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "`nScript completed with errors. Please review the output above." -ForegroundColor Yellow
    }
    
} catch {
    Write-Error "Script failed with error: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}

# End of Script
################
