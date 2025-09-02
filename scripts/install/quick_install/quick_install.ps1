$ErrorActionPreference = 'Stop'

$repoUrl = "https://github.com/bahayonghang/ccs"
$installDir = "$HOME/.ccs"
$configFile = "$HOME/.ccs_config.toml"
$rcFile = if ($PROFILE) { $PROFILE } else { "$HOME/.bashrc" }

# 创建安装目录
if (-not (Test-Path -Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# 下载脚本
$scriptUrl = "$repoUrl/raw/main/scripts/shell/ccs.ps1"
$commonScriptUrl = "$repoUrl/raw/main/scripts/shell/ccs-common.sh"

Invoke-WebRequest -Uri $scriptUrl -OutFile "$installDir/ccs.ps1"
Invoke-WebRequest -Uri $commonScriptUrl -OutFile "$installDir/ccs-common.sh"

# 下载Web界面
$webDir = "$installDir/web"
if (-not (Test-Path -Path $webDir)) {
    New-Item -ItemType Directory -Path $webDir | Out-Null
}
$webUrl = "$repoUrl/raw/main/web/index.html"
Invoke-WebRequest -Uri $webUrl -OutFile "$webDir/index.html"

# 创建配置文件
if (-not (Test-Path -Path $configFile)) {
    $configUrl = "$repoUrl/raw/main/config/.ccs_config.toml.example"
    Invoke-WebRequest -Uri $configUrl -OutFile $configFile
}

# 添加到PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
if (-not $currentPath.Contains("$installDir")) {
    $newPath = "$currentPath;$installDir"
    [System.Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
    Write-Host "Added to PATH. Please restart your terminal."
} else {
    Write-Host "Already in PATH."
}

Write-Host "Installation complete!"