<#
    .SYNOPSIS
    Login a user using an username and password.

    .DESCRIPTION   
    Login a user using an username and password and get a session key used to authenticate the user on the controller.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Invoke-LoginUser
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Invoke-LoginUser {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    param (
        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The hostname or ip address of the controller."
        )]
        [string]$Host = $Script:Host,

        [Parameter(
            Mandatory=$true,
            HelpMessage="The username used to authenticate to the controller."
        )]
        [string]$Username,

        [Parameter(
            Mandatory=$true,
            HelpMessage="The password used to authenticate to the controller."
        )]
        [string]$Password,

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
        $endPoint       = "api/auth/login"
        $method         = "POST"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $headers = @{
        }
        
        $body = @{
            "username"=$Username;
            "password"=$Password;
        }

        Write-Verbose -Message "$($method) $($uri) $($contentType)"
        Write-Verbose -Message "Body:`n$(ConvertTo-Json $body)"

        $message = @{
            Uri=$uri;
            Method=$method;
            Body=(ConvertTo-Json $body);
            ContentType=$contentType;
            Headers=$headers;
            UseBasicParsing=$true;
        }
        $response = Invoke-RestMethod @message
        $properties = @{
            Host=$Host;
            Username=$Username;
            SessionKey=$response.sessionKey;
            UseSSL=$UseSSL;
            IgnoreCertificateErrors=$IgnoreCertificateErrors;
            Timestamp=[DateTime]::UtcNow;
        }

        New-Object -TypeName PSObject -Property $properties
    }
    
    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}