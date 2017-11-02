function Get-Event {
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

        [Parameter()]
        [int]$Id,

        [Parameter()]
        [int]$Type,

        [Parameter()]
        [int]$PersonId,

        [Parameter()]
        [int]$DeviceId,

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
        $endPoint       = "api/events"
        $method         = "GET"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"
        
        $headers = @{
            Authorization=$SessionKey;
        }
        $query = @{
            limit=$Limit;
        }

        if($Type) {
            $query.Add("type", $Type)
        }

        if($PersonId) {
            $query.Add("personId", $PersonId)
        }

        if($DeviceId) {
            $query.Add("deviceId", $DeviceId)
        }

        if($Id) {
            $uri = "$uri/$Id"
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
        try {
            $response = Invoke-RestMethod @message
        }
        catch {
            throw $_
            return
        }
        $response | ForEach-Object {
            New-Object -TypeName PSObject -Property @{
                Id=$_.id;
                Type=$_.type;
                Description=$_.description;
                PersonId=$_.personId;
                PersonName=$_.personName;
                DeviceId=$_.deviceId;
                DeviceName=$_.deviceName;
                Timestamp=$_.timestamp;
                DateTime=([DateTime]"1/1/1970").AddSeconds($_.timestamp)
            }
        }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}