[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$global:url = "https://www.digicert.com/services/v2"
$global:url:order = $global:url + "/order/certificate"

#execute .ps1 file, call Cert-Issue function like: Cert-Issue @{key="API_KEY_HERE"}
function Cert-Issue
{    
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
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
            #"Accept"="application/json"
        }
        
        #supply cert details
        $server_platform = "-1"                                            #refer to https://www.digicert.com/services/v2/documentation/appendix-server-platforms
        $signature_hash = "sha256"                                         #sha256, sha384, or sha512
        $organization_id = 12345                                           #replace with your org id; retrieve org id from https://www.digicert.com/services/v2/documentation/organization/organization-list
        $validity_years = 1                                                #use https://www.digicert.com/services/v2/documentation/product/product-details with the product's name_id to determine allowed validity years
        $comments = "Order created via Bulk Cert Request"                  #optional note set on the request, to be reviewed by admin when approving or rejecting the request
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
# MIId7QYJKoZIhvcNAQcCoIId3jCCHdoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7tqcnzc29t0kyRAwPt/JvIiO
# 2OOgghkfMIIFNTCCBB2gAwIBAgIQCtvOfO8MtmSb4KtGs1D3YjANBgkqhkiG9w0B
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
# ggZqMIIFUqADAgECAhADAZoCOv9YsWvW1ermF/BmMA0GCSqGSIb3DQEBBQUAMGIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0Et
# MTAeFw0xNDEwMjIwMDAwMDBaFw0yNDEwMjIwMDAwMDBaMEcxCzAJBgNVBAYTAlVT
# MREwDwYDVQQKEwhEaWdpQ2VydDElMCMGA1UEAxMcRGlnaUNlcnQgVGltZXN0YW1w
# IFJlc3BvbmRlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKNkXfx8
# s+CCNeDg9sYq5kl1O8xu4FOpnx9kWeZ8a39rjJ1V+JLjntVaY1sCSVDZg85vZu7d
# y4XpX6X51Id0iEQ7Gcnl9ZGfxhQ5rCTqqEsskYnMXij0ZLZQt/USs3OWCmejvmGf
# rvP9Enh1DqZbFP1FI46GRFV9GIYFjFWHeUhG98oOjafeTl/iqLYtWQJhiGFyGGi5
# uHzu5uc0LzF3gTAfuzYBje8n4/ea8EwxZI3j6/oZh6h+z+yMDDZbesF6uHjHyQYu
# RhDIjegEYNu8c3T6Ttj+qkDxss5wRoPp2kChWTrZFQlXmVYwk/PJYczQCMxr7GJC
# kawCwO+k8IkRj3cCAwEAAaOCAzUwggMxMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMB
# Af8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMIIBvwYDVR0gBIIBtjCCAbIw
# ggGhBglghkgBhv1sBwEwggGSMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdp
# Y2VydC5jb20vQ1BTMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBl
# ACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBu
# AHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0
# AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQAIAB0
# AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBl
# AG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5
# ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABl
# AHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsGCWCGSAGG/WwD
# FTAfBgNVHSMEGDAWgBQVABIrE5iymQftHt+ivlcNK2cCzTAdBgNVHQ4EFgQUYVpN
# JLZJMp1KKnkag0v0HonByn0wfQYDVR0fBHYwdDA4oDagNIYyaHR0cDovL2NybDMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwOKA2oDSGMmh0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENBLTEuY3Js
# MHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
# cnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURDQS0xLmNydDANBgkqhkiG9w0BAQUFAAOCAQEAnSV+
# GzNNsiaBXJuGziMgD4CH5Yj//7HUaiwx7ToXGXEXzakbvFoWOQCd42yE5FpA+94G
# AYw3+puxnSR+/iCkV61bt5qwYCbqaVchXTQvH3Gwg5QZBWs1kBCge5fH9j/n4hFB
# pr1i2fAnPTgdKG86Ugnw7HBi02JLsOBzppLA044x2C/jbRcTBu7kA7YUq/OPQ6dx
# nSHdFMoVXZJB2vkPgdGZdA0mxA5/G7X1oPHGdwYoFenYk+VVFvC7Cqsc21xIJ2bI
# o4sKHOWV2q7ELlmgYd3a822iYemKC23sEhi991VUQAOSK2vCUcIKSK+w1G7g9BQK
# Ohvjjz3Kr2qNe9zYRDCCBqMwggWLoAMCAQICEA+oSQYV1wCgviF2/cXsbb0wDQYJ
# KoZIhvcNAQEFBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IElu
# YzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQg
# QXNzdXJlZCBJRCBSb290IENBMB4XDTExMDIxMTEyMDAwMFoXDTI2MDIxMDEyMDAw
# MFowbzELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEuMCwGA1UEAxMlRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBDb2RlIFNpZ25pbmcgQ0EtMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAJx8+aCPCsqJS1OaPOwZIn8My/dIRNA/Im6aT/rO38bTJJH/qFKT53L48UaG
# lMWrF/R4f8t6vpAmHHxTL+WD57tqBSjMoBcRSxgg87e98tzLuIZARR9P+TmY0zvr
# b2mkXAEusWbpprjcBt6ujWL+RCeCqQPD/uYmC5NJceU4bU7+gFxnd7XVb2ZklGu7
# iElo2NH0fiHB5sUeyeCWuAmV+UuerswxvWpaQqfEBUd9YCvZoV29+1aT7xv8cvnf
# PjL93SosMkbaXmO80LjLTBA1/FBfrENEfP6ERFC0jCo9dAz0eotyS+BWtRO2Y+k/
# Tkkj5wYW8CWrAfgoQebH1GQ7XasCAwEAAaOCA0MwggM/MA4GA1UdDwEB/wQEAwIB
# hjATBgNVHSUEDDAKBggrBgEFBQcDAzCCAcMGA1UdIASCAbowggG2MIIBsgYIYIZI
# AYb9bAMwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9z
# c2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4A
# eQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQA
# ZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUA
# IABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAA
# YQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcA
# cgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIA
# aQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQA
# ZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMBIG
# A1UdEwEB/wQIMAYBAf8CAQAweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEG
# A1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwHQYDVR0OBBYEFHtozimq
# wBe+SXrh5T/Wp/dFjzUyMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgP
# MA0GCSqGSIb3DQEBBQUAA4IBAQB7ch1k/4jIOsG36eepxIe725SS15BZM/orh96o
# W4AlPxOPm4MbfEPE5ozfOT7DFeyw2jshJXskwXJduEeRgRNG+pw/alE43rQly/Cr
# 38UoAVR5EEYk0TgPJqFhkE26vSjmP/HEqpv22jVTT8nyPdNs3CPtqqBNZwnzOoA9
# PPs2TJDndqTd8jq/VjUvokxl6ODU2tHHyJFqLSNPNzsZlBjU1ZwQPNWxHBn/j8hr
# m574rpyZlnjRzZxRFVtCJnJajQpKI5JA6IbeIsKTOtSbaKbfKX8GuTwOvZ/EhpyC
# R0JxMoYJmXIJeUudcWn1Qf9/OXdk8YSNvosesn1oo6WQsQz/MIIGzTCCBbWgAwIB
# AgIQBv35A5YDreoACus/J7u6GzANBgkqhkiG9w0BAQUFADBlMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMDYx
# MTEwMDAwMDAwWhcNMjExMTEwMDAwMDAwWjBiMQswCQYDVQQGEwJVUzEVMBMGA1UE
# ChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYD
# VQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTEwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDogi2Z+crCQpWlgHNAcNKeVlRcqcTSQQaPyTP8TUWRXIGf
# 7Syc+BZZ3561JBXCmLm0d0ncicQK2q/LXmvtrbBxMevPOkAMRk2T7It6NggDqww0
# /hhJgv7HxzFIgHweog+SDlDJxofrNj/YMMP/pvf7os1vcyP+rFYFkPAyIRaJxnCI
# +QWXfaPHQ90C6Ds97bFBo+0/vtuVSMTuHrPyvAwrmdDGXRJCgeGDboJzPyZLFJCu
# WWYKxI2+0s4Grq2Eb0iEm09AufFM8q+Y+/bOQF1c9qjxL6/siSLyaxhlscFzrdfx
# 2M8eCnRcQrhofrfVdwonVnwPYqQ/MhRglf0HBKIJAgMBAAGjggN6MIIDdjAOBgNV
# HQ8BAf8EBAMCAYYwOwYDVR0lBDQwMgYIKwYBBQUHAwEGCCsGAQUFBwMCBggrBgEF
# BQcDAwYIKwYBBQUHAwQGCCsGAQUFBwMIMIIB0gYDVR0gBIIByTCCAcUwggG0Bgpg
# hkgBhv1sAAEEMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5j
# b20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIA
# QQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMA
# YQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4A
# YwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAA
# UwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAA
# QQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkA
# YQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIA
# YQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUA
# LjALBglghkgBhv1sAxUwEgYDVR0TAQH/BAgwBgEB/wIBADB5BggrBgEFBQcBAQRt
# MGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEF
# BQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0
# cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# bDAdBgNVHQ4EFgQUFQASKxOYspkH7R7for5XDStnAs0wHwYDVR0jBBgwFoAUReui
# r/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQEFBQADggEBAEZQPsm3KCSnOB22
# WymvUs9S6TFHq1Zce9UNC0Gz7+x1H3Q48rJcYaKclcNQ5IK5I9G6OoZyrTh4rHVd
# Fxc0ckeFlFbR67s2hHfMJKXzBBlVqefj56tizfuLLZDCwNK1lL1eT7EF0g49GqkU
# W6aGMWKoqDPkmzmnxPXOHXh2lCVz5Cqrz5x2S+1fwksW5EtwTACJHvzFebxMElf+
# X+EevAJdqP77BzhPDcZdkbkPZ0XN1oPt55INjbFpjE/7WeAjD9KqrgB87pxCDs+R
# 1ye3Fu4Pw718CqDuLAhVhSK46xgaTfwqIa1JMYNHlXdx3LEbS0scEJx3FMGdTy9a
# lQgpECYxggQ4MIIENAIBATCBgzBvMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVE
# aWdpQ2VydCBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQS0xAhAK28587wy2ZJvg
# q0azUPdiMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTW8G9L55n+M/tCRto+tilXpcf8IjANBgkq
# hkiG9w0BAQEFAASCAQCpzNBjjv7hT6kx8bNenE903ObN+TQRud0WXqb3hu+KoWoi
# 4USUfqn1IH8F2ESVC48J+AR5Batsxh+MJEK842xbSVMyXi7p6/Fw5c+ZA+ZUs44x
# a4czplCQhUnzJ22aFRacLoGxj2DZPlHsAOos0Wlh5/qzWH9c36Z+fuzMYhCCfv8W
# hsuJxhyVx1XEzFOKdOkn2WtPbXu0Y29b0TnH42cU4D8XfpcL+zk75XzNprk+Nwmv
# Ou/Yi2f+NLtbXY5O5e57BQawZIQ8idi9zKm9cHSvsJp2v1wqh6cvsNnlPrOgQpFT
# VQYyeRVk5YddaEuLCodKtxYMVOadK/zTWhySnCS/oYICDzCCAgsGCSqGSIb3DQEJ
# BjGCAfwwggH4AgEBMHYwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNl
# cnQgQXNzdXJlZCBJRCBDQS0xAhADAZoCOv9YsWvW1ermF/BmMAkGBSsOAwIaBQCg
# XTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNzA4
# MjgyMDI2NTVaMCMGCSqGSIb3DQEJBDEWBBR6L2l5AXAR7oXTsMVnkBwcAAVFQTAN
# BgkqhkiG9w0BAQEFAASCAQAEC76/Lnvnz6MIQNZs0UdhrWe1TkOpZQPEnuqxZT5q
# DwOr+7C2PZ77wVdagmZ+LNzOB6PV/JOMo6dFeJ2Ih1GRtIys4RQ1Ex9IDrjgEHsA
# FZiU/G3UnpPllhowteTX27+o8HZV0bVa5vnxLQwJEie403sykjvt9nJzDWJQDLNW
# ZTvkueNz4DE9VauMrpu9uAWCVPgztRNgHCj5j4UfivoH5C/ZhCHzllg8Hye69ihY
# +8ZZQLwH4LtSZBIHXZV7uX/CUfxqPTg1OgOoCBCjt7RIL9buteDssgNCJOtH6IpT
# ZFE31DDIrrBqEG25rzh7g3v2Ivz2uPxt5VOkbhDKnmyf
# SIG # End signature block
