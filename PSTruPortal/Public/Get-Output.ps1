<#
    .SYNOPSIS
    Gets multiple outputs or a single output if an output id is specified.

    .DESCRIPTION   
    Gets multiple outputs or a single output if an output id is specified.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Get-Output
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Get-Output {
    [CmdletBinding()]
    param (
        [Parameter(
            Position=0, 
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The hostname or ip address of the controller."
        )]
        [string]$Host = $Script:Host,

        [Parameter(
            Position=1, 
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
            HelpMessage="The id of the output."
        )]
        [int]$OutputId,

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
        $endPoint       = "api/devices/outputs"
        $method         = "GET"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $headers = @{
            Authorization=$SessionKey;
        }
        $query = @{
            limit=$Limit;
        }

        if($OutputId) {
            $uri = "$uri/$OutputId"
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
                OutputId=$_.id;
                Name=$_.name;
                State=$_.state;
            } | Add-ObjectType -TypeName "TruPortal.Output"
        }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}