function Get-STWinStartup
 { # Get-STWinStartup
    
  <#   
   .SYNOPSIS   
     Function returns the Windows startup processes

   .DESCRIPTION 
     Function returns Windows startup processes. It will return the values as PSObject or in a gridview
      
   .PARAMETER title (optional)
     This is the tile of the GridView.
     default = "StartUp Services" 
   
   .PARAMETER Gridview
     Switch to tell the function to return the startup processes as a gridview
  
   .Example
     Get-STWinStartup 
      Returns the windows startup processes as a PSObject in the format
        Name        : 
        DisplayName : 
        Description : 
        State       : 
        PathName    : 
     
   .Example
     Get-STWinStartup -Gridview 
      Returns the windows startup processes in a Windows Gridview   
   
   .NOTES
     
     Current Version 1.0.0.0
      
     Version history 
      
     1.0.0.0 - 2025-02-28 - Initial version
               Versioned for Powershell module PSStout 

  #>

  [cmdletbinding()]    
   Param (
          [Parameter(
           Mandatory = $False,
           Position = 0)]
           [string]$title = "StartUp Services" ,
          [Parameter(
           Mandatory = $False)]
           [switch]$Gridview                   
         )
   # Check for grid view switch  
   [bool]$bGridView = $false
   if ($GridView.IsPresent) {$bGridView = $true}

   # Get the services that have automatic start mode using Win32_Service
   $autoServices = Get-CimInstance -ClassName Win32_Service -Filter "StartMode = 'Auto'" 

   # Select the properties to display
   $selectedProperties = $autoServices | Select-Object -Property Name,DisplayName,Description,State,PathName

   if ($bGridView){ $selectedProperties | Out-GridView -Title $title }  # Output the result to a GridView window
   else { Return $selectedProperties } # Return results to console


} # Get-STWinStartup