<#
    .SYNOPSIS
    Sets the script context variables.

    .DESCRIPTION   
    Sets the script context variables.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Set-ScriptContext
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Set-ScriptContext {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The hostname or ip address of the controller."
        )]
        [string]$Host = $Script:Host,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The username."
        )]
        [string]$Username,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The session key."
        )]
        [string]$SessionKey,

        [Parameter(
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Use a secure connection to the controller."
        )]
        [switch]$UseSSL = $Script:UseSSL,

        [Parameter(
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Allows a connection to be made to the controller even if the certificate on the controller is invalid. 
            Set this switch if the controller uses a self-signed certificate."
        )]
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors
    )
    
    process {
        $Script:Host=$Host
        $Script:Username=$Username
        $Script:SessionKey=$SessionKey
        $Script:UseSSL=$UseSSL
        $Script:IgnoreCertificateErrors=$IgnoreCertificateErrors
        $Script:Timestamp=[DateTime]::UtcNow
 
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
}