[CmdletBinding()]

Param(
    [Parameter(ParameterSetName = "AllComponents")]
    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $Extended,

    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $Memory,

    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $CPU,

    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $Motherboard,

    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $BIOS,

    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $GraphicCard,

    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $Printer,

    [Parameter(ParameterSetName = "AllComponents")]
    [switch]
    $All,

    [Parameter(ParameterSetName = "AllComponents")]
    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $Table,

    [Parameter(ParameterSetName = "AllComponents")]
    [Parameter(ParameterSetName = "MultipleComponents")]
    [switch]
    $List
)

#######################
# AUXILIARY FUNCTIONS #
#######################

function AddProperty {
    Param(
        [Parameter(Mandatory = $true)]
        [string]
        $Object,

        [Parameter(Mandatory = $true)]
        [string]
        $Name, 

        [Parameter(Mandatory = $true)]
        [string]
        $Value
    )

    Add-Member -InputObject $Object -MemberType NoteProperty -Name $Name -Value $Value
}

function Get-MemoryInfo{
    $properties = @{
        manufacturer = @{Name="Manufacturer"; Expression={$_.Manufacturer}}
        capacity = @{Name="Capacity (MB)"; Expression={$_.Capacity/1MB}}
        type = @{Name="Memory Type"; Expression={switch($_.SMBIOSMemoryType){20: {"DDR"} 21: {"DDR2"} 22: {"DDR2 FB-DIMM"} 24:{"DDR3"}} if($_.SMBIOSMemoryType -ge 26){"DDR4"}}}
        speed = @{Name="Memory Speed (MHz)"; Expression={$_.speed}}
        slot = @{Name="Slot"; Expression={$_.BankLabel}}
        partNumber = @{Name="PartNumber"; Expression={$_.PartNumber}}
        formFactor = @{Name="Form Factor"; Expression={if($_.FormFactor -eq 8) {"DIMM"} elseif($_.FormFactor -eq 12){"SODIMM"}}}
    }

    $filter = New-Object -TypeName PSObject -Property $properties

    return Get-CimInstance Win32_PhysicalMemory | Select-Object $filter.manufacturer, $filter.capacity, $filter.type, $filter.speed, $filter.slot, PartNumber, $filter.formFactor
}

function Get-GraphicCardInfo{
    $properties = @{
        name = @{Name="Name"; Expression={$_.Name}}
        description = @{Name="VideoModeDescription"; Expression={$_.VideoModeDescription}}
        status = @{Name="Status"; Expression={$_.Status}}
        driverVersion = @{Name="Driver Version"; Expression={$_.DriverVersion}}
        id = @{Name="ID"; Expression={$_.DeviceID}}
        vram = @{Name="VRAM (MB)"; Expression={$_.AdapterRAM/1MB}}
        # Case Frequency is null, reset computer and execute it again
        frequency = @{Name="Frequency"; Expression={$_.CurrentRefreshRate}}
    }

    $filter = New-Object -TypeName PSObject -Property $properties

    return Get-CimInstance win32_VideoController | Select-Object $filter.name, $filter.description, $filter.status, $filter.driverVersion, $filter.id, $filter.vram, $filter.frequency
}

function Get-BIOSInfo{
    $properties = @{
        smbiosversion = @{Name="SMBIOS Version"; Expression={$_.Name}}
        manufacturer = @{Name="Manufacturer"; Expression={$_.Manufacturer}}
        name = @{Name="Name"; Expression={$_.Name}}
        serialNumber = @{Name="Serial Number"; Expression={$_.SerialNumber}}
        version = @{Name="Version"; Expression={$_.Version}}    
    }

    $filter = New-Object -TypeName PSObject -Property $properties

    return Get-CimInstance Win32_bios  | Select-Object $filter.smbiosversion, $filter.manufacturer, $filter.name, $filter.serialNumber, $filter.version
}

function Get-MotherboardInfo{
    $properties = @{     
        manufacturer = @{Name="Manufacturer"; Expression={$_.Manufacturer}}
        name = @{Name="Name"; Expression={$_.Name}}
        model = @{Name="Model"; Expression={$_.Model}}
        serialNumber = @{Name="Serial Number"; Expression={$_.SerialNumber}}
        product = @{Name="Product"; Expression={$_.Product}}
        version = @{Name="Version"; Expression={$_.version}}
    }

    $filter = New-Object -TypeName PSObject -Property $properties

    return Get-CimInstance Win32_baseboard | Select-Object $filter.manufacturer, $filter.name, $filter.model, $filter.serialNumber, $filter.product
}

function Get-CPUInfo{
    $properties = @{    
        caption = @{Name="Caption"; Expression={$_.Caption}}
        id = @{Name="ID"; Expression={$_.DeviceID}}
        manufacturer = @{Name="Manufacturer"; Expression={$_.Manufacturer}}
        clock = @{Name="Max Clock Speed"; Expression={$_.MaxClockSpeed}}
        name = @{Name="Name"; Expression={$_.Name}}
        socket = @{Name="Socket"; Expression={$_.SocketDesignation}}
        l1 = @{Name="L1 Cache (KB)"; Expression={(& "$PSScriptRoot\CacheMemory.ps1" -Level 1 -op getsize).l1}}
        l2 = @{Name="L2 Cache (KB)"; Expression={(& "$PSScriptRoot\CacheMemory.ps1" -Level 2 -op getsize).l2}}
        l3 = @{Name="L3 Cache (KB)"; Expression={(& "$PSScriptRoot\CacheMemory.ps1" -Level 3 -op getsize).l3}}
    }
    
    $filter = New-Object -TypeName PSObject -Property $properties

    return Get-CimInstance Win32_processor | Select-Object $filter.caption, $filter.id, $filter.manufacturer, $filter.clock, $filter.name, $filter.socket, $filter.l1, $filter.l2, $filter.l3
}

# This module will just work for printers that don't bypass Windows spooler 
# in other words, the printer's driver has to communicate with spoolsv.exe process
# where the CMI retrieve information

function Get-PrinterInfo{
    # "Include" Get-PrinterStatus function
    . "$PSScriptRoot\aux_func\Printer_Status.ps1"

    $properties = @{    
        location = @{Name="Location"; Expression={$_.Location}}
        name = @{Name="Name"; Expression={$_.Name}}
        printerState = @{Name="PrinterState"; Expression={$_.PrinterState}}
        printerStatus = @{Name="PrinterStatus"; Expression={Get-PrinterStatus($_.PrinterStatus)}}
        shareName = @{Name="ShareName"; Expression={$_.ShareName}}
    }

    $private:filter = New-Object -TypeName PSObject -Property $properties

    return Get-CimInstance Win32_Printer | Select-Object $filter.location, $filter.name, $filter.printerState, $filter.printerStatus, $filter.shareName
}

##################
#  MAIN FUNCTION #
##################

function Main{
    #This is the output object
    $Components = @{}

    $AllComponents = @('Memory', 'CPU', 'BIOS', 'Printer', 'Motherboard', 'GraphicCard')
    if($All -eq $true) {$AllComponents | % {Set-Variable -Name $_ -Value $true}}

    $SelectedComponents = $AllComponents | Where-Object {$(get-variable $_ -ValueOnly) -eq $true}

    ForEach($component in $SelectedComponents){
        $Entry = @(&"Get-${component}Info")

        $Components.Add($component, $Entry)
    }

    if($Extended){
        foreach($component in $SelectedComponents){
            Write-Host "----- $component ------"
            $Components."$component" | &"format-$(if($Table) {"table"} else {"list"})"
        }
        return
    }
    else{
        return $Components
    }
}

& Main