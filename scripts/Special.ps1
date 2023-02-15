[CmdletBinding()]

Param(
    [Parameter()]
    [switch]
    $Habilitar,

    [Parameter()]
    [switch]
    $Desabilitar
)

########
# MAIN #
########

if($Habilitar){
    Write-Output "Tela azul agora não reinicia automaticamente... (Te permite ver com calma qual o erro que causou o crash)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type Dword -Value 0

    Write-Output "Habilitando navegacao com caminhos longos... (alem de 260 caracteres)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWORD -Value 1

    Write-Host "Exibir extensoes conhecidas..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

    Write-Output "Habilitar visualizacao de arquivos ocultos..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
}
elseif($Desabilitar){
    Write-Output "Tela azul reiniciara normalmente"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type Dword -Value 1

    Write-Output "Navegacao com caminhos longos desabilitada... (usar ate 260 caracteres)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWORD -Value 0

    Write-Host "Esconder Extensoes conhecidas..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1

    Write-Output "Desabilitar visualizacao de arquivos ocultos..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
}
else {throw "Por favor, insira um parametro valido: [ Habilitar | Desabilitar ]"}
