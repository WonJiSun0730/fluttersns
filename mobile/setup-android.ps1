$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    if (!(Test-Path 'android/app/src/main/AndroidManifest.xml')) {
        $scaffold = Join-Path ([System.IO.Path]::GetTempPath()) ('moa-' + [guid]::NewGuid())
        flutter create --platforms=android --org com.moa --project-name mini_social $scaffold
        if ($LASTEXITCODE -ne 0) { throw 'Flutter Android scaffold generation failed.' }
        Copy-Item -LiteralPath (Join-Path $scaffold 'android') -Destination . -Recurse
    }
    $manifest = 'android/app/src/main/AndroidManifest.xml'
    $xml = Get-Content -LiteralPath $manifest -Raw
    if (!$xml.Contains('android.permission.INTERNET')) {
        $xml = $xml.Replace('<application', '<uses-permission android:name="android.permission.INTERNET" />' + [Environment]::NewLine + '    <application')
    }
    $xml = $xml.Replace('android:label="mini_social"', 'android:label="MOA"')
    if (!$xml.Contains('android:usesCleartextTraffic')) {
        $xml = $xml.Replace('<application', '<application android:usesCleartextTraffic="true"')
    }
    Set-Content -LiteralPath $manifest -Value $xml -Encoding utf8
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Flutter dependency resolution failed.' }
} finally {
    Pop-Location
}
