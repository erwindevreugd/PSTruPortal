<#
    .SYNOPSIS
    Gets the current session key stored in the script context.

    .DESCRIPTION   
    Gets the current session key stored in the script context. 
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Get-SessionKeyFromScriptContext
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Get-SessionKeyFromScriptContext {
    [CmdletBinding()]
    param (
    )

    process {

        $properties = @{
            SessionKey=$Script:SessionKey;
        }

        New-Object -TypeName PSObject -Property $properties
    }
}