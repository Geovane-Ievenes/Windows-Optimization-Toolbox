function Get-PrinterStatus{
  param ([Parameter(Mandatory = $true,HelpMessage = "Type Printer Status Code")][int]$Code)
  
  if ($Code -ne '')
  {
  switch ($Code){
    1 
    {
      'Other'
    }
    2 
    {
      'Unknown'
    }
    3 
    {
    # In this case, reinstall Try to: Unplug your Printer's USB or Reinstall Printer's Driver
      'Idle'
    }
    4 
    {
      'Printing'
    }
    5 
    {
      'Warmup'
    }
    6 
    {
      'Stopped printing'
    }
    7 
    {
      'Offline'
    }
    default 
    {
      'Invalid Code'
    }
  }
  }
  
  return
}

