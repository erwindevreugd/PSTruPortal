function Set-Person {
    [CmdletBinding()]
    param (
        [Parameter(
            Position=0, 
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$Host = $Script:Host,

        [Parameter(
            Position=1, 
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$SessionKey = $Script:SessionKey,

        [Parameter(
            Mandatory=$true
        )]
        [int]$Id,

        [Parameter(
            Mandatory=$false
        )]
        [string]$FirstName = $null,

        [Parameter(
            Mandatory=$false
        )]
        [string]$MiddleName = $null,

        [Parameter(
            Mandatory=$false
        )]
        [string]$LastName = $null,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$UseSSL = $Script:UseSSL,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = "api/persons"
        $method         = "PUT"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        if($Id) {
            $uri = "$uri/$Id"
        }

        $headers = @{
            Authorization=$SessionKey;
        }
        
        $body = @{
        }

        if($FirstName) {
            $body.Add("firstname", $FirstName)
        }

        if($MiddleName) {
            $body.Add("middlename", $MiddleName)
        }

        if($LastName) {
            $body.Add("lastname", $LastName)
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
        Invoke-RestMethod @message | Out-Null
    }
    
    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}