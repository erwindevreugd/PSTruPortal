<#
    .SYNOPSIS
    Sets a credential.

    .DESCRIPTION   
    Sets a credential. 
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Set-Credential
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Set-Credential {
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
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The id of the credential."
        )]
        [int]$CredentialId,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The id of the person."
        )]
        [int]$PersonId,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The card number of the credential."
        )]
        [string]$CardNumber,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The issue code of the credential."
        )]
        [int]$IssueCode,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The pin number of the credential."
        )]
        [int]$Pin,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The activation date of the credential."
        )]
        [string]$ActiveFrom,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The deactivation date of the credential."
        )]
        [string]$ActiveTo,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Exampts the credential from antipassback."
        )]
        [switch]$AntipassbackExempt,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Enables the credential to use extended access."
        )]
        [switch]$ExtendedAccess,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The access levels assigned to the credential."
        )]
        [int[]]$AccessLevels
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = "api/credentials"
        $method         = "PUT"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        if($CredentialId) {
            $uri = "$uri/$CredentialId"
        }

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