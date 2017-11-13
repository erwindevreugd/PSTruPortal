function Get-SessionKeyFromScriptContext {
    [CmdletBinding()]
    param (
    )
    
    begin {
    }
    
    process {

        $properties = @{
            SessionKey=$Script:SessionKey;
        }

        New-Object -TypeName PSObject -Property $properties
    }
    
    end {
    }
}