################
<#
.SYNOPSIS
    Assigns Owner role to Insight regional object ID for specified Azure subscriptions

.DESCRIPTION
    This script assigns Owner permissions to Insight regional object IDs for Azure subscriptions.
    AU Object ID: b1d52de1-30aa-48de-9220-c93f9b6c5711
    NZ Object ID: 118aa420-89ee-4264-a34a-b400dd7422be
    HK Object ID: 46eed55b-7edc-4dd1-a092-f038877ac393
    SG Object ID: ecdc3e3a-7b29-4300-b92b-14d0f3739ab9
    It can import subscription IDs from a file or use all accessible subscriptions.

.PARAMETER FilePath
    Optional path to a .txt or .csv file containing subscription IDs. 
    For .txt files: one subscription ID per line
    For .csv files: subscription IDs should be in a column named 'SubscriptionId' or 'Id'

.PARAMETER Region
    Optional parameter to specify the region (AU, NZ, HK, or SG). If not provided, user will be prompted to choose.

.PARAMETER Verbose
    Enable verbose output for detailed logging

.EXAMPLE
    .\set-aobo-au.ps1
    Prompts for region selection and assigns permissions for all accessible subscriptions

.EXAMPLE
    .\set-aobo-au.ps1 -FilePath "subscriptions.txt" -Region "AU"
    Assigns AU permissions for subscriptions listed in the text file

.EXAMPLE
    .\set-aobo-au.ps1 -FilePath "subscriptions.csv" -Region "SG" -Verbose
    Assigns SG permissions for subscriptions listed in the CSV file with verbose output
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$FilePath,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("AU", "NZ", "HK", "SG")]
    [string]$Region
)

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# Define regional object IDs
$objectIds = @{
    "AU" = @{
        "ObjectId" = "b1d52de1-30aa-48de-9220-c93f9b6c5711"
        "Description" = "Insight AU"
    }
    "NZ" = @{
        "ObjectId" = "118aa420-89ee-4264-a34a-b400dd7422be"
        "Description" = "Insight NZ"
    }
    "HK" = @{
        "ObjectId" = "46eed55b-7edc-4dd1-a092-f038877ac393"
        "Description" = "Insight HK"
    }
    "SG" = @{
        "ObjectId" = "ecdc3e3a-7b29-4300-b92b-14d0f3739ab9"
        "Description" = "Insight SG"
    }
}

try {
    Write-Host "Starting Admin on Behalf of (AOBO) Role Assignment script..." -ForegroundColor Green
    
    # Region selection logic
    if (-not $Region) {
        Write-Host "`nPlease select the region for your Insight CSP Subscriptions:" -ForegroundColor Yellow
        Write-Host "1. AU (Australia) - Object ID: b1d52de1-30aa-48de-9220-c93f9b6c5711" -ForegroundColor White
        Write-Host "2. NZ (New Zealand) - Object ID: 118aa420-89ee-4264-a34a-b400dd7422be" -ForegroundColor White
        Write-Host "3. HK (Hong Kong) - Object ID: 46eed55b-7edc-4dd1-a092-f038877ac393" -ForegroundColor White
        Write-Host "4. SG (Singapore) - Object ID: ecdc3e3a-7b29-4300-b92b-14d0f3739ab9" -ForegroundColor White
        
        do {
            $selection = Read-Host "`nEnter your choice (1 for AU, 2 for NZ, 3 for HK, 4 for SG)"
            switch ($selection) {
                "1" { $Region = "AU"; break }
                "2" { $Region = "NZ"; break }
                "3" { $Region = "HK"; break }
                "4" { $Region = "SG"; break }
                default { Write-Host "Invalid selection. Please enter 1, 2, 3, or 4." -ForegroundColor Red }
            }
        } while ($null -eq $Region -or $Region -eq "")
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
                    if ($subId -match "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$") {
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
                            if ($subId -match "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$") {
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
    
    # Process each subscription
    $successCount = 0
    $errorCount = 0
    $skippedCount = 0
    
    Write-Host "`nStarting role assignments..." -ForegroundColor Green
    
    foreach ($sub in $subscriptions) {
        try {
            Write-Host "Processing subscription: $($sub.Name) ($($sub.Id))" -ForegroundColor Cyan
            
            # Check if role assignment already exists
            $scopeVar = "/subscriptions/$($sub.Id)"
            $existingAssignment = Get-AzRoleAssignment -ObjectId $objectIdVar -Scope $scopeVar -RoleDefinitionName "Owner" -ErrorAction SilentlyContinue
            
            if ($existingAssignment) {
                Write-Warning "Role assignment already exists for subscription: $($sub.Name)"
                $skippedCount++
                continue
            }
            
            # Create new role assignment
            $roleAssignment = New-AzRoleAssignment -ObjectId $objectIdVar -RoleDefinitionName "Owner" -Scope $scopeVar -ObjectType "ForeignGroup"
            
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
    
    # Summary
    Write-Host "`n--- Summary ---" -ForegroundColor Magenta
    Write-Host "Region: $regionDescription" -ForegroundColor White
    Write-Host "Object ID: $objectIdVar" -ForegroundColor White
    Write-Host "Total subscriptions processed: $($subscriptions.Count)" -ForegroundColor White
    Write-Host "Successful assignments: $successCount" -ForegroundColor Green
    Write-Host "Skipped (already assigned): $skippedCount" -ForegroundColor Yellow
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
