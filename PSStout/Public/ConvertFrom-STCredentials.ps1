function ConvertFrom-STCredentials
 { # ConvertFrom-STCredentials
   <#   
   .SYNOPSIS   
      Converts secured userid and password files created by function ConvertTo-STCredentials and returns a Powershell Credential
   
   .DESCRIPTION 
      Converts secured userid and password files created by function ConvertTo-STCredentials and returns a Powershell Credential
      
   .PARAMETER UserNameFile (required)
      This is the full path name to the username file 

   .PARAMETER PasswordFile (required)
      This is the full path name to the password file

   .PARAMETER SecuredUserName (switch) (optional)
      Switch to tell the function that the UserName file has been secured by the ConvertTo-STCredentials using the switch -SecureUserName
      By default the userid file shows the userid in plaintext but if the ConvertTo-STCredentials uses the switch -SecureUserName
      the username file is secured. If you use switch -SecureUserName in Convertto-NCPSCredentials you will have to 
      use the switch -UserNameIsSecured in Convertfrom-NCPSCredentials

   .PARAMETER VerbosePeek (switch) (optional)
      Setting -verbosePeek switch the function will display username and password in warning console.
      WARNING - userid and pasword will be displayed (USE ONLY FOR TROUBLSHOOTING)

   .EXAMPLE  
      $credential = ConvertFrom-STCredentials -UserNameFile $useridfile -PasswordFile $passwordfile -UserNameIsSecured -Verbose
      Returns a PowerShell credential from the user name in the file $useridfile and from the password in the file $passwordfile 
      The user name file is in a secured format.
        
   .EXAMPLE 
      ConvertFrom-STCredentials -UserNameFile $useridfile -PasswordFile $passwordfile -UserNameIsSecured -Verbosepeek
      Returns a PowerShell credential from the user name in the file $useridfile and from the password in the file $passwordfile 
      The user name file is in a secured format. The userid and password will be displayed in the following format
        WARNING: Password and UserName will be displayed
        WARNING: UserName - tcruise
        WARNING: Password - missionimpossible
   
   .EXAMPLE       
      $credential = ConvertFrom-STCredentials -UserNameFile "username.dat" -PasswordFile "password.dat" 
      Returns a PowerShell credential from the user name in the file username.dat and from the password in the file password.dat. 
      The user name file is in plain text. If the username.dat is secured the function will return an error.
   
   .NOTES
     
     Current Version 1.0.0.0
      
     Version history 
      
     1.0.0.0 - 2025-02-27
               Function was versioned to be placed in the PSStout Modules
  #>  
    
   [cmdletbinding()]    
   Param (
              [Parameter(
                Mandatory = $TRUE,
                Position = 0)]
                [string]$UserNameFile,  
              [Parameter(
                Mandatory = $TRUE,
                Position = 1)]
                [string]$PasswordFile,
              [Parameter(
                Mandatory = $False)]
                [switch]$SecuredUserName,
              [Parameter(
                Mandatory = $False)]
                [switch]$VerbosePeek                       
             )
   
   [bool]$bVerbosePeek = $false
    if($VerbosePeek.IsPresent) 
     {
       write-verbose "Verbose Peek set - Password and UserName will be displayed"
       Write-Warning "Password and UserName will be displayed"
       $bVerbosePeek = $true
     }

    [bool]$bUserNameIsSecured = $false
    if($UserNameIsSecured.IsPresent) 
     {
       write-verbose "The Switch that the username is in secured format was set"
       $bUserNameIsSecured = $true
     }
   
   if($bUserNameIsSecured)
    { # Username is secured
      
      [bool]$bConvertError = $false
      try
       { $UserName       = Get-content $UserNameFile   | Convertto-SecureString}

      catch
       { $bConvertError = $true} # Error on Conversion
   
      if(! $bConvertError)
       { # No Error on Conversion
         $UserNameBasicString = [system.Runtime.InteropServices.Marshal]::secureStringToBSTR($UserName)
         $UserName = [system.Runtime.InteropServices.Marshal]::PtrToStringAuto($UserNameBasicString)
       } # No Error on Conversion
    } # Username is secured
   else
    { $UserName = Get-content $UserNameFile } # Username plain text
   
   if($bConvertError)
    { # Conversion Error
      
      write-verbose "Error converting the username from secured string check to see if it is in plaintext and remove switch -UserNameIsSecured, "
      Write-Error   "Error converting the username from secured string"
      $credential = $null
    
    } # Conversion Error
   else
    { # No Coversion Error
    
      $Password   = Get-content $passwordfile | ConvertTo-SecureString
      $credential = New-Object System.Management.Automation.PsCredential($UserName,$Password)

      if ($bVerbosePeek)
       { # Verbose Peek
         
         $BasicString = [system.Runtime.InteropServices.Marshal]::secureStringToBSTR($password)
         $password = [system.Runtime.InteropServices.Marshal]::PtrToStringAuto($BasicString)
         Write-Warning "UserName - $UserName"
         Write-Warning "Password - $password"
       
       } # Verbose Peek
    } # No Coversion Error
 
   return $credential

 } # ConvertFrom-STCredentials
