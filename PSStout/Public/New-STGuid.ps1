function New-STGuid
{ # New-STGuid
  
  <#
     .SYNOPSIS
       Creates 1 or more GUIDs. GUIDS can be forced to Uppercase and\or copied to clipboard.
     
     .DESCRIPTION
       Creates 1 or more GUIDs. GUIDS can be forced to Uppercase and\or copied to clipboard.
     
     .PARAMETER numberOfGuids (default 1)
       Number of GUIDS to generate

     .PARAMETER uppercase (default $false)
       Switch to put the GUID in UPPERCASE
     
     .PARAMETER clipboard (default $false)
       Switch to copy the results to the clipboard
     
     .EXAMPLE 1
       New-STGuid
       Creates 1 GUID in lowercase and writes it to screen

     .EXAMPLE 2
       New-STGuid -Uppercase -clipboard
       Creates 1 GUID in uppercase, writes it to screen and puts it in the clipboard
     
     .EXAMPLE 3
       New-STGuid 3 -Uppercase
       Creates 3 GUIDs in uppercase and writes it to screen. 
     
     .NOTES
       Current Version 1.0.0.1
 
       Version history
 
       1.0.0.0 - Version on 2025-02-28 
  #> 
  
  [cmdletbinding()]
  Param (
          [Parameter( 
            Mandatory = $False,
            Position = 0)]
            [int]$numberOfGuids = 1,
          [Parameter( 
            Mandatory = $False)]
            [switch]$uppercase,
          [Parameter( 
            Mandatory = $False)]
            [switch]$clipboard    
        )
   
   [bool]$bUpperCase = $False
   if($uppercase.IsPresent){$bUpperCase = $True}

   [bool]$bclipboard = $False
   if($clipboard.IsPresent){$bclipboard = $True}  
 
   $GuidArray = @()
   $numberOfGuids = [int]$numberOfGuids

   foreach ($i in 0..$($numberOfGuids-1))
    {# Foreach
     [Guid] $guidObject = [guid]::NewGuid()
     $guid = $guidObject.Guid.ToString().trim()
     if ($bUpperCase){$guid = $guid.ToUpper()}
     
     $GuidArray += [PSCustomObject]@{
                      Guid = $guid
                    }

    }# Foreach

    if($bclipboard) 
     {$GuidArray.guid | clip}

    return $GuidArray

} # New-STGuid