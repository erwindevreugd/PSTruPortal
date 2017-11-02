function Set-ScriptContext {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$Host,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$Username,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$SessionKey,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$UseSSL,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$IgnoreCertificateErrors
    )
    
    process {

        $Script:Host=$Host
        $Script:Username=$Username
        $Script:SessionKey=$SessionKey
        $Script:UseSSL=$UseSSL
        $Script:IgnoreCertificateErrors=$IgnoreCertificateErrors
        $Script:Timestamp=[DateTime]::UtcNow
 
        $properties = @{
            Host=$Script:Host;
            Username=$Script:Username;
            SessionKey=$Script:SessionKey;
            UseSSL=$Script:UseSSL;
            IgnoreCertificateErrors=$Script:IgnoreCertificateErrors;
            Timestamp=$Script:Timestamp;
        }

        New-Object -TypeName PSObject -Property $properties
    }
}