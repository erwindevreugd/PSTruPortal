function Get-SessionKeyFromScriptContext {
    [CmdletBinding()]
    param (
    )
    
    begin {
    }
    
    process {

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
    
    end {
    }
}