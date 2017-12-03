<#
    .SYNOPSIS
    Removes an access level.

    .DESCRIPTION   
    Removes an access level.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Remove-AccessLevel
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Remove-AccessLevel {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact="High"
    )]
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
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The id of the access level to remove."
        )]
        [int]$AccessLevelId,

        [Parameter(
            Mandatory=$false, 
            ValueFromPipelineByPropertyName=$false,
            HelpMessage='Forces the removal of the access level with out displaying a should process.')]
        [switch]$Force
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = "api/accesslevels"
        $method         = "DELETE"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        if($AccessLevelId) {
            $uri = "$uri/$AccessLevelId"
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
        if($Force -or $PSCmdlet.ShouldProcess("$Host", "Removing AccessLevel: $($AccessLevelId)")) {
            Invoke-RestMethod @message | Out-Null
        }
    }
    
    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}