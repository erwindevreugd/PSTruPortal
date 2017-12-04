<#
    .SYNOPSIS
    Logout an user.

    .DESCRIPTION   
    Logout an user associated with the given session key.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Invoke-LogoutUser
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Invoke-LogoutUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The hostname or ip address of the controller."
        )]
        [string]$Host = $Script:Host,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The session key associated with an username to logout."
        )]
        [string]$SessionKey = $Script:SessionKey,

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
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = "api/auth/logout"
        $method         = "POST"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $headers = @{
            Authorization=$SessionKey;
        }
        $body = @{
        }
        $message = @{
            Uri=$uri;
            Method=$method;
            Body=(ConvertTo-Json $body);
            ContentType=$contentType;
            Headers=$headers;
        }

        Write-Verbose -Message "$($method) $($uri) $($contentType)"
        Write-Verbose -Message "Body:`n$(ConvertTo-Json $body)"

        Invoke-RestMethod @message | Out-Null
    }
    
    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}