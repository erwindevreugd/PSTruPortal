<#
    .SYNOPSIS
    Removes a person.

    .DESCRIPTION   
    Removes a person.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Remove-Person
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Remove-Person {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact="High"
    )]
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
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The id of the person to remove."
        )]
        [int]$PersonId,

        [Parameter(
            Mandatory=$false, 
            ValueFromPipelineByPropertyName=$false,
            HelpMessage='Forces the removal of the person with out displaying a should process.')]
        [switch]$Force
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = "api/persons"
        $method         = "DELETE"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        if($PersonId) {
            $uri = "$uri/$PersonId"
        }

        $headers = @{
            Authorization=$SessionKey;
        }
        
        $body = @{
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
        if($Force -or $PSCmdlet.ShouldProcess("$Host", "Removing Person: $($PersonId)")) {
            Invoke-RestMethod @message | Out-Null
        }
    }
    
    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}