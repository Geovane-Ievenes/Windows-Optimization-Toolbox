# Copyright (c) 2023 Geovane-Ievenes
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this PowerShell script and associated documentation files (the "Script"), to deal in the Script without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Script, and to permit persons to whom the Script is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Script.
#

[CmdletBinding()]

Param(
    [Parameter()]
    [switch]
    $FreezeCrashScreen = $null,

    [Parameter()]
    [switch]
    $LongPaths = $null,

    [Parameter()]
    [switch]
    $UnknownExt = $null,

    [Parameter()]
    [switch]
    $ShowHiddenFiles = $null,

    [Parameter()]
    [switch]
    $TPMCheck = $null
)

########
# MAIN #
########

$parameters = @{
    'FreezeCrashScreen' = @{
        $true = @{
            'message' = "Blue screen now does not restart automatically ... (allows you to see it calmly what error has caused the crash)"; 
            'regValue' = 0
        };
        $false = @{
            'message' = "Blue screen now restarts normally";
            'regValue' = 1
        }
    };
    'LongPaths' = @{
        $true = @{
            'message' = "Enabling navigation with long paths ... (besides 260 characters)"; 
            'regValue' = 1
        };
        $false = @{
            'message' = "Navigation with disabled long paths ... (use up to 260 characters)";
            'regValue' = 0
        }
    };
    'UnknownExt' = @{
        $true = @{
            'message' = "Showing known extensions ...";
            'regValue' = 0
        };
        $false = @{
            'message' = "Hiding known extensions ...";
            'regValue' = 1
        }
    };
    'ShowHiddenFiles' = @{
        $true = @{
            'message' = "Enabling Hidden Files View ...";
            'regValue' = 0
        };
        $false = @{
            'message' = "Hiding hidden files ...";
            'regValue' = 1
        }
    };
    'TPMCheck' = @{
        $true = @{
            'message' = "Enabling TPM and CPU check... (You can no longer update for Windows 11, see the compatible processor list)";
            'regValue' = 0
        };
        $false = @{
            'message' = "Disabled Verification of PMS and CPU ... (You can update for Windows 11 even though you don't have a compatible processor)";
            'regValue' = 1
        }
    }
}

if($PSBoundParameters.Count -ne 0){
    if($PSBoundParameters.ContainsKey('FreezeCrashScreen')){
        Write-Output $parameters.FreezeCrashScreen[$FreezeCrashScreen.IsPresent].message
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type Dword -Value $parameters.FreezeCrashScreen[$FreezeCrashScreen.IsPresent].regValue
    }
    if($PSBoundParameters.ContainsKey('LongPaths')){
        Write-Output $parameters.LongPaths[$LongPaths.IsPresent].message
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWORD -Value $parameters.LongPaths[$LongPaths.IsPresent].regValue
    }
    if($PSBoundParameters.ContainsKey('UnknownExt')){
        Write-Output $parameters.UnknownExt[$UnknownExt.IsPresent].message
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value $parameters.UnknownExt[$UnknownExt.IsPresent].regValue
    }
    if($PSBoundParameters.ContainsKey('ShowHiddenFiles')){
        Write-Output $parameters.ShowHiddenFiles[$ShowHiddenFiles.IsPresent].message
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value $parameters.ShowHiddenFiles[$ShowHiddenFiles.IsPresent].regValue
    }

    if($PSBoundParameters.ContainsKey('TPMCheck')){
        Write-Output $parameters.TPMCheck[$TPMCheck.IsPresent].message
        If (!(Test-Path "HKLM:\SYSTEM\Setup\MoSetup")) {
            New-Item -Path "HKLM:\SYSTEM\Setup\MoSetup" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\MoSetup" -Name "AllowUpgradesWithUnsupportedTPMOrCPU" -Type DWord -Value $parameters.TPMCheck[$TPMCheck.IsPresent].regValue
    }
}
else {Write-Host "Please enter at least one parameter"}
