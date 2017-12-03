<#
    .SYNOPSIS
    Gets multiple credentials or a single credential if a credential id is specified.

    .DESCRIPTION   
    Gets multiple credentials or a single credential if a credential id is specified.
    
    If the result return null, try the parameter "-Verbose" to get more details.
    
    .EXAMPLE
    Get-Credential
    
    .LINK
    https://github.com/erwindevreugd/PSThruPortal
#>
function Get-Credential {
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
            HelpMessage="The id of the credential."
        )]
        [int]$CredentialId,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The id of the person."
        )]
        [int]$PersonId,

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
        $endPoint       = "api/credentials"
        $method         = "GET"
        $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $headers = @{
            Authorization=$SessionKey;
        }

        $query = @{
            limit=$Limit;
        }

        if($CredentialIdId) {
            $uri = "$uri/$CredentialId"
        }

        if($PersonId) {
            $query.Add("personId", $PersonId)
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
                CredentialId=$_.id;
                ActiveFrom=$_.activeFrom;
                ActiveTo=$_.activeTo;
                AntipassbackExempt=$_.antipassbackExempt;
                CardNumber=$_.cardNumber;
                AccessLevels=$_.accessLevels;
                Pin=$_.pin;
                PersonId=$_.PersonId;
                ExtendedAccess=$_.extendedAccess;
                IssueCode=$_.issueCode;
            } | Add-ObjectType -TypeName "TruPortal.Credential"
        }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}