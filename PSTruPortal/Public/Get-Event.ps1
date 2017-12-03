<#
    .SYNOPSIS
    Gets multiple events or a single event if a event id is specified.

    .DESCRIPTION   
    Gets multiple events or a single event if a event id is specified.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Get-Event
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Get-Event {
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
            HelpMessage="The session key used to authenticate to the controller."
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
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The id of the event."
        )]
        [int]$EventId,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The type of events to retrieve."
        )]
        [int]$EventType,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The person id for which to retrieve events."
        )]
        [int]$PersonId,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The device id for which to retrieve events."
        )]
        [int]$DeviceId,

        [Parameter(
            HelpMessage="The maximum number of results to return. The maximum number of results that can be returned by a single request is 250."
        )]
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

        if($EventId) {
            $uri = "$uri/$EventId"
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
                EventId=$_.id;
                EventType=$_.type;
                Description=$_.description;
                PersonId=$_.personId;
                PersonName=$_.personName;
                DeviceId=$_.deviceId;
                DeviceName=$_.deviceName;
                Timestamp=$_.timestamp;
                DateTime=([DateTime]"1/1/1970").AddSeconds($_.timestamp)
            } | Add-ObjectType -TypeName "TruPortal.Event"
        }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}