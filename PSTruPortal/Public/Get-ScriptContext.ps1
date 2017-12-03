<#
    .SYNOPSIS
    Gets the script context variables.

    .DESCRIPTION   
    Gets the script context variables. 
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Get-ScriptContext
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Get-SessionKeyFromScriptContext {
    [CmdletBinding()]
    param (
    )
    
    begin {
    }
    
    process {

        $properties = @{
            Host=$Script:Host;
            Username=$Script:Username;
            SessionKey=$Script:SessionKey;
            UseSSL=$Script:UseSSL;
            IgnoreCertificateErrors=$Script:IgnoreCertificateErrors;
            Timestamp=$Script:Timestamp;
        }

        New-Object -TypeName PSObject -Property $properties
    }
    
    end {
    }
}