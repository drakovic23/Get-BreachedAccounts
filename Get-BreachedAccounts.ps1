function Get-BreachedAccountss
(
    [Parameter(Position=0, ParameterSetName="email")]
    [string]$email,
    [Parameter(Position=0,ParameterSetName="emailArray")]
    [string[]]$emailArray,
    [switch]$unverified
)
{
    [Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11"
    if($email)
    {
        $url = "https://haveibeenpwned.com/api/v2/breachedaccount/" + $email
        if($unverified)
        {
            $url += "?includeUnverified=true"
        }
        try {
            $Response = Invoke-WebRequest -Uri $url -UsebasicParsing | ConvertFrom-Json
            Write-Host($Response.length.ToString() + " validated breaches found for " + $email)
            $Response| Select-Object name, domain, breachdate, pwncount
        }
        catch{
            if($_.Exception.Response.StatusCode.value__)
            {
                if ($_.Exception.Response.StatusCode.value__ -eq 404)
                {
                    Write-Host ("No Breaches found for " + $email)
                }
            }
            else {
                $_.Exception
            }
        }
    }
    elseif($emailArray)
    {
        $accountsCompromised = 0
       ForEach ($email in $emailArray)
       {
            $url = "https://haveibeenpwned.com/api/v2/breachedaccount/" + $email
            if($unverified)
            {
                $url += "?includeUnverified=true"
            }
            try {
                $Response = Invoke-WebRequest -Uri $url -UsebasicParsing | ConvertFrom-Json
                Write-Host("Breaches found for " + $email + ":") -NoNewline
                $Response|Select-Object name, domain, breachdate, pwncount | Format-List
                $accountsCompromised++
            }
            catch{
                if($_.Exception.Response.StatusCode.value__)
                {
                    if ($_.Exception.Response.StatusCode.value__ -eq 404)
                    {
                        Write-Host("No Breaches found for " + $email)
                    }
                }
                else {
                    Write-Warning -Message $_.Exception
                }
            }
            Start-Sleep -Seconds 1
        }
        Write-Host("Total number of accounts compromised: " + $accountsCompromised)
    }
}