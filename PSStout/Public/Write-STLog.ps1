function Write-STLog
{ # Write-STLog

   <#   
     .SYNOPSIS   
      Writes a line to a log file
   
     .DESCRIPTION 
      Writes a line to a log file in the format <Date> <time>-<appname>-Log Line Entry 
    
     .PARAMETER Logstring (Mandatory) 
      The Line you want to write to the log file

     .PARAMETER Logfile (Mandatory) 
      Path to the log file

     .PARAMETER Lappname (optional) 
      The name of the application (optional)

     .Parameter WriteLine (optional switch)
      A switch to write the line to the screen can be handy for screen updates

     .PARAMETER NODate (optional switch)
      A Switch to turn off the Date from the log line

     .PARAMETER NOTime (optional switch)
      A Switch to turn off the Time from the log line 

     .PARAMETER Dformat (optional switch)
      A String for the date format

     .PARAMETER Tformat (optional switch)
      A String for the Time format
      
     .Example
      Write-StLog "We have failed to write the file" "C:\logs\logfile.txt" 
      Writes line  - "<Date in the format yyyyMMdd> <Time in the format hh:mm:ss>-We have failed to write the file" to the file C:\logs\logfile.txt

     .Example
      Write-StLog $logstr $logfile $AppName 
      Will write the line - "<Date in the format yyyyMMdd> <Time in the format hh:mm:ss>-$appname-$logstr" to the file $logfile

     .Example
      Write-StLog $logstr $logfile -noDate -noTime
      Will write the line - "$logstr" to the file $logfile
 
     .Example
      Write-StLog $logstr $logfile -Dformat "MMdd" Tformat "hh"
      Will write the line - "<Date in the format MMdd> <Time in the format hh>-$logstr" to the file $logfile

     .Notes
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
            [AllowEmptyString()]  
            [string]$Logstring = $null,
           [Parameter( 
            Mandatory = $False,
            Position = 1)]
            [AllowEmptyString()] 
            [string]$Logfile = $null, 
           [Parameter( 
            Mandatory = $False,
            Position = 2)]
            [AllowEmptyString()]
            [Alias("Lappname")] 
            [string]$AppName ,
           [Parameter( 
            Mandatory = $False)]
            [switch] $WriteLine,
           [Parameter( 
            Mandatory = $False)]
            [switch] $NODate,
           [Parameter( 
            Mandatory = $False)]
            [switch] $NOTime, 
           [Parameter( 
            Mandatory = $False)]
            [switch] $RotateLogs,
           [Parameter( 
             Mandatory = $False)]
             [decimal]$MaxLogSize = 10MB, 
           [Parameter( 
             Mandatory = $False)]
             [int]$NumberOflogfiles = 10,        
           [Parameter( 
             Mandatory = $False)]
             [String]$Dformat = "yyyyMMdd",
           [Parameter( 
             Mandatory = $False)]
             [String]$Tformat = "hh:mm:ss"
          )
   # Writeline
   [bool] $bWriteline = $false
   if ( $WriteLine.IsPresent) {$bWriteline = $true}
   
   # Use Date
   [bool] $bDate = $True
   if ( $NODate.IsPresent) {$bDate = $false}
   
   # Use Time
   [bool] $bTime = $True
   if ( $NOTime.IsPresent) {$bTime = $false}

   # Use AppName
   [bool] $bAppName = $True
   if (!($AppName)) {$bAppName = $False}
   
   # Rotate Logs
   [bool] $bRotateLogs = $false
   if ( $RotateLogs.IsPresent) {$bRotateLogs = $TRUE}
   
   # Trim the logstring to check for NUll or white-space
   $logstring = $logstring.Trim()

   if ($Logstring)
    { # Log String Does not equal to $Null

      # Write the Line of Text 
      if ($PSBoundParameters['Verbose'] -or $bWriteline) {Write-Host $Logstring}
   
      # Initialize the Log line 
      [string]$StrLOGLine = $null
      
      # Build the Log line With Date 
      if ($bDate) 
       { # Add Date to Logline
        $StrDate = Get-Date -Format $Dformat
        $StrLOGLine = $StrDate + " "
       } # Add Date to Logline   
   
      # Build the Log line with Time 
      if ($bTime) 
       { # Add Time to Logline
         $strTime = Get-Date -Format $Tformat
         $StrLOGLine = $StrLOGLine + $strTime + "-"
       } # Add Time to Logline 

      # Build the Log line AppName 
      if ($bAppName) 
       {$StrLOGLine = $StrLOGLine + $AppName + "-"}  
   
      # Build the Log line with the log string
      $StrLOGLine = $StrLOGLine + $Logstring
     
      # Trim the logfile to check for NUll or white-space
      $Logfile = $logfile.Trim()
      
      if ($Logfile) 
        { # logfile not equal to Null
          
          if($bRotateLogs)
           { # Rotate Logs Set
             
             $FileNameWildcard = [System.IO.Path]::GetFileNameWithoutExtension($Logfile) + "*"
             $SearchPath       = [System.IO.Path]::GetDirectoryName($Logfile) + "\"
             $Setlogfile = $Logfile
             [bool]$bfilefound = $false
             [int] $Count = 1
             
             Do
              { # Iterate 
                if (!(Test-Path -path $Setlogfile )) 
                 { $bfilefound = $true } # File does not Exist - will create it
                else
                 { # File Found Check Maximum Size
                   if ((Get-Item $Setlogfile).length -le $MaxLogSize)
                    {$bfilefound = $true} # File Exists below Maxsize limit - will use it
                   else
                    { # Need to search for a new file  
                      $FileNameNoExtensions = [System.IO.Path]::GetFileNameWithoutExtension($Logfile)
                      $FileExtension        = [System.IO.Path]::GetExtension($Logfile)
                      $Path                 = [System.IO.Path]::GetDirectoryName($Logfile)

                      $Setlogfile = $Path + "\" + $FileNameNoExtensions + "$count" + $FileExtension

                      $Count += 1
                    } # Need to search for a new file  
                 } # File Found Check Maximum Size
              }
            Until(($Count -gt $NumberOflogfiles) -or ($bfilefound))
            
            if ($bfilefound)
             { $Logfile = $Setlogfile }
            else
             {
               $OldestFile = Get-ChildItem -Path $SearchPath -Filter $FileNameWildcard | Sort-Object -property lastwritetime   | Select-Object -First 1
               $Logfile = $SearchPath + $OldestFile.Name
               Start-Sleep 1
               Remove-Item -Path $Logfile -Force -Confirm:$false 

             } # Rotate Logs Set
           } # Rotate Logs Set
          
          # See if the log file has been created if not create if it exsists write to it 
          if (!(Test-Path -path $Logfile )) 
           { # File does not Exist
             New-Item -Path $Logfile  -Type file  -force -value "Log file created" | Out-Null
             Add-content -Path $Logfile -value ( "`n`r" ) 
             Add-content -Path $Logfile -value $StrLOGLine
           } # File does not Exist
          else  
           { # File Exist
             Add-content -Path $Logfile -value $StrLOGLine 
           } # File Exist

          } # logfile not equal to Null
   } # Log String Does not equal to $Null

} # Write-STLog