$info = (Get-Content info.json) -join "`n" | ConvertFrom-Json
$version = $info.version

$filename = "AutoFactoryBuilder_$version"

$exclude = @("build.ps1",".gitignore","*.zip","AutoFactoryBuilder*")

Write-Host $filename

New-Item -Path ".\" -Name $filename -ItemType "directory" -Force

Get-ChildItem -Path $from -Recurse -Exclude $exclude |
    ForEach-Object { 
        Write-Host $_
        Copy-Item $_ -Destination ".\$filename" -force
    }

Compress-Archive -Path .\$filename -CompressionLevel Optimal -DestinationPath "$filename.zip" -Update

Write-Host "Zip $filename.zip written"

Remove-Item -Path .\$filename -Recurse -Force
