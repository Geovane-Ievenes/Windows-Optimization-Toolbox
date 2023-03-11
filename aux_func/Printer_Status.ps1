# Copyright (c) 2023 Geovane-Ievenes
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this PowerShell script and associated documentation files (the "Script"), to deal in the Script without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Script, and to permit persons to whom the Script is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Script.
#

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

