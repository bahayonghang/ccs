# Claude Code Configuration Switcher (CCS) - PowerShell v2.0 优化版
# 此脚本用于在Windows环境中快速切换不同的Claude Code API配置
# 优化特性: 缓存系统、性能提升、增强的错误处理

# 全局变量和配置
$Script:CONFIG_FILE = "$env:USERPROFILE\.ccs_config.toml"
$Script:CCS_VERSION = "2.0.0"
$Script:CCS_DIR = "$env:USERPROFILE\.ccs"
$Script:CONFIG_CACHE = @{}
$Script:CACHE_TIMESTAMP = @{}
$Script:CACHE_TTL = 300  # 5分钟缓存

# 错误码定义
$Script:ERROR_SUCCESS = 0
$Script:ERROR_CONFIG_MISSING = 1
$Script:ERROR_CONFIG_INVALID = 2
$Script:ERROR_PERMISSION_DENIED = 4
$Script:ERROR_FILE_NOT_FOUND = 5
$Script:ERROR_NETWORK_UNREACHABLE = 7
$Script:ERROR_UNKNOWN = 99

# 日志和输出函数
function Write-CcsError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-CcsWarning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-CcsInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-CcsSuccess {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Write-CcsStep {
    param([string]$Message)
    Write-Host "[→] $Message" -ForegroundColor Cyan
}

# 错误处理函数
function Handle-Error {
    param(
        [int]$ErrorCode,
        [string]$Message,
        [bool]$ShowHelp = $false
    )
    
    Write-CcsError "错误[$ErrorCode]: $Message"
    
    switch ($ErrorCode) {
        $Script:ERROR_CONFIG_MISSING {
            Write-CcsInfo "解决方案: 请运行安装脚本创建配置文件"
            Write-CcsInfo "  命令: 运行 install.bat 或手动创建配置文件"
        }
        $Script:ERROR_CONFIG_INVALID {
            Write-CcsInfo "解决方案: 请检查配置文件格式和必需字段"
            Write-CcsInfo "  参考: 配置文件必须包含 [section] 和 base_url、auth_token 字段"
        }
        $Script:ERROR_PERMISSION_DENIED {
            Write-CcsInfo "解决方案: 请检查文件权限或使用管理员权限运行"
        }
        $Script:ERROR_FILE_NOT_FOUND {
            Write-CcsInfo "解决方案: 请检查文件路径是否正确"
        }
        $Script:ERROR_NETWORK_UNREACHABLE {
            Write-CcsInfo "解决方案: 请检查网络连接和防火墙设置"
        }
    }
    
    if ($ShowHelp) {
        Write-Host ""
        Write-Host "使用 'ccs help' 查看帮助信息"
    }
    
    exit $ErrorCode
}

# 配置文件验证
function Test-ConfigFile {
    param([string]$ConfigFilePath = $Script:CONFIG_FILE)
    
    if (-not (Test-Path $ConfigFilePath)) {
        return $false
    }
    
    try {
        $content = Get-Content $ConfigFilePath -ErrorAction Stop
        
        # 检查是否有配置节
        $hasSections = $false
        foreach ($line in $content) {
            if ($line -match "^\s*\[.+\]\s*$") {
                $hasSections = $true
                break
            }
        }
        
        return $hasSections
    }
    catch {
        return $false
    }
}

# 缓存管理
function Get-CachedConfig {
    param([string]$ConfigName)
    
    $cacheKey = "$Script:CONFIG_FILE:$ConfigName"
    $currentTime = Get-Date
    
    if ($Script:CONFIG_CACHE.ContainsKey($cacheKey) -and $Script:CACHE_TIMESTAMP.ContainsKey($cacheKey)) {
        $cacheTime = $Script:CACHE_TIMESTAMP[$cacheKey]
        $ageDiff = ($currentTime - $cacheTime).TotalSeconds
        
        if ($ageDiff -lt $Script:CACHE_TTL) {
            Write-Verbose "使用缓存配置: $ConfigName (age: $ageDiff s)"
            return $Script:CONFIG_CACHE[$cacheKey]
        }
        else {
            Write-Verbose "缓存过期，清理: $ConfigName (age: $ageDiff s)"
            $Script:CONFIG_CACHE.Remove($cacheKey)
            $Script:CACHE_TIMESTAMP.Remove($cacheKey)
        }
    }
    
    return $null
}

function Set-CachedConfig {
    param(
        [string]$ConfigName,
        [hashtable]$ConfigData
    )
    
    $cacheKey = "$Script:CONFIG_FILE:$ConfigName"
    $Script:CONFIG_CACHE[$cacheKey] = $ConfigData
    $Script:CACHE_TIMESTAMP[$cacheKey] = Get-Date
    Write-Verbose "缓存配置: $ConfigName"
}

function Clear-ConfigCache {
    $Script:CONFIG_CACHE.Clear()
    $Script:CACHE_TIMESTAMP.Clear()
    Write-Verbose "清理所有配置缓存"
}
# 显示帮助信息（优化版）
function Show-Help {
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host "🔄 Claude Code Configuration Switcher (CCS) v$Script:CCS_VERSION (PowerShell)" -ForegroundColor Blue  
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "📋 基本用法:" -ForegroundColor Green
    Write-Host "  ccs [配置名称]          - 切换到指定配置"
    Write-Host "  ccs list               - 列出所有可用配置" 
    Write-Host "  ccs current            - 显示当前配置状态"
    Write-Host ""
    Write-Host "🔧 管理命令:" -ForegroundColor Green
    Write-Host "  ccs web                - 启动Web配置界面"
    Write-Host "  ccs backup             - 备份当前配置文件"
    Write-Host "  ccs verify             - 验证配置文件完整性"
    Write-Host "  ccs clear-cache        - 清理配置缓存"
    Write-Host "  ccs uninstall          - 卸载CCS工具"
    Write-Host ""
    Write-Host "ℹ️  信息命令:" -ForegroundColor Green
    Write-Host "  ccs version            - 显示版本信息"
    Write-Host "  ccs help               - 显示此帮助信息"
    Write-Host ""
    Write-Host "💡 使用示例:" -ForegroundColor Cyan
    Write-Host "  ccs anyrouter          - 切换到anyrouter配置"
    Write-Host "  ccs glm                - 切换到智谱GLM配置" 
    Write-Host "  ccs list               - 查看所有可用配置"
    Write-Host "  ccs current            - 查看当前配置状态"
    Write-Host "  ccs web                - 打开图形化配置界面"
    Write-Host "  ccs backup             - 备份配置文件"
    Write-Host ""
    Write-Host "🔗 配置文件:" -ForegroundColor Yellow
    Write-Host "  位置: $env:USERPROFILE\.ccs_config.toml"
    Write-Host "  格式: TOML"
    Write-Host "  示例: 参考 config\.ccs_config.toml.example"
    Write-Host ""
    Write-Host "📝 新功能 (v2.0):" -ForegroundColor Yellow
    Write-Host "  • 配置缓存系统 - 提升解析性能"
    Write-Host "  • 增强的错误处理和诊断"
    Write-Host "  • 配置文件完整性验证"
    Write-Host "  • 自动备份和恢复系统"
    Write-Host "  • 性能监控和调试模式"
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Blue
}

# 显示版本信息
function Show-Version {
    $packageJsonPath = "$Script:CCS_DIR\package.json"
    $fallbackPath = "$PSScriptRoot\..\..\package.json"
    
    if (-not (Test-Path $packageJsonPath) -and (Test-Path $fallbackPath)) {
        $packageJsonPath = $fallbackPath
    }
    
    Write-Host "🔄 Claude Code Configuration Switcher (CCS)"
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════"
    Write-Host ""
    
    if (Test-Path $packageJsonPath) {
        try {
            $packageContent = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
            
            Write-Host "📦 基本信息:"
            if ($packageContent.version) {
                Write-Host "   📌 版本: $($packageContent.version)"
            }
            else {
                Write-Host "   ⚠️  版本: 未知 (建议在package.json中补充version字段)"
            }
            
            if ($packageContent.author) {
                Write-Host "   👤 作者: $($packageContent.author)"
            }
            else {
                Write-Host "   ⚠️  作者: 未知 (建议在package.json中补充author字段)"
            }
            
            Write-Host ""
            Write-Host "📝 项目描述:"
            if ($packageContent.description) {
                Write-Host "   $($packageContent.description)"
            }
            else {
                Write-Host "   ⚠️  描述: 未知 (建议在package.json中补充description字段)"
            }
            
            Write-Host ""
            Write-Host "🔗 项目链接:"
            if ($packageContent.homepage) {
                Write-Host "   🌐 项目主页: $($packageContent.homepage)"
            }
            else {
                Write-Host "   🌐 项目主页: https://github.com/bahayonghang/ccs (默认)"
            }
            
            if ($packageContent.license) {
                Write-Host "   📄 许可证: $($packageContent.license)"
            }
            else {
                Write-Host "   📄 许可证: MIT (默认)"
            }
            
            Write-Host ""
            Write-Host "📁 文件信息:"
            Write-Host "   📍 配置文件路径: $packageJsonPath"
            Write-Host "   ✅ 文件复制操作: 无需执行 (直接读取源文件)"
        }
        catch {
            Write-CcsWarning "读取package.json文件时出错: $($_.Exception.Message)"
            Write-Host ""
            Write-Host "📦 使用默认信息:"
            Write-Host "   📌 版本: $Script:CCS_VERSION"
            Write-Host "   👤 作者: 未知"
            Write-Host "   📝 描述: Claude Code Configuration Switcher - Windows PowerShell版"
            Write-Host "   🌐 项目主页: https://github.com/bahayonghang/ccs"
            Write-Host "   📄 许可证: MIT"
        }
    }
    else {
        Write-CcsWarning "未找到package.json文件"
        Write-Host "📍 预期路径: $packageJsonPath"
        Write-Host ""
        Write-Host "📦 使用默认信息:"
        Write-Host "   📌 版本: $Script:CCS_VERSION"
        Write-Host "   👤 作者: 未知"
        Write-Host "   📝 描述: Claude Code Configuration Switcher - Windows PowerShell版"
        Write-Host "   🌐 项目主页: https://github.com/bahayonghang/ccs"
        Write-Host "   📄 许可证: MIT"
        Write-Host ""
        Write-Host "💡 建议: 请确保package.json文件存在并包含完整的项目信息"
    }
    
    Write-Host ""
    Write-Host "🖥️ 系统信息:"
    Write-Host "   💻 操作系统: $([System.Environment]::OSVersion.VersionString)"
    Write-Host "   🐚 PowerShell: $($PSVersionTable.PSVersion)"
    Write-Host "   📁 配置文件: $Script:CONFIG_FILE"
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════"
    Write-Host "🚀 感谢使用 CCS PowerShell版！如有问题请访问项目主页获取帮助。"
}

# 高效TOML解析器（优化版，支持缓存）
function Parse-Toml {
    param(
        [string]$ConfigName,
        [string]$SilentMode = ""
    )
    
    Write-Verbose "解析配置: $ConfigName (模式: $(if ($SilentMode) { $SilentMode } else { 'normal' }))"
    
    # 检查缓存
    $cachedConfig = Get-CachedConfig -ConfigName $ConfigName
    if ($cachedConfig) {
        # 使用缓存配置设置环境变量
        Set-EnvironmentVariables -ConfigData $cachedConfig -ConfigName $ConfigName -SilentMode $SilentMode
        return
    }
    
    # 读取并解析配置文件
    try {
        $lines = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
    }
    catch {
        Handle-Error -ErrorCode $Script:ERROR_FILE_NOT_FOUND -Message "无法读取配置文件: $Script:CONFIG_FILE"
    }
    
    $configContent = @{}
    $inSection = $false
    $foundSection = $false
    
    foreach ($line in $lines) {
        $trimmedLine = $line.Trim()
        
        if ($trimmedLine -match "^\[$ConfigName\]$") {
            $inSection = $true
            $foundSection = $true
            continue
        } 
        elseif ($trimmedLine -match "^\[.+\]$") {
            if ($inSection) {
                break
            }
        } 
        elseif ($inSection -and $trimmedLine -ne "" -and -not $trimmedLine.StartsWith("#")) {
            if ($trimmedLine -match "^(.+?)\s*=\s*(.*)$") {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                
                # 移除引号
                if (($value.StartsWith('"') -and $value.EndsWith('"')) -or 
                    ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                    $value = $value.Substring(1, $value.Length - 2)
                }
                
                $configContent[$key] = $value
            }
        }
    }
    
    if (-not $foundSection) {
        Handle-Error -ErrorCode $Script:ERROR_CONFIG_INVALID -Message "配置 '$ConfigName' 不存在"
    }
    
    if ($configContent.Count -eq 0) {
        Handle-Error -ErrorCode $Script:ERROR_CONFIG_INVALID -Message "配置 '$ConfigName' 内容为空"
    }
    
    # 缓存配置
    Set-CachedConfig -ConfigName $ConfigName -ConfigData $configContent
    
    # 设置环境变量
    Set-EnvironmentVariables -ConfigData $configContent -ConfigName $ConfigName -SilentMode $SilentMode
    
    # 更新当前配置（非静默模式）
    if ($SilentMode -ne "silent") {
        Update-CurrentConfig -ConfigName $ConfigName
    }
}

# 设置环境变量
function Set-EnvironmentVariables {
    param(
        [hashtable]$ConfigData,
        [string]$ConfigName,
        [string]$SilentMode = ""
    )
    
    # 清理现有环境变量
    $envVars = @("ANTHROPIC_BASE_URL", "ANTHROPIC_AUTH_TOKEN", "ANTHROPIC_MODEL", "ANTHROPIC_SMALL_FAST_MODEL")
    foreach ($var in $envVars) {
        Remove-Item "Env:$var" -ErrorAction SilentlyContinue
        [Environment]::SetEnvironmentVariable($var, $null, "User")
    }
    
    $varsSet = 0
    
    # 设置环境变量
    if ($ConfigData.ContainsKey("base_url") -and $ConfigData["base_url"]) {
        $env:ANTHROPIC_BASE_URL = $ConfigData["base_url"]
        [Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $ConfigData["base_url"], "User")
        $varsSet++
        if ($SilentMode -ne "silent") {
            Write-CcsSuccess "设置 ANTHROPIC_BASE_URL=$($ConfigData['base_url'])"
        }
    }
    else {
        if ($SilentMode -ne "silent") {
            Write-CcsWarning "配置 '$ConfigName' 缺少 base_url"
        }
    }
    
    if ($ConfigData.ContainsKey("auth_token") -and $ConfigData["auth_token"]) {
        $env:ANTHROPIC_AUTH_TOKEN = $ConfigData["auth_token"]
        [Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $ConfigData["auth_token"], "User")
        $varsSet++
        if ($SilentMode -ne "silent") {
            $maskedToken = Mask-SensitiveInfo -Value $ConfigData["auth_token"]
            Write-CcsSuccess "设置 ANTHROPIC_AUTH_TOKEN=$maskedToken"
        }
    }
    else {
        if ($SilentMode -ne "silent") {
            Write-CcsWarning "配置 '$ConfigName' 缺少 auth_token"
        }
    }
    
    if ($ConfigData.ContainsKey("model") -and $ConfigData["model"]) {
        $env:ANTHROPIC_MODEL = $ConfigData["model"]
        [Environment]::SetEnvironmentVariable("ANTHROPIC_MODEL", $ConfigData["model"], "User")
        $varsSet++
        if ($SilentMode -ne "silent") {
            Write-CcsSuccess "设置 ANTHROPIC_MODEL=$($ConfigData['model'])"
        }
    }
    else {
        if ($SilentMode -ne "silent") {
            Write-CcsInfo "配置 '$ConfigName' 使用默认模型"
        }
    }
    
    if ($ConfigData.ContainsKey("small_fast_model") -and $ConfigData["small_fast_model"]) {
        $env:ANTHROPIC_SMALL_FAST_MODEL = $ConfigData["small_fast_model"]
        [Environment]::SetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", $ConfigData["small_fast_model"], "User")
        $varsSet++
        if ($SilentMode -ne "silent") {
            Write-CcsSuccess "设置 ANTHROPIC_SMALL_FAST_MODEL=$($ConfigData['small_fast_model'])"
        }
    }
    
    if ($varsSet -eq 0) {
        Handle-Error -ErrorCode $Script:ERROR_CONFIG_INVALID -Message "配置 '$ConfigName' 没有设置任何有效的环境变量"
    }
    
    if ($SilentMode -ne "silent") {
        Write-CcsSuccess "已切换到配置: $ConfigName ($varsSet 个变量已设置)"
    }
}

# 敏感信息掩码
function Mask-SensitiveInfo {
    param(
        [string]$Value,
        [int]$PrefixLength = 10
    )
    
    if ($Value.Length -le $PrefixLength) {
        return "$($Value.Substring(0, 1))..."
    }
    else {
        return "$($Value.Substring(0, $PrefixLength))..."
    }
}

# 更新当前配置
function Update-CurrentConfig {
    param([string]$ConfigName)
    
    Write-Verbose "更新当前配置为: $ConfigName"
    
    try {
        $content = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
        $updatedContent = @()
        $currentConfigFound = $false
        
        for ($i = 0; $i -lt $content.Length; $i++) {
            $line = $content[$i]
            if ($line -match "^current_config\s*=") {
                $updatedContent += "current_config = `"$ConfigName`""
                $currentConfigFound = $true
            }
            else {
                $updatedContent += $line
            }
        }
        
        # 如果没有找到current_config行，在文件开头添加
        if (-not $currentConfigFound) {
            $newContent = @(
                "# 当前使用的配置（自动添加）",
                "current_config = `"$ConfigName`"",
                ""
            ) + $updatedContent
            $updatedContent = $newContent
        }
        
        $updatedContent | Set-Content $Script:CONFIG_FILE -ErrorAction Stop
        Write-Verbose "配置文件已更新，当前配置: $ConfigName"
    }
    catch {
        Write-CcsWarning "无法更新配置文件: $($_.Exception.Message)"
    }
}

# 列出所有可用配置（优化版）
function List-Configs {
    Write-CcsStep "扫描可用的配置..."
    Write-Host ""
    
    try {
        $lines = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
    }
    catch {
        Handle-Error -ErrorCode $Script:ERROR_FILE_NOT_FOUND -Message "无法读取配置文件: $Script:CONFIG_FILE"
    }
    
    # 提取所有配置节
    $configs = @()
    foreach ($line in $lines) {
        if ($line -match "^\s*\[(.+)\]\s*$") {
            $configName = $matches[1]
            if ($configName -ne "default_config") {
                $configs += $configName
            }
        }
    }
    
    if ($configs.Count -eq 0) {
        Write-CcsWarning "未找到任何配置节"
        return
    }
    
    # 获取当前配置
    $currentConfig = ""
    foreach ($line in $lines) {
        if ($line -match "^current_config\s*=\s*(.+)$") {
            $currentConfig = $matches[1].Trim()
            if (($currentConfig.StartsWith('"') -and $currentConfig.EndsWith('"')) -or 
                ($currentConfig.StartsWith("'") -and $currentConfig.EndsWith("'"))) {
                $currentConfig = $currentConfig.Substring(1, $currentConfig.Length - 2)
            }
            break
        }
    }
    
    # 计算最大长度用于对齐
    $maxLength = 0
    foreach ($config in $configs) {
        if ($config.Length -gt $maxLength) {
            $maxLength = $config.Length
        }
    }
    
    # 显示配置列表
    foreach ($config in $configs) {
        # 获取配置描述
        $description = Get-ConfigDescription -ConfigName $config -Lines $lines
        
        # 格式化输出
        $marker = " "
        $color = "White"
        if ($config -eq $currentConfig) {
            $marker = "▶"
            $color = "Green"
        }
        
        $paddedConfig = $config.PadRight($maxLength)
        if ($description) {
            Write-Host "$marker $paddedConfig - $description" -ForegroundColor $color
        }
        else {
            Write-Host "$marker $paddedConfig - (无描述)" -ForegroundColor $color
        }
    }
    
    Write-Host ""
    
    # 显示统计信息
    Write-CcsStep "配置统计: $($configs.Count) 个配置可用"
    
    # 显示默认配置
    $defaultConfig = ""
    foreach ($line in $lines) {
        if ($line -match "^default_config\s*=\s*(.+)$") {
            $defaultConfig = $matches[1].Trim()
            if (($defaultConfig.StartsWith('"') -and $defaultConfig.EndsWith('"')) -or 
                ($defaultConfig.StartsWith("'") -and $defaultConfig.EndsWith("'"))) {
                $defaultConfig = $defaultConfig.Substring(1, $defaultConfig.Length - 2)
            }
            break
        }
    }
    
    if ($defaultConfig) {
        Write-Host "默认配置: $defaultConfig"
    }
    
    # 显示当前配置
    if ($currentConfig) {
        Write-Host "当前配置: " -NoNewline
        Write-Host "$currentConfig" -ForegroundColor Green
    }
    else {
        Write-Host "当前配置: " -NoNewline
        Write-Host "未设置" -ForegroundColor Yellow
    }
}

# 获取配置描述
function Get-ConfigDescription {
    param(
        [string]$ConfigName,
        [string[]]$Lines
    )
    
    $inSection = $false
    
    foreach ($line in $Lines) {
        $trimmedLine = $line.Trim()
        
        if ($trimmedLine -match "^\[$ConfigName\]$") {
            $inSection = $true
            continue
        } 
        elseif ($trimmedLine -match "^\[.+\]$") {
            if ($inSection) {
                break
            }
        } 
        elseif ($inSection -and $trimmedLine -match "^description\s*=\s*(.+)$") {
            $descValue = $matches[1].Trim()
            if (($descValue.StartsWith('"') -and $descValue.EndsWith('"')) -or 
                ($descValue.StartsWith("'") -and $descValue.EndsWith("'"))) {
                $descValue = $descValue.Substring(1, $descValue.Length - 2)
            }
            return $descValue
        }
    }
    
    return ""
}

# 显示当前配置（优化版）
function Show-Current {
    Write-CcsStep "检查当前环境配置..."
    Write-Host ""
    
    # 定义环境变量配置
    $envVars = @{
        "ANTHROPIC_BASE_URL" = "API端点"
        "ANTHROPIC_AUTH_TOKEN" = "认证令牌"
        "ANTHROPIC_MODEL" = "模型"
        "ANTHROPIC_SMALL_FAST_MODEL" = "快速模型"
    }
    
    $varsSet = 0
    $maxNameLength = 25
    
    # 显示环境变量状态
    foreach ($varName in $envVars.Keys) {
        $varValue = [Environment]::GetEnvironmentVariable($varName)
        $description = $envVars[$varName]
        
        $paddedDesc = $description.PadRight($maxNameLength)
        Write-Host "  $paddedDesc : " -NoNewline
        
        if ($varValue) {
            $varsSet++
            if ($varName -eq "ANTHROPIC_AUTH_TOKEN") {
                $maskedValue = Mask-SensitiveInfo -Value $varValue
                Write-Host "$maskedValue" -ForegroundColor Green
            }
            else {
                Write-Host "$varValue" -ForegroundColor Green
            }
        }
        else {
            Write-Host "(未设置)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    
    # 获取并显示配置文件中的当前配置
    try {
        $lines = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
        $currentConfig = ""
        
        foreach ($line in $lines) {
            if ($line -match "^current_config\s*=\s*(.+)$") {
                $currentConfig = $matches[1].Trim()
                if (($currentConfig.StartsWith('"') -and $currentConfig.EndsWith('"')) -or 
                    ($currentConfig.StartsWith("'") -and $currentConfig.EndsWith("'"))) {
                    $currentConfig = $currentConfig.Substring(1, $currentConfig.Length - 2)
                }
                break
            }
        }
        
        if ($currentConfig) {
            Write-CcsStep "配置文件中的活跃配置: " -NoNewline
            Write-Host "$currentConfig" -ForegroundColor Green
        }
        else {
            Write-CcsWarning "配置文件中未找到 current_config 字段"
        }
    }
    catch {
        Write-CcsWarning "无法读取配置文件: $($_.Exception.Message)"
    }
    
    # 显示统计信息
    Write-Host ""
    if ($varsSet -gt 0) {
        Write-CcsSuccess "环境状态: $varsSet/4 个环境变量已设置"
    }
    else {
        Write-CcsWarning "环境状态: 没有设置任何CCS环境变量"
        Write-Host "建议运行: ccs <配置名称> 来设置配置"
    }
    
    # 配置文件信息
    Write-Host ""
    Write-CcsStep "配置文件信息:"
    Write-Host "  路径: $Script:CONFIG_FILE"
    if (Test-Path $Script:CONFIG_FILE) {
        try {
            $fileInfo = Get-Item $Script:CONFIG_FILE
            $fileSize = $fileInfo.Length
            $modifiedTime = $fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            
            Write-Host "  大小: $fileSize 字节"
            Write-Host "  修改时间: $modifiedTime"
            
            # 配置节统计
            $content = Get-Content $Script:CONFIG_FILE
            $configCount = 0
            foreach ($line in $content) {
                if ($line -match "^\s*\[.+\]\s*$") {
                    $configCount++
                }
            }
            Write-Host "  配置节数量: $configCount 个"
        }
        catch {
            Write-CcsWarning "无法获取配置文件信息: $($_.Exception.Message)"
        }
    }
    else {
        Write-CcsError "配置文件不存在"
    }
}

# 自动加载当前配置
function Load-CurrentConfig {
    if (-not (Test-ConfigFile)) {
        Write-Verbose "配置文件不存在,跳过自动加载"
        return
    }
    
    try {
        $lines = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
        $currentConfig = ""
        
        # 获取当前配置
        foreach ($line in $lines) {
            if ($line -match "^current_config\s*=\s*(.+)$") {
                $currentConfig = $matches[1].Trim()
                if (($currentConfig.StartsWith('"') -and $currentConfig.EndsWith('"')) -or 
                    ($currentConfig.StartsWith("'") -and $currentConfig.EndsWith("'"))) {
                    $currentConfig = $currentConfig.Substring(1, $currentConfig.Length - 2)
                }
                break
            }
        }
        
        # 如果没有当前配置,尝试使用默认配置
        if (-not $currentConfig) {
            foreach ($line in $lines) {
                if ($line -match "^default_config\s*=\s*(.+)$") {
                    $currentConfig = $matches[1].Trim()
                    if (($currentConfig.StartsWith('"') -and $currentConfig.EndsWith('"')) -or 
                        ($currentConfig.StartsWith("'") -and $currentConfig.EndsWith("'"))) {
                        $currentConfig = $currentConfig.Substring(1, $currentConfig.Length - 2)
                    }
                    Write-Verbose "未找到当前配置,使用默认配置: $currentConfig"
                    break
                }
            }
        }
        else {
            Write-Verbose "自动加载当前配置: $currentConfig"
        }
        
        # 如果找到了配置,则加载它
        if ($currentConfig) {
            # 检查配置是否存在
            $configExists = $false
            foreach ($line in $lines) {
                if ($line -match "^\[$currentConfig\]$") {
                    $configExists = $true
                    break
                }
            }
            
            if ($configExists) {
                Parse-Toml -ConfigName $currentConfig -SilentMode "silent"
            }
            else {
                Write-Verbose "当前配置 '$currentConfig' 不存在,回退到默认配置"
                # 尝试加载默认配置
                foreach ($line in $lines) {
                    if ($line -match "^default_config\s*=\s*(.+)$") {
                        $defaultConfig = $matches[1].Trim()
                        if (($defaultConfig.StartsWith('"') -and $defaultConfig.EndsWith('"')) -or 
                            ($defaultConfig.StartsWith("'") -and $defaultConfig.EndsWith("'"))) {
                            $defaultConfig = $defaultConfig.Substring(1, $defaultConfig.Length - 2)
                        }
                        
                        $defaultExists = $false
                        foreach ($line2 in $lines) {
                            if ($line2 -match "^\[$defaultConfig\]$") {
                                $defaultExists = $true
                                break
                            }
                        }
                        
                        if ($defaultExists) {
                            Parse-Toml -ConfigName $defaultConfig -SilentMode "silent"
                            Update-CurrentConfig -ConfigName $defaultConfig
                        }
                        break
                    }
                }
            }
        }
    }
    catch {
        Write-Verbose "自动加载配置时出错: $($_.Exception.Message)"
    }
}

# 卸载ccs工具（增强版）
function Uninstall-CCS {
    Write-Host "正在卸载Claude Code Configuration Switcher..." -ForegroundColor Yellow
    Write-Host ""
    Write-CcsStep "开始卸载ccs..."
    
    # 创建备份
    if (Test-Path $Script:CONFIG_FILE) {
        $backupResult = Backup-ConfigFile
        if ($backupResult) {
            Write-CcsInfo "已备份配置文件: $backupResult"
        }
    }
    
    # 删除整个.ccs目录（除了配置文件）
    if (Test-Path $Script:CCS_DIR) {
        # 删除脚本文件
        $batFile = "$Script:CCS_DIR\ccs.bat"
        if (Test-Path $batFile) {
            Remove-Item $batFile -Force
            Write-CcsSuccess "删除bat脚本文件"
        }
        
        $ps1File = "$Script:CCS_DIR\ccs.ps1"
        if (Test-Path $ps1File) {
            Remove-Item $ps1File -Force
            Write-CcsSuccess "删除PowerShell脚本文件"
        }
        
        # 删除web文件
        $webDir = "$Script:CCS_DIR\web"
        if (Test-Path $webDir) {
            Remove-Item $webDir -Recurse -Force
            Write-CcsSuccess "删除web文件"
        }
        
        # 删除package.json文件
        $packageFile = "$Script:CCS_DIR\package.json"
        if (Test-Path $packageFile) {
            Remove-Item $packageFile -Force
            Write-CcsSuccess "删除package.json文件"
        }
        
        # 删除备份目录
        $backupDir = "$Script:CCS_DIR\backups"
        if (Test-Path $backupDir) {
            Remove-Item $backupDir -Recurse -Force
            Write-CcsSuccess "删除备份目录"
        }
        
        # 检查.ccs目录是否为空（除了配置文件）
        $remainingFiles = Get-ChildItem $Script:CCS_DIR | Where-Object { $_.Name -notmatch "\.toml$" }
        
        if ($remainingFiles.Count -eq 0) {
            # 如果没有配置文件,删除整个目录
            if (-not (Test-Path $Script:CONFIG_FILE)) {
                Remove-Item $Script:CCS_DIR -Recurse -Force
                Write-CcsSuccess "删除.ccs目录"
            } else {
                Write-CcsWarning "保留.ccs目录（包含配置文件）"
            }
        }
    }
    
    # 删除配置文件（询问用户）
    if (Test-Path $Script:CONFIG_FILE) {
        $reply = Read-Host "是否要删除配置文件 $Script:CONFIG_FILE (y/N)"
        if ($reply -eq "y" -or $reply -eq "Y") {
            Remove-Item $Script:CONFIG_FILE -Force
            Write-CcsSuccess "删除配置文件"
            # 如果删除了配置文件且.ccs目录为空,删除目录
            if ((Test-Path $Script:CCS_DIR) -and ((Get-ChildItem $Script:CCS_DIR).Count -eq 0)) {
                Remove-Item $Script:CCS_DIR -Force
                Write-CcsSuccess "删除空的.ccs目录"
            }
        }
    }
    
    # 从PATH环境变量中移除ccs目录
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -and $currentPath.Contains($Script:CCS_DIR)) {
            $newPath = $currentPath -replace [regex]::Escape($Script:CCS_DIR + ";"), ""
            $newPath = $newPath -replace [regex]::Escape(";" + $Script:CCS_DIR), ""
            $newPath = $newPath -replace [regex]::Escape($Script:CCS_DIR), ""
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            Write-CcsSuccess "从PATH环境变量中移除ccs目录"
        } else {
            Write-CcsWarning "未在PATH环境变量中找到ccs目录"
        }
    }
    catch {
        Write-CcsWarning "处理PATH环境变量时出错: $($_.Exception.Message)"
    }
    
    # 清理环境变量
    $envVars = @("ANTHROPIC_BASE_URL", "ANTHROPIC_AUTH_TOKEN", "ANTHROPIC_MODEL", "ANTHROPIC_SMALL_FAST_MODEL")
    foreach ($var in $envVars) {
        [Environment]::SetEnvironmentVariable($var, $null, "User")
    }
    Write-CcsSuccess "清理CCS环境变量"
    
    Write-CcsSuccess "卸载完成！请重新打开PowerShell"
    Write-Host ""
    Write-CcsWarning "注意：当前PowerShell会话中的ccs命令仍然可用,直到重新打开"
}

# 备份配置文件
function Backup-ConfigFile {
    if (-not (Test-Path $Script:CONFIG_FILE)) {
        Write-CcsWarning "配置文件不存在,无法备份"
        return $null
    }
    
    try {
        $backupDir = "$Script:CCS_DIR\backups"
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "$backupDir\.ccs_config.toml.$timestamp.bak"
        
        Copy-Item $Script:CONFIG_FILE $backupFile -Force
        Write-Verbose "备份文件: $Script:CONFIG_FILE -> $backupFile"
        
        return $backupFile
    }
    catch {
        Write-CcsWarning "备份配置文件时出错: $($_.Exception.Message)"
        return $null
    }
}

# 验证配置文件完整性
function Verify-ConfigFile {
    Write-CcsStep "验证配置文件完整性: $Script:CONFIG_FILE"
    
    if (-not (Test-Path $Script:CONFIG_FILE)) {
        Write-CcsError "配置文件不存在"
        return $false
    }
    
    $errors = @()
    
    try {
        $content = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
        
        # 检查是否有配置节
        $hasSections = $false
        foreach ($line in $content) {
            if ($line -match "^\s*\[.+\]\s*$") {
                $hasSections = $true
                break
            }
        }
        
        if (-not $hasSections) {
            $errors += "配置文件中没有找到配置节"
        }
        
        # 检查文件大小（防止异常大文件）
        $fileInfo = Get-Item $Script:CONFIG_FILE
        if ($fileInfo.Length -gt 1MB) {
            $errors += "配置文件过大: $($fileInfo.Length) bytes"
        }
        
        # 输出检查结果
        if ($errors.Count -eq 0) {
            Write-CcsSuccess "配置文件完整性检查通过"
            return $true
        }
        else {
            Write-CcsError "配置文件完整性检查失败:"
            foreach ($error in $errors) {
                Write-CcsError "  - $error"
            }
            return $false
        }
    }
    catch {
        Write-CcsError "验证配置文件时出错: $($_.Exception.Message)"
        return $false
    }
}

# 启动Web界面
function Start-WebInterface {
    $webDir = "$Script:CCS_DIR\web"
    $webPath = "$webDir\index.html"
    
    if (-not (Test-Path $webPath)) {
        Handle-Error -ErrorCode $Script:ERROR_FILE_NOT_FOUND -Message "Web界面文件不存在,请重新运行安装脚本"
    }
    
    # 复制用户配置文件到web目录,确保web页面能读取到正确的配置
    if (Test-Path $Script:CONFIG_FILE) {
        try {
            Copy-Item $Script:CONFIG_FILE "$webDir\.ccs_config.toml" -Force
            Write-CcsSuccess "已复制用户配置文件到web目录"
        }
        catch {
            Write-CcsWarning "无法复制配置文件到web目录: $($_.Exception.Message)"
        }
    }
    else {
        Write-CcsWarning "未找到用户配置文件 $Script:CONFIG_FILE"
    }
    
    # 启动HTTP服务器
    $port = 8888
    Write-CcsInfo "启动web服务器在端口 $port"
    Write-CcsInfo "请在浏览器中访问: http://localhost:$port"
    
    # 检查Python可用性
    $pythonCommand = $null
    if (Get-Command "python3" -ErrorAction SilentlyContinue) {
        $pythonCommand = "python3"
    }
    elseif (Get-Command "python" -ErrorAction SilentlyContinue) {
        $pythonCommand = "python"
    }
    
    if ($pythonCommand) {
        try {
            Push-Location $webDir
            Write-CcsStep "启动Python HTTP服务器..."
            & $pythonCommand -m http.server $port
        }
        catch {
            Write-CcsError "启动HTTP服务器失败: $($_.Exception.Message)"
        }
        finally {
            Pop-Location
        }
    }
    else {
        # 尝试使用默认浏览器打开文件
        try {
            Start-Process $webPath
            Write-CcsSuccess "正在打开web配置界面..."
        }
        catch {
            Handle-Error -ErrorCode $Script:ERROR_FILE_NOT_FOUND -Message "无法启动HTTP服务器或打开浏览器,请手动打开 $webPath"
        }
    }
}

# 主函数（优化版）
function ccs {
    param([string]$command = "")
    
    $startTime = Get-Date
    Write-Verbose "CCS 主函数调用: 命令='$command', PowerShell版本=$($PSVersionTable.PSVersion)"
    
    # 检查配置文件完整性（只在需要时检查）
    if ($command -ne "help" -and $command -ne "-h" -and $command -ne "--help" -and $command -ne "version") {
        if (-not (Test-ConfigFile)) {
            Handle-Error -ErrorCode $Script:ERROR_CONFIG_MISSING -Message "配置文件 $Script:CONFIG_FILE 不存在,请先运行安装脚本来创建配置文件" -ShowHelp $true
        }
    }
    
    # 命令路由（优化的switch结构）
    switch ($command) {
        { $_ -in @("ls", "list") } {
            List-Configs
        }
        { $_ -in @("current", "show", "status") } {
            Show-Current
        }
        "web" {
            Start-WebInterface
        }
        { $_ -in @("version", "-v", "--version") } {
            Show-Version
        }
        { $_ -in @("uninstall", "remove") } {
            $reply = Read-Host "确定要卸载CCS吗？这将删除所有脚本文件 (y/N)"
            if ($reply -eq "y" -or $reply -eq "Y") {
                Uninstall-CCS
            }
            else {
                Write-CcsStep "取消卸载操作"
            }
        }
        { $_ -in @("help", "-h", "--help") } {
            Show-Help
        }
        { $_ -in @("clear-cache", "cache-clear") } {
            Clear-ConfigCache
            Write-CcsSuccess "配置缓存已清理"
        }
        { $_ -in @("verify", "check") } {
            Write-CcsInfo "验证配置文件完整性..."
            if (Verify-ConfigFile) {
                Write-CcsSuccess "配置文件验证通过"
            }
            else {
                Handle-Error -ErrorCode $Script:ERROR_CONFIG_INVALID -Message "配置文件验证失败"
            }
        }
        "backup" {
            $backupFile = Backup-ConfigFile
            if ($backupFile) {
                Write-CcsSuccess "配置文件已备份: $backupFile"
            }
            else {
                Handle-Error -ErrorCode $Script:ERROR_UNKNOWN -Message "备份失败"
            }
        }
        "" {
            # 如果没有参数,使用默认配置或当前配置
            try {
                $lines = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
                $targetConfig = ""
                
                # 首先尝试获取当前配置
                foreach ($line in $lines) {
                    if ($line -match "^current_config\s*=\s*(.+)$") {
                        $targetConfig = $matches[1].Trim()
                        if (($targetConfig.StartsWith('"') -and $targetConfig.EndsWith('"')) -or 
                            ($targetConfig.StartsWith("'") -and $targetConfig.EndsWith("'"))) {
                            $targetConfig = $targetConfig.Substring(1, $targetConfig.Length - 2)
                        }
                        break
                    }
                }
                
                # 如果没有当前配置,尝试使用默认配置
                if (-not $targetConfig) {
                    foreach ($line in $lines) {
                        if ($line -match "^default_config\s*=\s*(.+)$") {
                            $targetConfig = $matches[1].Trim()
                            if (($targetConfig.StartsWith('"') -and $targetConfig.EndsWith('"')) -or 
                                ($targetConfig.StartsWith("'") -and $targetConfig.EndsWith("'"))) {
                                $targetConfig = $targetConfig.Substring(1, $targetConfig.Length - 2)
                            }
                            break
                        }
                    }
                }
                
                if ($targetConfig) {
                    Write-CcsInfo "使用配置: $targetConfig"
                    Parse-Toml -ConfigName $targetConfig
                }
                else {
                    Handle-Error -ErrorCode $Script:ERROR_CONFIG_INVALID -Message "没有指定配置名称且没有默认配置" -ShowHelp $true
                }
            }
            catch {
                Handle-Error -ErrorCode $Script:ERROR_FILE_NOT_FOUND -Message "无法读取配置文件: $($_.Exception.Message)"
            }
        }
        default {
            # 指定的配置名称
            if ($command) {
                # 验证配置名称是否存在
                try {
                    $lines = Get-Content $Script:CONFIG_FILE -ErrorAction Stop
                    $configExists = $false
                    
                    foreach ($line in $lines) {
                        if ($line -match "^\[$command\]$") {
                            $configExists = $true
                            break
                        }
                    }
                    
                    if ($configExists) {
                        Parse-Toml -ConfigName $command
                    }
                    else {
                        Write-CcsError "配置 '$command' 不存在"
                        Write-Host ""
                        Write-CcsStep "可用的配置:"
                        List-Configs
                        exit $Script:ERROR_CONFIG_INVALID
                    }
                }
                catch {
                    Handle-Error -ErrorCode $Script:ERROR_FILE_NOT_FOUND -Message "无法读取配置文件: $($_.Exception.Message)"
                }
            }
            else {
                Handle-Error -ErrorCode $Script:ERROR_CONFIG_INVALID -Message "无效的参数" -ShowHelp $true
            }
        }
    }
    
    # 性能统计（仅在调试模式下）
    if ($PSBoundParameters.ContainsKey('Verbose') -or $VerbosePreference -eq 'Continue') {
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        Write-Verbose "CCS 命令执行完成 (耗时: $duration 秒)"
    }
}

# 初始化检查
if (-not (Test-ConfigFile)) {
    Write-Verbose "配置文件不存在,跳过自动加载"
}
else {
    # 自动加载当前配置（静默模式）
    Load-CurrentConfig
}

# 如果直接运行此脚本,则执行主函数
if ($MyInvocation.InvocationName -ne ".") {
    ccs $args[0]
}