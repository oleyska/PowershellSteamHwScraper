Param(
	[Parameter(Mandatory=$false)] [String]$exportpath,
    	[Parameter(Mandatory=$false)] [String]$delimiter ## not yet implemented.
	)

if ($null -eq (get-module powerHTML))
    {
    Install-Module -Name PowerHTML -RequiredVersion 0.1.6 -force
    }
Import-Module PowerHTML

$steamwebreq = Invoke-WebRequest -Uri 'https://store.steampowered.com/hwsurvey/videocard/' -UseBasicParsing
$htmlContent = $steamwebreq.Content
$doc = $htmlContent | ConvertFrom-Html
$divs = $doc.SelectNodes('/html/body/div')
$stringvalue=$divs[1].innertext
$arrayvalues=($stringvalue -split '\r?\n').trim() | ? {[string]::IsNullOrWhiteSpace($_) -eq $false}
## All gpu's parsing.
$start = $arrayvalues.IndexOf('PC VIDEO CARD USAGE DETAILS')
$End = ($arrayvalues.IndexOf('Other') +6)
$valuestoParse = $arrayvalues[$start..$end]

$month1 = $valuestoParse[2]
$month2 = $valuestoParse[3]
$month3 = $valuestoParse[4]
$month4 = $valuestoParse[5]
$month5 = $valuestoParse[6].Replace('&nbsp;','')
$linecount = 0
$out = @()
foreach ($line in $valuestoParse)
{

        #write-host $line
        if ($line -like 'amd*')
            {
            $manufacturer = 'AMD'
            $product = ($line.Replace('AMD ',''))
            $gen = @()
            if ($product -like 'Radeon RX 7*' -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -gt 3)
                {
                $gen = 'RDNA 3'
                }
            if ($product -like 'Radeon RX 6*' -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -gt 3)
                {
                $gen = 'RDNA 2'
                }
            if ($product -like 'Radeon RX 5*' -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 4)
                {
                $gen = 'RDNA 1'
                }
            if (($product -like 'Radeon RX 4*' -or $product -like 'Radeon RX 5*') -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -gt 2 -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -lt 4)
                {
                $gen = 'GCN 4.0'
                }
            if (($product -like 'Radeon RX vega*' -or $product -like 'Radeon vega*'))
                {
                $gen = 'GCN 5.x'
                }
            if ([string]::IsNullOrWhiteSpace($gen) -eq $true)
                {
                $gen = "Unclassified"
                }
            $output = new-object -TypeName psobject
            $output | Add-Member -MemberType NoteProperty -Name Manufacturer -Value $manufacturer -PassThru|
            Add-Member -MemberType NoteProperty -Name Product -Value $product -PassThru|
            Add-Member -MemberType NoteProperty -Name Generation -Value $gen -PassThru|
            Add-Member -MemberType NoteProperty -Name $month1 -Value $valuestoParse[$linecount +1] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month2 -Value $valuestoParse[$linecount +2] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month3 -Value $valuestoParse[$linecount +3] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month4  -Value $valuestoParse[$linecount +4] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month5 -Value $valuestoParse[$linecount +5] -PassThru|
            Add-Member -MemberType NoteProperty -Name Change -Value $valuestoParse[$linecount +6]
            $out +=$output
            }
        if ($line -like 'Nvidia*')
            {
            $manufacturer = 'NVIDIA'
            $product = ($line.Replace('NVIDIA ',''))
            $gen = @()
            if (($product -like 'Geforce RTX 40*') -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 4)
                {
                $gen = 'ADA'
                }
            if (($product -like 'Geforce RTX 20*' -or $product -like 'Geforce GTX 16*') -and $product -notlike 'Geforce RTX 2050*' -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 4)
                {
                $gen = 'Turing'
                }
            if (($product -like 'Geforce RTX 30*' -or $product -like 'Geforce RTX 2050*') -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 4)
                {
                $gen = 'Ampere'
                }
            if (($product -like 'Geforce GTX 10*' -or $product -like 'Geforce GT 10*') -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 4)
                {
                $gen = 'Pascal'
                }
            if ($product -in ('Geforce MX150','Geforce MX250','Geforce MX350'))
                {
                $gen = 'Pascal'
                }
            if ($product -like 'Geforce MX450*' -or $product -eq 'Geforce MX550')
                {
                $gen = 'Turing'
                }
            if ($product -like 'Geforce MX570*')
                {
                $gen = 'Ampere'
                }
            if (($product -like 'Geforce GTX 9*' -or $product -like 'Geforce 9*') -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 3)
                {
                $gen = 'Maxwell'
                }
            if (($product -like 'Geforce GTX 7*' -or $product -like 'Geforce GT 7*') -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 3)
                {
                $gen = 'Keppler'
                }
            if ([string]::IsNullOrWhiteSpace($gen) -eq $true)
                {
                $gen = "Unclassified"
                }
            $output = new-object -TypeName psobject
            $output | Add-Member -MemberType NoteProperty -Name Manufacturer -Value $manufacturer -PassThru|
            Add-Member -MemberType NoteProperty -Name Product -Value $product -PassThru|
            Add-Member -MemberType NoteProperty -Name Generation -Value $gen -PassThru|
            Add-Member -MemberType NoteProperty -Name $month1 -Value $valuestoParse[$linecount +1] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month2 -Value $valuestoParse[$linecount +2] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month3 -Value $valuestoParse[$linecount +3] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month4  -Value $valuestoParse[$linecount +4] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month5 -Value $valuestoParse[$linecount +5] -PassThru|
            Add-Member -MemberType NoteProperty -Name Change -Value $valuestoParse[$linecount +6]
            $out +=$output
            }
        if ($line -like 'Intel*' -or $line -like 'Intel(R)*')
            {
            $manufacturer = 'Intel'
            $product = ($line.Replace('Intel ',''))
            $product = ($product.Replace('Intel(R) ',''))
            $gen = @()
            if (($product -like 'ARC 7*') -and ((($product | Select-String -Pattern '\d+' -AllMatches).Matches.Value).Length) -eq 3)
                {
                $gen = 'Alchemist'
                }
            if ([string]::IsNullOrWhiteSpace($gen) -eq $true)
                {
                $gen = "Unclassified"
                }
            $output = new-object -TypeName psobject
            $output | Add-Member -MemberType NoteProperty -Name Manufacturer -Value $manufacturer -PassThru|
            Add-Member -MemberType NoteProperty -Name Product -Value $product -PassThru|
            Add-Member -MemberType NoteProperty -Name Generation -Value $gen -PassThru|
            Add-Member -MemberType NoteProperty -Name $month1 -Value $valuestoParse[$linecount +1] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month2 -Value $valuestoParse[$linecount +2] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month3 -Value $valuestoParse[$linecount +3] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month4  -Value $valuestoParse[$linecount +4] -PassThru|
            Add-Member -MemberType NoteProperty -Name $month5 -Value $valuestoParse[$linecount +5] -PassThru|
            Add-Member -MemberType NoteProperty -Name Change -Value $valuestoParse[$linecount +6]
            $out +=$output
            }
    $linecount++
    }

if ($null -eq $exportpath)
    {
    Write-Output $out
    }
if ($null -ne $exportpath)
    {
    $out | export-csv $exportpath -Delimiter ';' -Encoding utf8 -NoTypeInformation
    }
