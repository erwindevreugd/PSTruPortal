function Get-AccessLevel {
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
        [int]$AccessLevelId,

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
        $endPoint       = "api/accessLevels"
        $method         = "GET"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $headers = @{
            Authorization=$SessionKey;
        }

        $query = @{
            limit=$Limit;
        }

        if($AccessLevelId) {
            $uri = "$uri/$AccessLevelId"
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
                AccessLevelId=$_.id;
                Name=$_.name;
                ReaderGroupSchedules=$_.readerGroupSchedules | 
                    ForEach-Object { New-Object -TypeName PSObject -Property @{ 
                        ReaderGroupId=$_.readerGroupId; 
                        ScheduleId=$_.scheduleId; } }
                ReaderSchedules=$_.readerSchedules | 
                    ForEach-Object { New-Object -TypeName PSObject -Property @{ 
                        ReaderId=$_.readerId; 
                        ScheduleId=$_.scheduleId; } }
            }
        }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}