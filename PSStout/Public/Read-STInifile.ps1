Function Read-STIniFile  
 { # Read-STIniFile
   
   <#   
   .SYNOPSIS   
      Reads an INI file from either the notes field of an AD security group or from the INI file path.    
   
   .DESCRIPTION 
      Reads an INI file from either the notes field of an AD security group or from the INI file path and returns it as PowerShell object. 
      Function uses regex to determine if the INI file is an INI section or a INI name value keypair. 
      Ignores comment lines and does not include them. Returned object has a Name and Value field. 
      Name is the INI section, and Value are the INI key pairs for that INI section. 
      If the INI file does not have a section, it uses the default NO_SECTION 
   
   .PARAMETER IniLocation 
      Path to the INI object either AD security group notes field or an INI file path.
   
   .PARAMETER logFile 
      Path to the Log file.
   
   .EXAMPLE 1 - Reading a Windows INI file
     $test = Read-STIniFile -IniLocation "c:\windows\system.ini" -Verbose
     Test will hold the object to the system INI
            Name                           Value                                                                                                                           
            ----                           -----                                                                                                                           
            NO_SECTION                     {}                                                                                                                              
            386Enh                         {EGA40WOA.FON, woafont, EGA80WOA.FON, CGA80WOA.FON...}                                                                          
            mci                            {}                                                                                                                              
            drivers                        {timer, wave}    
     
     to access the 386Enh section you would use $test.'386Enh' (Note it has to be in quotes because it starts with a number)

            $test.'386Enh'

            Name                           Value                                                                                                                           
            ----                           -----                                                                                                                           
            EGA40WOA.FON                   EGA40WOA.FON                                                                                                                    
            woafont                        dosapp.fon                                                                                                                      
            EGA80WOA.FON                   EGA80WOA.FON                                                                                                                    
            CGA80WOA.FON                   CGA80WOA.FON                                                                                                                    
            CGA40WOA.FON                   CGA40WOA.FON
     
     to access the drivers section you would use $test.drivers  

            $test.drivers

            Name                           Value                                                                                                                           
            ----                           -----                                                                                                                           
            timer                          timer.drv                                                                                                                       
            wave                           mmdrv.dll  

   .EXAMPLE 2 - read the notes field of a security group
     
     $test = Read-STIniFile -IniLocation "NCW_DFS_Groups_Folder_Parameter" 
     $test.'NO_SECTION'

        Name                           Value                                                                                                                                                           
        ----                           -----                                                                                                                                                           
        ServerShare                    "Groups"                                                                                                                                                        
        whatif                         False                                                                                                                                                           
        FromAddr                       dfs_Groups@example.com                                                                                                                                           
        RemoteServerRootFolderList     "\\Secretstuff\groups","\\Secretstuff\groups1$"
        smtpserver                     edge.ncwest.ncsoft.corp                                                                                                                                         
        DFSRootFolder                  "\\NCW\Folders"                                                                                                                                                 
        logFile                        "SyncDFSGroupsTargets"                                                                                                                                          
        ReplyAddr                      noreply@ncsoft.com

   .NOTES
       
       Current Version 1.0.0.0
       Version history 
      
       1.0.0.0 - 2025-02-28 - Initial version.
 #>  

   [cmdletbinding()] 
   Param (
           [Parameter( 
             Mandatory = $true,
             Position = 0)]
             [string] $IniLocation,
           [Parameter(
             Mandatory = $false,
             Position = 1)]
            [string]$logFile = $null
          )

   # Create a default section if none exist in the file. Like a java prop file.
   $ini = @{}
   $section = "NO_SECTION"
   $ini[$section] = @{}
   
   if(Test-path $IniLocation)
    { # Read from File
      
      write-verbose "File $IniLocation - found"
      Write-STPSLog "File $IniLocation - found" -Logfile $logfile

      switch -regex -file $IniLocation 
       { # Switch
                          "^\[(.+)\]$" { # ini Section Pattern
                                         $section = $matches[1].Trim()
                                         write-verbose "found section - $section"
                                         Write-STPSLog "found section - $section" -Logfile $logfile
                                         $ini[$section] = @{}
                                       } # ini Section Pattern
    
            "^\s*([^#].+?)\s*=\s*(.*)" { # ini Data key pair values
                                         $name,$value = $matches[1..2]
                                         write-verbose "Found keypair - name=>$name< - value=>$value<"
                                         Write-STPSLog "Found keypair - name=>$name< - value=>$value<" -Logfile $logfile
                                         if (!($name.StartsWith(";"))) {$ini[$section][$name] = $value.Trim()} # skip comments that start with semicolon:
                                       } # ini Data key pair values
       } # Switch

    } # Read from File
   else
    { # Read from an AD group

      $ADGroupName =  $IniLocation -Replace '^cn=([^,]+).+$', '$1'
      $searcher = [adsisearcher]"(&(objectCategory=group)(samaccountname=$ADGroupName))"
      $LDAPGroupUrl = $($searcher.FindOne()).Path
      [bool]$bLdapGroupGood  = [ADSI]::Exists($LDAPGroupUrl)

      if ($bLdapGroupGood)
       { # SGParamGroup Group Exists

         write-verbose "AD Group $IniLocation - found"
         Write-STPSLog "AD Group $IniLocation - found" -Logfile $logfile
         $Group = [ADSI]$LDAPGroupUrl
         foreach($line in $($Group.info).Split("`r`n"))
          { # Foreach line in the ini file
            
            switch -regex ($line)
              { # Switch
                                  "^\[(.+)\]$" { # ini Section Pattern
                                                 $section = $matches[1].Trim()
                                                 write-verbose "found section - $section"
                                                 Write-STPSLog "found section - $section" -Logfile $logfile
                                                 $ini[$section] = @{}
                                               } # ini Section Pattern
    
                    "^\s*([^#].+?)\s*=\s*(.*)" { # ini Data key pair values
                                                 $name,$value = $matches[1..2]
                                                 write-verbose "Found keypair - name=>$name< - value=>$value<"
                                                 Write-STPSLog "Found keypair - name=>$name< - value=>$value<" -Logfile $logfile
                                                 if (!($name.StartsWith(";"))) {$ini[$section][$name] = $value.Trim()} # skip comments that start with semicolon:
                                               } # ini Data key pair values
              } # Switch
          }  # Foreach line in the ini file 
       } # SGParamGroup Group Exists
    } # Read from an AD group

   return $ini

 } # Read-STIniFile