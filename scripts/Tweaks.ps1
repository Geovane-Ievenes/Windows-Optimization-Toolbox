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
            'message' = "Tela azul agora não reinicia automaticamente... (Te permite ver com calma qual o erro que causou o crash)"; 
            'regValue' = 0
        };
        $false = @{
            'message' = "Tela azul agora reinicia normalmente";
            'regValue' = 1
        }
    };
    'LongPaths' = @{
        $true = @{
            'message' = "Habilitando navegacao com caminhos longos... (alem de 260 caracteres)"; 
            'regValue' = 1
        };
        $false = @{
            'message' = "Navegacao com caminhos longos desabilitada... (usar ate 260 caracteres)";
            'regValue' = 0
        }
    };
    'UnknownExt' = @{
        $true = @{
            'message' = "Exibindo extensoes conhecidas...";
            'regValue' = 0
        };
        $false = @{
            'message' = "Escondendo Extensoes conhecidas...";
            'regValue' = 1
        }
    };
    'ShowHiddenFiles' = @{
        $true = @{
            'message' = "Habilitando visualizacao de arquivos ocultos...";
            'regValue' = 0
        };
        $false = @{
            'message' = "Escondendo Extensoes conhecidas...";
            'regValue' = 1
        }
    };
    'TPMCheck' = @{
        $true = @{
            'message' = "Habilitando verificacao de TPM e CPU... (Você não podera mais atualizar para o Windows 11, Consulte a lista de processadores compatíveis)";
            'regValue' = 0
        };
        $false = @{
            'message' = "Desabilitando verificacao de TPM e CPU... (Voce podera atualizar para o Windows 11 mesmo não possuindo um processador compatível)";
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
else {throw "Por favor, Insira ao menos um parâmetro"}
