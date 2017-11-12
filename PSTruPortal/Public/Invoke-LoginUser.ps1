function Invoke-LoginUser {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$Host,

        [Parameter(
            Mandatory=$true
        )]
        [string]$Username,

        [Parameter(
            Mandatory=$true
        )]
        [string]$Password,

        [Parameter()]
        [switch]$UseSSL,

        [Parameter()]
        [switch]$IgnoreCertificateErrors
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