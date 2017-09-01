[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$global:url = "https://www.digicert.com/services/v2"
$global:url:order = $global:url + "/order/certificate"

#execute .ps1 file, call Cert-Issue function like: DC-StandardSSL @{key="API_KEY_HERE"}
function DC-StandardSSL
{    
    Param(
        [Parameter(HelpMessage = "An API Key must be supplied", Mandatory = $true)]
        [System.Collections.Hashtable]$apikey        
    )
    
    try
    {
        # Order Standard SSL Cert

        #set the product URL; refer to the "group_name" values from https://www.digicert.com/services/v2/documentation/product/product-list
        $ssl_plus_url = $global:url:order + "/ssl_plus"
        
        #set reqeust headers using api key passed into the Cert-Issue command
        $headers = @{
            "X-DC-DEVKEY"=$apikey.key
        }
        
        #supply cert details
        $server_platform = "-1"                                            #refer to https://www.digicert.com/services/v2/documentation/appendix-server-platforms
        $signature_hash = "sha256"                                         #sha256, sha384, or sha512
        $organization_id = 123456                                          #replace with your org id; retrieve org id from https://www.digicert.com/services/v2/documentation/organization/organization-list
        $validity_years = 1                                                #use https://www.digicert.com/services/v2/documentation/product/product-details with the product's name_id to determine allowed validity years
        $comments = "Order created via PowerShell Script"                  #optional note set on the request, to be reviewed by admin when approving or rejecting the request
        $disable_issuance_email = $true                                    #if true, the certificate, once issued, will _not_ be emailed to the contact on the org 
        $common_name = "mydomain.com"                                      #replace with your common name value
        $csr = "CSR_HERE"                                                  #replace with your CSR, all one line, including -----BEGIN and END----- tags   

        #build request payload
        $body = @{
            certificate=@{
                common_name=$common_name;                
                csr=$csr;                
                signature_hash=$signature_hash
                server_platform=@{id=$server_platform}
            };
            organization=@{id=$organization_id};
            validity_years=$validity_years;
            disable_issuance_email=$disable_issuance_email;
            comments=$comments;                
        } | ConvertTo-Json 
        
        #request cert
        $resp = Invoke-RestMethod -Uri $ssl_plus_url -Method Post -Headers $headers -Body $body -ContentType "application/json"                 
          
    }
    #catch any errors
    catch 
    {
        throw CC-Error($_.Exception)
    }
}

#parse and display errors returned from the API
function CC-Error( [Exception] $exception )
{
    try
    {
        $result = $exception.Response.GetResponseStream()
        $read = New-Object System.IO.StreamReader($result)
        $read.BaseStream.Position = 0
        $read.DiscardBufferedData()
        $content_type = $read.ReadToEnd() | ConvertFrom-Json
        return $content_type.errors.message
    }
    catch
    {
        return $exception.Message
    }
}
# SIG # Begin signature block
# MIIOmwYJKoZIhvcNAQcCoIIOjDCCDogCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgJavY907GFXbZ975IKW4RWkM
# 2y2gggvgMIIFNTCCBB2gAwIBAgIQCtvOfO8MtmSb4KtGs1D3YjANBgkqhkiG9w0B
# AQUFADBvMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1cmVk
# IElEIENvZGUgU2lnbmluZyBDQS0xMB4XDTE3MDgwNzAwMDAwMFoXDTE4MDgxNzEy
# MDAwMFowgYAxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDENMAsGA1UEBxMET3Jl
# bTEVMBMGA1UEChMMQ2xpbnQgV2lsc29uMRUwEwYDVQQDEwxDbGludCBXaWxzb24x
# JzAlBgkqhkiG9w0BCQEWGGNsaW50LnQud2lsc29uQGdtYWlsLmNvbTCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBALhPEhMNFxyYuMbrMm6sDhIB1W5MWiVH
# Z7NCRjqZbJnDj+0j3MoHiEcCfEyLcZUlDJMj6bcwIVbMjbqgYyy2rzOxzkcI4VU8
# 1aL6hbqUw2uY0hF8U5b1E00NThN1LfCQ9rbEhhg/8OcLbTnRGO0yXaxbmld4QOm1
# BbdnH+ApXIKUwDdJA0/RxgN/K2+O2J3k0nvoF1Ob30ILDfmFr7BV/msJuRJ0QDDb
# NIY0TwzxK7kgkmn+cGDK9MhFYC+ozTKSi0DgcP7Rw/SljbZuKLuLk/51jdmZp2xl
# Ecgese8qqAFF/mNSTAacH4SO54p7EDreAq0XFbSIRU8cT/rgzzro6zkCAwEAAaOC
# AbkwggG1MB8GA1UdIwQYMBaAFHtozimqwBe+SXrh5T/Wp/dFjzUyMB0GA1UdDgQW
# BBSj0RrbnEA7AUN+/EKsGEifFRxM5DAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwbQYDVR0fBGYwZDAwoC6gLIYqaHR0cDovL2NybDMuZGlnaWNl
# cnQuY29tL2Fzc3VyZWQtY3MtZzEuY3JsMDCgLqAshipodHRwOi8vY3JsNC5kaWdp
# Y2VydC5jb20vYXNzdXJlZC1jcy1nMS5jcmwwTAYDVR0gBEUwQzA3BglghkgBhv1s
# AwEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAI
# BgZngQwBBAEwgYIGCCsGAQUFBwEBBHYwdDAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEwGCCsGAQUFBzAChkBodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDb2RlU2lnbmluZ0NBLTEuY3J0MAwG
# A1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEFBQADggEBAAQkBxyiTRr5kZGbDU9lIJPe
# vVRpX6tiZGVhng2//V++xwgKXZBSXl1UdGmuKSwHQkbiyMMvekE5UgKh4VKzJ5Bl
# xqbgEvZMeS581EakRgFstqOYEintk/ItIpw09iA7mAGsHf2Sqt0jZVmxuRxybYpN
# ITdqyC8EI3T7rFljWOZpUu5MUGNrtyIu+wSL03XCe04gKt0QKKN0lYXEuyExBVjE
# ccniqw2shCjHFODM9oOEYpt/IPW0yVztlQfuh94TwkdPeoeeqyaSThl+tewDYeyo
# k7ykEtAAQiIQTgP9A0OFdl1jDx7BDOBhPIsYyoW6+BpOwM1AUxGU7WmkaWeJdQkw
# ggajMIIFi6ADAgECAhAPqEkGFdcAoL4hdv3F7G29MA0GCSqGSIb3DQEBBQUAMGUx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9v
# dCBDQTAeFw0xMTAyMTExMjAwMDBaFw0yNjAyMTAxMjAwMDBaMG8xCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29kZSBTaWduaW5n
# IENBLTEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCcfPmgjwrKiUtT
# mjzsGSJ/DMv3SETQPyJumk/6zt/G0ySR/6hSk+dy+PFGhpTFqxf0eH/Ler6QJhx8
# Uy/lg+e7agUozKAXEUsYIPO3vfLcy7iGQEUfT/k5mNM7629ppFwBLrFm6aa43Abe
# ro1i/kQngqkDw/7mJguTSXHlOG1O/oBcZ3e11W9mZJRru4hJaNjR9H4hwebFHsng
# lrgJlflLnq7MMb1qWkKnxAVHfWAr2aFdvftWk+8b/HL53z4y/d0qLDJG2l5jvNC4
# y0wQNfxQX6xDRHz+hERQtIwqPXQM9HqLckvgVrUTtmPpP05JI+cGFvAlqwH4KEHm
# x9RkO12rAgMBAAGjggNDMIIDPzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYI
# KwYBBQUHAwMwggHDBgNVHSAEggG6MIIBtjCCAbIGCGCGSAGG/WwDMIIBpDA6Bggr
# BgEFBQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0
# b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8A
# ZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQA
# aQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUA
# IABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUA
# IABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQA
# IAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEA
# bgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUA
# aQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjASBgNVHRMBAf8ECDAGAQH/
# AgEAMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGln
# aWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2
# hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRB
# c3N1cmVkSURSb290Q0EuY3JsMB0GA1UdDgQWBBR7aM4pqsAXvkl64eU/1qf3RY81
# MjAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUF
# AAOCAQEAe3IdZP+IyDrBt+nnqcSHu9uUkteQWTP6K4feqFuAJT8Tj5uDG3xDxOaM
# 3zk+wxXssNo7ISV7JMFyXbhHkYETRvqcP2pRON60Jcvwq9/FKAFUeRBGJNE4Dyah
# YZBNur0o5j/xxKqb9to1U0/J8j3TbNwj7aqgTWcJ8zqAPTz7NkyQ53ak3fI6v1Y1
# L6JMZejg1NrRx8iRai0jTzc7GZQY1NWcEDzVsRwZ/4/Ia5ue+K6cmZZ40c2cURVb
# QiZyWo0KSiOSQOiG3iLCkzrUm2im3yl/Brk8Dr2fxIacgkdCcTKGCZlyCXlLnXFp
# 9UH/fzl3ZPGEjb6LHrJ9aKOlkLEM/zGCAiUwggIhAgEBMIGDMG8xCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xLjAsBgNVBAMTJURpZ2lDZXJ0IEFzc3VyZWQgSUQgQ29kZSBTaWduaW5n
# IENBLTECEArbznzvDLZkm+CrRrNQ92IwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBsJzihlJkKR
# hkMd2XgLGNgI34qUMA0GCSqGSIb3DQEBAQUABIIBAF8FzFOzB761cCZDgMty/8mr
# 5+hXXIOtcH/tGuzQIaGlxKzsUpFNzwh69EsGtqth5UMkE7TC6PwJVCOZMDoijNv0
# H5fFbd0CEdP6HZw3Fx6gcRbXr4GNJq4//w/+XPewi+WecHUZ539pPjFgba9xlemX
# 3QhAe8/M2AdXIhXFVB8DcOozorZZPQ70FfwzDU4gI/IpYa+nUUcIhobAlG65aZzJ
# EHseyYa6QEuPZj/X/RA6j2rHM85Rb1n6NBEXy6kN2YSh67EOn47klwsVH9N1lhch
# wDdVt7203518pmTFofoCEyu5QXEymo+YEbyYXLIYQJCumrDptZYdks8ZSdIiLPk=
# SIG # End signature block
