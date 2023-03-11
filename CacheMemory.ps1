[CmdletBinding()]
Param(
    [Alias("lv")]
    [Parameter(Mandatory = $true)]
    [String]$Level,

    [Alias("op")]
    [Parameter(Mandatory = $true)]
    [String]$Operation
)

$ErrorActionPreference = "Stop"

#
# AUXILIARY FUNCTIONS
#
function Get-RegistryValue
{
    Param(
        [string]$Name,
        [string]$Path
    )

    try{
        $reg = (Get-ItemProperty -path $Path -name $Name)."$Name"
        return $reg
    }
    catch [System.Management.Automation.PSArgumentException]{
        #If the registry doesn`t exist, it will show an exception message
        return $null
    }
}

function Set-RegistryValue
{
    Param(
        [string]$Path,
        [string]$Name,
        [string]$Value
    )

    try{
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWORD -Force | Out-Null
        return 
    }
    catch [System.Management.Automation.PSArgumentException]{
        return 
    }
    
}

#
# MAIN FUNCTIONS
#

function Get-CacheSize
{
    $caches = [ordered]@{}      

    switch($Level){
        1 {$caches.l1 = $null}
        2 {$caches.l2 = $null}
        3 {$caches.l3 = $null}
        "all" {$caches.l1 = $null; $caches.l2 = $null; $caches.l3 = $null}
        default {Write-Host "This is not a cache level, please use [1|2|3|all]"}
    }

    # Given wmic cache size output: "MaxCacheSize=999". Storage info are in odd indexes
    $wmicCache = (wmic memcache list /format:list | select-string -pattern "MaxCacheSize") -split "="
    
    #iterate over odd indexes of $caches hashtable
    $i = 1;
    for($c = 1; $c -le $wmicCache.Count; $c += 2){
        #Case $Level is a specific cache, add an item to hashtable just if it`s equal to the selected level
        if($Level -ne "all" -AND $i -ne $Level) {$i++; continue}

        $caches["l$i"] = $wmicCache[$c]
        
        #Get until L3 memory
        if($Level -eq "all" -AND $i -le 3) {$i++}
        else {break}
    }

    return $caches;
}

function Get-CacheStatus
{
    #L1 cache is always enable, but doesn`t have a registry entry
    $status = [ordered]@{}

    $caches = Get-CacheSize
    $caches.Keys | ForEach-Object {
        $currentCacheLevel = $_

        #Pushing selected cache levels to $status hash table 
        if($currentCacheLevel -eq "l1") {$status["l1"] = "enabled"}
        if($currentCacheLevel -eq "l2") {$status["l2"] = $null}
        if($currentCacheLevel -eq "l3") {$status["l3"] = $null}

        $REG_PATH = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        $cacheExtendedName = if($currentCacheLevel -eq "l1") {return} elseif($currentCacheLevel -eq "l2") {"SecondLevelDataCache"} else {"ThirdLevelDataCache"}

        $RegistryValue = Get-RegistryValue -Name $cacheExtendedName -Path $REG_PATH

        if($registryValue -eq 0){$status[$currentCacheLevel] = "disabled"}
        elseif($null -eq $registryValue) {$status[$currentCacheLevel] = 'Don`t Have'}
        else {$status[$currentCacheLevel] = "enabled"}
    }

    return $status
}

function Enable-CacheMemory
{

    $caches = Get-CacheSize
    $modified = $false

    $caches.Keys | ForEach-Object {
        $currentCacheLevel = $_
        $REG_PATH = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        $modify = $false

        #NOTE: L1 CACHE is by default enabled on Windows 10
        $cacheExtendedName = if($currentCacheLevel -eq "l1") {return} elseif($currentCacheLevel -eq "l2") {"SecondLevelDataCache"} else {"ThirdLevelDataCache"}
        
        $RegistryValue = Get-RegistryValue -Name $cacheExtendedName -Path $REG_PATH

        #If registry == 0, it exists but is not enabled. But if it`s null, verify if the computer really has this level cache, if so, create registry
        if($registryValue -eq 0) {$modify = $true}
        # If computer doesn`t have this cache level or ir the registry is not equal 0, chek next chache level. Else, create/modify registry
        elseif($null -eq $caches[$currentCacheLevel] -OR $registryValue -gt 0) {return} else {$modify = $true}

        if($modify){
            Set-RegistryValue -Path $REG_PATH -Name $cacheExtendedName -Value $caches[$currentCacheLevel] 
            Write-Output "$((Get-Date -Format "G").toString()) >>> $cacheExtendedName Enabled | $($caches[$currentCacheLevel])KB cache enabled" | Tee-Object -Append -FilePath "$HOME/Desktop/CacheMemoryLog.txt"
            $modified = $true
        }
    }

    if(!$modified) {Write-Output "$((Get-Date -Format "G").toString()) >>> All cache memories are enabled" | Tee-Object -Append -FilePath "$HOME/Desktop/CacheMemoryLog.txt"}  
}

function Disable-CacheMemory
{
    $caches = Get-CacheSize
    $caches.Keys | ForEach-Object {
        $currentCacheLevel = $_

        $REG_PATH = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        $cacheExtendedName = if($currentCacheLevel -eq "l1") {return} elseif($currentCacheLevel -eq "l2") {"SecondLevelDataCache"} else {"ThirdLevelDataCache"}

        $RegistryValue = Get-RegistryValue -Name $cacheExtendedName -Path $REG_PATH
        if($RegistryValue -eq 0 -OR $null -eq $RegistryValue) {
            Write-Output "$cacheExtendedName is already Disabled or does not exist"
            return 
        }
        else {
            Set-RegistryValue -Path $REG_PATH -Name $cacheExtendedName -Value 0 
            Write-Output "$cacheExtendedName disabled"
        }
    }
}

switch($Operation){
    "getsize" {Get-CacheSize}
    "enable" {Enable-CacheMemory}
    "disable" {Disable-CacheMemory}
    "getstatus" {Get-CacheStatus}
    default{ Write-Host "Not a valid operation. Use -Operation [
    getsize --> Get size of select cache memory level (KB) | 
    enable --> Enable the selected cache memory level | 
    disable --> Enable the selected cache memory level | 
    getstatus --> See if the selected cache memory level(s) are enabled or not]"}
}
