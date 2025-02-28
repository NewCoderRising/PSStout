Function ConvertTo-STPSStringToScriptBlock
{ # ConvertTo-STPSStringToScriptBlock

  <#
    .SYNOPSIS
     Convert string value passed by pipeline into script block value.
    
    .DESCRIPTION
     Convert string value passed by pipeline into script block value.
     It can be used for calls to Invoke-Command cmdlet which accepts script block value in the parameter ScriptBlock.
      For example, the Invoke-Command cmdlet has a ScriptBlock parameter that takes a script block value, as shown in this example:

        Invoke-Command -ScriptBlock { Get-Process }

    .PARAMETER string
     Input value of string that will be converted into script block type value.

    .EXAMPLE
     $sb = "Get-Service" | ConvertTo-STPSStringToScriptBlock
     Invoke-Command -ScriptBlock $sb

     String value "Get-Service" is coverted into a scriptblock and kept in $sb variable.
     The Invoke-Command cmdlet runs the scriptblock {Get-Service}
     The function Get-Service is executed.        

     Status   Name               DisplayName
     ------   ----               -----------
     Stopped  AarSvc_88841       Agent Activation Runtime_88841
     Stopped  ALG                Application Layer Gateway Service
     Stopped  AppIDSvc           Application Identity
     :
     :
     
    .NOTES
     
     Current Version 1.0.0.0
      
     Version history 
      
     1.0.0.0 - 2025-02-28
               Versioned for Powershell module PSStout
  
  #>
                                                                                    
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline=$true,
                    Position=0,
                    Mandatory=$false,
                    HelpMessage="Input string that will this CmdLet convert into Script Block.")] 
        [string]$string
    )
     
    BEGIN { } # Begin Process
    
    PROCESS {  

        Write-Verbose "Starting converting string to script block..."

        $sb = [scriptblock]::Create($string)
    
        Write-Verbose "Converting string to script block finished."

        return $sb

    }        
    
    END { }

} # ConvertTo-STPSStringToScriptBlock
