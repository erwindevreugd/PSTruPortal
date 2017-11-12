function Add-Credential {
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
        [int]$PersonId,

        [Parameter(
            Mandatory=$true
        )]
        [string]$CardNumber,

        [Parameter(
            Mandatory=$false
        )]
        [int]$IssueCode,

        [Parameter(
            Mandatory=$false
        )]
        [int]$Pin,

        [Parameter(
            Mandatory=$false
        )]
        [string]$ActiveFrom,

        [Parameter(
            Mandatory=$false
        )]
        [string]$ActiveTo,

        [Parameter(
            Mandatory=$false
        )]
        [switch]$AntipassbackExempt,

        [Parameter(
            Mandatory=$false
        )]
        [switch]$ExtendedAccess,

        [Parameter(
            Mandatory=$false
        )]
        [int[]]$AccessLevels,

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
        $endPoint       = "api/credentials"
        $method         = "POST"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $headers = @{
            Authorization=$SessionKey;
        }
        
        $body = @{
            "personId"=$PersonId;
            "cardNumber"=$CardNumber;
        }

        if($IssueCode) {
            $body.Add("issueCode", $IssueCode)
        }

        if($Pin) {
            $body.Add("pin", $Pin)
        }

        if($ActiveFrom) {
            $body.Add("activeFrom", $ActiveFrom)
        }

        if($ActiveTo) {
            $body.Add("activeTo", $ActiveTo)
        }

        if($AntipassbackExempt) {
            $body.Add("antipassbackExempt", $AntipassbackExempt)
        }

        if($ExtendedAccess) {
            $body.Add("extendedAccess", $ExtendedAccess)
        }

        if($AccessLevels) {
            $body.Add("accessLevels", $AccessLevels)
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