function Compare-STMSVersionNumbers
  { # Compare-STMSVersionNumbers
    
    [cmdletbinding()]
    Param (
           [Parameter( 
             Mandatory = $true,
             Position = 0)]
             [version]$current,
           [Parameter( 
             Mandatory = $True,
             Position = 1)]
             [version]$latest,
            [Parameter( 
             Mandatory = $false,
             Position = 2)]
             [byte]$build_tolerance = 0,
            [Parameter( 
             Mandatory = $false)]
             [switch]$Assembly 
           )
    <#   
     .SYNOPSIS   
        Compares MS version numbers. Current version is compared to latest version.
        Allows a plus and minus tolerance in comparison of the build portion of the version number.
        By default the revision portion of the version number is ignored unless the Assembly switch is used.
        Returns  0 if Current version equals to    latest version.
        Returns  1 if Current version less than    latest version.
        Returns -1 if Current version greater than latest version.

     .DESCRIPTION 
        Compares MS version numbers. Current version is compared to latest Version. 
        Allows a plus and minus tolerance in comparison of build portion of the version number.
        By default the revision number is ignored unless the Assembly switch is used.
        Returns  0 if Current version equals to    latest version.
        Returns  1 if Current version less than    latest version.
        Returns -1 if Current version greater than latest version.

        MS Version defined 
        Version numbers consist of four components: Major, Minor, Build, and Revision. 
        All defined components must be integers greater than or equal to 0. 
        The format of the version number is as follows:

           Major.Minor.Build.Revision
        
        Compare-STMSVersionNumbers allows for build tolerance by setting an optional build_tolerance. 
        If build_tolerance is set the function will check build numbers to be plus or minus within 
        build tolerance range. If major, minor version numbers are equal and the build numbers is 
        within tolerance the function returns 0

        By default Compare-STMSVersionNumbers ignores the revision portion of the version number.
        If the use_revision switch is set the revision number will be checked.
    
     .PARAMETER current (Mandatory) 
        Current version of driver or software to compare

     .PARAMETER latest (Mandatory) 
        Latest version of driver or software to compare  

     .PARAMETER $build_tolerance (optional) 
        Build_tolerance is a byte that can bet set from 0 to 255 
        Build_Tolerance is a range that allows for the Current Build to be within plus or minus tolerance of Latest Build.
        If Current Major and Minor = Latest Major and Minor and the Current Build is within +\- build_tolerance - returns 0.
        Build_tolerance defaults to 0
     
     .Parameter $Assembly (optional) 
        Assembly switch is used to compare the revision portion of the version number. 
        By default the revision portion of the version number is ignored.
        If the Assembly switch is set the revision number will be checked.
        The revision number is the fourth component of the version number and is used to identify a specific build of the software.
     
        .example
        Compare-STMSVersionNumbers 2.0.0.1 2.0.0.2
        returns 0 
        Major, Minor and Build of current and latest are equal - current and latest revison is ignored.

     .example
        Compare-STMSVersionNumbers 2.0.0.1 2.0.1.2 
        Returns 1
        Major and Minor of Current and Latest are equal but Current Build 0 < Latest Build 1 

     .example
        Compare-STMSVersionNumbers 2.0.1.1 2.0.0.2 
        Return -1  
        Major and Minor of Current and Latest are equal but the Current Build 1 > Latest Build 0

     .example
        Compare-STMSVersionNumbers 2.0.1.1 2.0.0.2 2 
        Return 0 
        Major and Minor of Current and Latest are equal and the Current Build 1 > Latest Build 0 but within +/- build_tolerance of 2.
     
     .Notes
      Microsoft uses several versioning standards across its products and libraries. Function uses the following key points:

      1. **Semantic Versioning (SemVer)**:
         - Commonly used for NuGet and MSI packages.
         - Format: **Major.Minor.Patch** (e.g., 1.0.0).
         - Major version changes indicate breaking changes, minor versions add functionality in a backward-compatible manner, and patch versions include backward-compatible bug fixes.

      2. **Assembly Versioning**:
         - Used by the .NET runtime to load the correct version of an assembly.
         - Format: **Major.Minor.Build.Revision** (e.g., 1.0.0.0).
         - Strong-named assemblies require an exact version match unless a binding redirect is specified

      
      Current Version 1.0.0.0
      
      Version history 
      
      1.0.0.0 - 2025-02-27 - Initial release of Compare-STMSVersionNumbers function.
                Function was versioned to be placed in the PSStout Modules

      Reference
      Versioning and .NET libraries - .NET | Microsoft Learn. https://learn.microsoft.com/en-us/dotnet/standard/library-guidance/versioning.
      Assembly versioning - .NET | Microsoft Learn. https://learn.microsoft.com/en-us/dotnet/standard/assembly/versioning.
      Read This to Understand Windows 10 Update Names and Numbers - How-To Geek. https://www.howtogeek.com/697411/read-this-to-understand-windows-10-update-names-and-numbers/.
      Software versioning - Wikipedia. https://en.wikipedia.org/wiki/Software_versioning.
      Enable and configure versioning for a list or library - Microsoft Support. https://support.microsoft.com/en-gb/office/enable-and-configure-versioning-for-a-list-or-library-1555d642-23ee-446a-990a-bcab618c7a37.
      https://semver.org/ 

   #>   
    Write-Verbose "Compare-STMSVersionNumbers function called"
    Write-Verbose "Current Version: $current"
    Write-Verbose "Latest Version: $latest"
    [bool]$bAssembly = $false
    if ($Assembly.IsPresent) 
      { # Assembly switch is set
        $bAssembly = $true
        Write-Verbose "Assembly switch is set - revision portion of version number will be checked"
      } # Assembly switch is set
    
    $ReturnValue = 0
    [int]$delta_major    = $latest.Major    - $current.Major
    [int]$delta_minor    = $latest.Minor    - $current.Minor
    [int]$delta_build    = $latest.Build    - $current.Build
    [int]$delta_revision = $latest.Revision - $current.Revision   

    switch ($delta_major)
      { # Major switch
        {$_ -lt 0} 
          { # Current Major Version > Latest Major Version 
            Write-Verbose "Current Major Version > Latest Major Version"
            $ReturnValue = -1
          } # Current Major Version > Latest Major Version 
        
        {$_ -gt 0} 
          { # Current Major Version < Latest Major Version
            Write-Verbose "Current Major Version < Latest Major Version"
            $ReturnValue = 1
          } # Current Major Version < Latest Major Version

        {$_ -eq 0} 
         { # Current Major Version = Latest Major Version
           Write-Verbose "Current Major Version = Latest Major Version"
                   
           switch ($delta_minor)
             { # Minor switch
               {$_ -lt 0} 
                 { # Current Minor Version > Latest Minor Version 
                   Write-Verbose "Current Minor Version > Latest Minor Version"
                   $ReturnValue = -1
                 } # Current Minor Version > Latest Minor Version 
        
               {$_ -gt 0} 
                 { # Current Minor Version < Latest Minor Version
                   Write-Verbose "Current Minor Version < Latest Minor Version"
                   $ReturnValue = 1
                 } # Current Minor Version < Latest Minor Version

               {$_ -eq 0} 
                 { # Current Minor Version = Latest Minor Version
                   Write-Verbose "Current Minor Version = Latest Minor Version"
                   if($([Math]::Abs($delta_build)) -le $build_tolerance)
                    { # Current build Version = Latest Build Version 
                      Write-Verbose "Current Build Version = or within tolerance of Latest Build Version"

                      if($bAssembly)
                        { # Assembly switch is set - revision portion of version number will be checked
                          Write-Verbose "Assembly switch is set - revision portion of version number will be checked"
                          
                          if($delta_revision -eq 0) 
                            { # Current Revision Version = Latest Revision Version 
                              Write-Verbose "Current Revision Version = Latest Revision Version"
                            } # Current Revision Version = Latest Revision Version 
                          elseif($delta_revision -lt 0) 
                            { # Current Revision Version > Latest Revision Version
                              Write-Verbose "Current Revision Version > Latest Revision Version"
                              $ReturnValue = -1
                            } # Current Revision Version > Latest Revision Version 
                          else  
                            { # Current Revision Version < Latest Revision Version
                              Write-Verbose "Current Revision Version < Latest Revision Version"
                              $ReturnValue = 1
                            } # Current Revision Version < Latest Revision Version 
                        } # Assembly switch is set - revision portion of version number will be checked                    
                      } # Current Build Version = Latest Build Version 

                   else  
                    { # Current Build Version != Latest Build Version 
                      switch ($delta_build)
                        { # Build switch
                          {$_ -lt 0} 
                            { # Current build Version > Latest build Version
                              Write-Verbose "Current Build Version > Latest Build Version"
                              $ReturnValue = -1
                            } # Current build Version > Latest build Version

                          {$_ -gt 0} 
                            { # Current build Version < Latest Build Version
                              Write-Verbose "Current Build Version < Latest Build Version"
                              $ReturnValue = 1
                            } # Current build Version < Latest Build Version

                        } # Build switch
                    }  # Current Build Version != Latest Build Version    
                 } # Current Minor Version = Latest Minor Version
             } # Minor switch
         } # Major current Version = Latest Major Version
      } # Major switch
    
      return $ReturnValue
  
    } # Compare-STMSVersionNumbers