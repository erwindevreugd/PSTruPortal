function Get-Person {
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
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$UseSSL = $Script:UseSSL,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$FirstName,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$MiddleName,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$LastName,

        [Parameter()]
        [ValidateRange(1,250)]
        [int]$Limit = 250
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = "api/persons"
        $method         = "GET"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $headers = @{
            Authorization=$SessionKey;
        }
        $query = @{
            limit=$Limit;
        }

        if($FirstName) {
            $query.Add("firstName", $FirstName)
        }

        if($MiddleName) {
            $query.Add("middleName", $MiddleName)
        }

        if($LastName) {
            $query.Add("lastName", $LastName)
        }

        Write-Verbose -Message "$($method) $($uri) $($contentType)"
        Write-Verbose -Message "Query:`n$(ConvertTo-Json $query)"

        $message = @{
            Uri=$uri;
            Method=$method;
            Body=$query;
            ContentType=$contentType;
            Headers=$headers;
            UseBasicParsing=$true;
        }
        $response = Invoke-RestMethod @message
        $response | ForEach-Object {
            New-Object -TypeName PSObject -Property @{
                PersonId=$_.id;
                FirstName=$_.firstname;
                MiddleName=$_.middlename;
                LastName=$_.lastname;
                UserDefinedFields=$_.userDefinedFields | 
                    ForEach-Object { New-Object -TypeName PSObject -Property @{ 
                        Id=$_.id;
                        Data=$_.data; } }
            }
        }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}