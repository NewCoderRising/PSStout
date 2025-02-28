Function ConvertTo-STBoolean
{ # ConvertTo-STBoolean
  
  <#  
   .SYNOPSIS
     Function returns PowerShell Boolean $true or $false depending on the input string value $BooleanString
     
   .DESCRIPTION
     Function returns PowerShell Boolean values $true or $false depending on the input string value $BooleanString.  
     If the input $BooleanString is any of the following (case does not matter) "T", "True", "1", or "ON" 
     the function returns Boolean $true otherwise it will return Boolean $false. 
     NOTE - Calling the function with no value or anything else not listed above the function returns Boolean $False. 

     Function designed for importing a CSV file that was CSV exported and the file has Booleans values. 
     A PowerShell import will interpret the Boolean values as string and those values will need to be 
     converted back to Boolean if you plan to use the values for any Boolean logic. 
     This function is designed to be used in a pipeline.
   
   .PARAMETER strBoolean
     A string that should repersent a Powershell Boolean 
     If the string is NOT one of the following "T", "True", "1", or "ON" the function will return Boolean $false.
     If the string is one of the following "T", "True", "1", or "ON" the function will return Boolean $true. 
 
   .Example
     ConvertTo-STBoolean
     Returns boolean False.
     
   .Example 
     ConvertTo-STBoolean True
     Returns boolean True.

   .Example
     ConvertTo-STBoolean on
     Returns boolean True.
   
   .Example
     ConvertTo-STBoolean 1
     Returns boolean True.
   
   .Example
     ConvertTo-STBoolean -BooleanString "false"
     Returns boolean False.
   
   .Example
     ConvertTo-STBoolean -BooleanString "F"
     Returns boolean False.

   .Example
     'T' | ConvertTo-STBoolean 
     Returns boolean True.
  
    .Example 
     ("t", "f") | ConvertTo-STBoolean
     returns boolean True, False.

   .Example
     "This is stupid" | ConvertTo-STBoolean  
     Returns boolean False.
    
   .Notes
     I had limited success in re-casting the string values as Boolean values.
     I have tried to use the [bool] type cast but it does not work as expected. 
     I may come back to this I feel there is a simple solution but this works.

     Current Version 1.0.0.0
 
     Version history
       
      1.0.0.0 - Version on 2025-02-28
                Version it and name it to add to the module PSStouts 
#> 
  [cmdletbinding()]
  Param (
         [Parameter( 
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [AllowEmptyString()]
            [AllowNull()]
            [string]$BooleanString
      )

    # Function to convert a string to a PowerShell Boolean value
  
  process 
    { # Begin Process
      [bool]$rtvalue = $false # Default value is $false

      # Check if the input is null or empty and return $false
      if ($null -eq $BooleanString) { return $rtvalue } 
      if ($BooleanString -eq "") { return $rtvalue } 

      # Convert the string to upper case and check for true values
      # If the string is not one of the true values return $false

      switch ($BooleanString.ToUpper())
        { # Begin Switch
                
            "1"     { $rtvalue = $true;  break }  # True
            "T"     { $rtvalue = $true;  break }  # True
            "TRUE"  { $rtvalue = $true;  break }  # True
            "ON"    { $rtvalue = $true;  break }  # True 
                            
        } # End Switch
   
      return $rtvalue
    } # End Process
  
} # ConvertTo-STBoolean