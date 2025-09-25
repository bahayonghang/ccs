# CCS (Claude Code Configuration Switcher) Windows 通用工具函数库
# 版本: 2.0 - 优化版
# 此文件包含Windows平台的共享功能,用于减少代码重复并提高一致性
# 包含: 性能优化、缓存机制、增强的安全性和错误处理

# 全局变量和配置
$Script:CCS_COMMON_VERSION = "2.0.0"
$Script:CCS_DIR = "$env:USERPROFILE\.ccs"
$Script:CACHE_DIR = "$Script:CCS_DIR\cache"
$Script:TEMP_DIR = "$Script:CCS_DIR\temp"
$Script:BACKUP_DIR = "$Script:CCS_DIR\backups"
$Script:LOG_DIR = "$Script:CCS_DIR\logs"

# 性能配置
$Script:CCS_CACHE_TTL = if ($env:CCS_CACHE_TTL) { [int]$env:CCS_CACHE_TTL } else { 300 }  # 缓存生存时间(秒)
$Script:CCS_MAX_RETRIES = if ($env:CCS_MAX_RETRIES) { [int]$env:CCS_MAX_RETRIES } else { 3 }  # 最大重试次数
$Script:CCS_TIMEOUT = if ($env:CCS_TIMEOUT) { [int]$env:CCS_TIMEOUT } else { 30 }  # 默认超时时间(秒)

# 错误码定义（扩展版）
$Script:ERROR_SUCCESS = 0
$Script:ERROR_CONFIG_MISSING = 1
$Script:ERROR_CONFIG_INVALID = 2
$Script:ERROR_DOWNLOAD_FAILED = 3
$Script:ERROR_PERMISSION_DENIED = 4
$Script:ERROR_FILE_NOT_FOUND = 5
$Script:ERROR_INVALID_ARGUMENT = 6
$Script:ERROR_NETWORK_UNREACHABLE = 7
$Script:ERROR_DEPENDENCY_MISSING = 8
$Script:ERROR_CONFIGURATION_CORRUPT = 9
$Script:ERROR_RESOURCE_BUSY = 10
$Script:ERROR_TIMEOUT = 11
$Script:ERROR_AUTHENTICATION_FAILED = 12
$Script:ERROR_UNKNOWN = 99

# 日志级别
$Script:LOG_LEVEL_DEBUG = 0
$Script:LOG_LEVEL_INFO = 1
$Script:LOG_LEVEL_WARN = 2
$Script:LOG_LEVEL_ERROR = 3
$Script:LOG_LEVEL_OFF = 4

# 当前日志级别（默认为INFO）
$Script:CCS_LOG_LEVEL = if ($env:CCS_LOG_LEVEL) { [int]$env:CCS_LOG_LEVEL } else { $Script:LOG_LEVEL_INFO }

# 缓存相关变量
$Script:ConfigCache = @{}
$Script:CacheTimestamp = @{}

# 初始化目录结构
function Initialize-CcsDirectories {
    $directories = @($Script:CCS_DIR, $Script:CACHE_DIR, $Script:TEMP_DIR, $Script:BACKUP_DIR, $Script:LOG_DIR)
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            try {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-Verbose "创建目录: $dir"
            }
            catch {
                Write-Warning "无法创建目录 $dir : $($_.Exception.Message)"
            }
        }
    }
}

# 统一错误处理函数（增强版）
function Handle-CcsError {
    param(
        [int]$ErrorCode,
        [string]$ErrorMessage,
        [bool]$ShowHelp = $false
    )
    
    Write-CcsError "错误[$ErrorCode]: $ErrorMessage"
    
    switch ($ErrorCode) {
        $Script:ERROR_CONFIG_MISSING {
            Write-CcsInfo "解决方案: 请运行安装脚本创建配置文件"
            Write-CcsInfo "  命令: 运行 install.bat 或 install.ps1"
        }
        $Script:ERROR_CONFIG_INVALID {
            Write-CcsInfo "解决方案: 请检查配置文件格式和必需字段"
            Write-CcsInfo "  参考: 配置文件必须包含 [section] 和 base_url、auth_token 字段"
        }
        $Script:ERROR_DOWNLOAD_FAILED {
            Write-CcsInfo "解决方案: 请检查网络连接或稍后重试"
            Write-CcsInfo "  检查: 防火墙设置、代理配置、DNS设置"
        }
        $Script:ERROR_PERMISSION_DENIED {
            Write-CcsInfo "解决方案: 请检查文件权限或使用管理员权限运行"
            Write-CcsInfo "  命令: 以管理员身份运行PowerShell"
        }
        $Script:ERROR_NETWORK_UNREACHABLE {
            Write-CcsInfo "解决方案: 请检查网络连接和防火墙设置"
            Write-CcsInfo "  测试: Test-NetConnection github.com -Port 443"
        }
        $Script:ERROR_DEPENDENCY_MISSING {
            Write-CcsInfo "解决方案: 安装缺少的依赖程序"
            Write-CcsInfo "  检查: 使用 Test-CcsDependencies 函数检查所需依赖"
        }
        $Script:ERROR_CONFIGURATION_CORRUPT {
            Write-CcsInfo "解决方案: 恢复或重新创建配置文件"
            Write-CcsInfo "  备份: 检查 $Script:BACKUP_DIR 目录中的备份文件"
        }
        $Script:ERROR_FILE_NOT_FOUND {
            Write-CcsInfo "解决方案: 检查文件路径是否正确或重新安装"
            Write-CcsInfo "  检查: 确认文件是否存在，路径是否正确"
        }
        $Script:ERROR_RESOURCE_BUSY {
            Write-CcsInfo "解决方案: 等待资源释放或终止占用的进程"
            Write-CcsInfo "  检查: Get-Process | Where-Object {$_.ProcessName -like '*ccs*'}"
        }
        $Script:ERROR_TIMEOUT {
            Write-CcsInfo "解决方案: 检查网络连接或增加超时时间"
            Write-CcsInfo "  设置: 使用 CCS_TIMEOUT 环境变量调整超时时间"
        }
        $Script:ERROR_AUTHENTICATION_FAILED {
            Write-CcsInfo "解决方案: 检查API认证令牌是否正确"
            Write-CcsInfo "  验证: 确保 auth_token 字段包含有效的API密钥"
        }
    }
    
    if ($ShowHelp) {
        Write-Host ""
        Write-Host "使用 'ccs help' 查看帮助信息"
        Write-Host "使用 'ccs --debug' 启用调试模式获取更多信息"
    }
    
    exit $ErrorCode
}

# 日志函数
function Write-CcsDebug {
    param([string]$Message)
    if ($Script:CCS_LOG_LEVEL -le $Script:LOG_LEVEL_DEBUG) {
        Write-Host "[DEBUG] $Message" -ForegroundColor Cyan
        Write-CcsLog "DEBUG" $Message
    }
}

function Write-CcsInfo {
    param([string]$Message)
    if ($Script:CCS_LOG_LEVEL -le $Script:LOG_LEVEL_INFO) {
        Write-Host "[INFO] $Message" -ForegroundColor Blue
        Write-CcsLog "INFO" $Message
    }
}

function Write-CcsWarn {
    param([string]$Message)
    if ($Script:CCS_LOG_LEVEL -le $Script:LOG_LEVEL_WARN) {
        Write-Host "[WARN] $Message" -ForegroundColor Yellow
        Write-CcsLog "WARN" $Message
    }
}

function Write-CcsError {
    param([string]$Message)
    if ($Script:CCS_LOG_LEVEL -le $Script:LOG_LEVEL_ERROR) {
        Write-Host "[ERROR] $Message" -ForegroundColor Red
        Write-CcsLog "ERROR" $Message
    }
}

# 带颜色的消息输出函数
function Write-CcsSuccess {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
    Write-CcsLog "SUCCESS" $Message
}

function Write-CcsWarning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
    Write-CcsLog "WARNING" $Message
}

function Write-CcsStep {
    param([string]$Message)
    Write-Host "[→] $Message" -ForegroundColor Cyan
    Write-CcsLog "STEP" $Message
}

# 日志写入函数
function Write-CcsLog {
    param(
        [string]$Level,
        [string]$Message
    )
    
    if ($Script:CCS_LOG_LEVEL -eq $Script:LOG_LEVEL_OFF) {
        return
    }
    
    try {
        Initialize-CcsDirectories
        $logFile = Join-Path $Script:LOG_DIR "ccs_$(Get-Date -Format 'yyyyMMdd').log"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
        
        # 清理旧日志文件
        Clear-OldLogFiles
    }
    catch {
        Write-Verbose "写入日志失败: $($_.Exception.Message)"
    }
}

# 清理旧日志文件
function Clear-OldLogFiles {
    try {
        $logFiles = Get-ChildItem -Path $Script:LOG_DIR -Filter "ccs_*.log" | Sort-Object LastWriteTime -Descending
        if ($logFiles.Count -gt 10) {
            $filesToDelete = $logFiles | Select-Object -Skip 10
            foreach ($file in $filesToDelete) {
                Remove-Item $file.FullName -Force
                Write-Verbose "删除旧日志文件: $($file.Name)"
            }
        }
    }
    catch {
        Write-Verbose "清理日志文件失败: $($_.Exception.Message)"
    }
}

# 检查命令是否存在
function Test-CommandExists {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# 检查依赖
function Test-CcsDependencies {
    param([string[]]$RequiredCommands = @())
    
    $missingCommands = @()
    foreach ($cmd in $RequiredCommands) {
        if (-not (Test-CommandExists $cmd)) {
            $missingCommands += $cmd
        }
    }
    
    if ($missingCommands.Count -gt 0) {
        Write-CcsError "缺少必需的依赖: $($missingCommands -join ', ')"
        return $false
    }
    
    return $true
}

# 高级缓存管理系统
function Get-CacheKey {
    param([string]$ConfigName)
    return "$ConfigName"
}

function Get-CacheFilePath {
    param([string]$CacheKey)
    return Join-Path $Script:CACHE_DIR "config_$CacheKey.cache"
}

function Get-CacheMetaPath {
    param([string]$CacheKey)
    return Join-Path $Script:CACHE_DIR "config_$CacheKey.meta"
}

function Test-CacheValidity {
    param([string]$ConfigName)
    
    $cacheKey = Get-CacheKey $ConfigName
    $cacheFile = Get-CacheFilePath $cacheKey
    $metaFile = Get-CacheMetaPath $cacheKey
    
    if (-not (Test-Path $cacheFile) -or -not (Test-Path $metaFile)) {
        return $false
    }
    
    try {
        $cacheTime = Get-Content $metaFile -Raw | ConvertFrom-Json
        $currentTime = Get-Date
        $ageDiff = ($currentTime - [DateTime]$cacheTime.Timestamp).TotalSeconds
        
        if ($ageDiff -lt $Script:CCS_CACHE_TTL) {
            Write-CcsDebug "缓存有效: $ConfigName (age: $ageDiff s)"
            return $true
        }
        else {
            Write-CcsDebug "缓存过期: $ConfigName (age: $ageDiff s)"
            return $false
        }
    }
    catch {
        Write-CcsDebug "缓存验证失败: $($_.Exception.Message)"
        return $false
    }
}

function Save-ConfigToCache {
    param(
        [string]$ConfigName,
        [hashtable]$ConfigData
    )
    
    try {
        Initialize-CcsDirectories
        $cacheKey = Get-CacheKey $ConfigName
        $cacheFile = Get-CacheFilePath $cacheKey
        $metaFile = Get-CacheMetaPath $cacheKey
        
        # 保存配置数据
        $ConfigData | ConvertTo-Json -Depth 10 | Set-Content $cacheFile -Encoding UTF8
        
        # 保存元数据
        $metaData = @{
            Timestamp = Get-Date
            ConfigName = $ConfigName
            Version = $Script:CCS_COMMON_VERSION
        }
        $metaData | ConvertTo-Json | Set-Content $metaFile -Encoding UTF8
        
        Write-CcsDebug "配置已缓存: $ConfigName"
    }
    catch {
        Write-CcsWarn "缓存保存失败: $($_.Exception.Message)"
    }
}

function Get-ConfigFromCache {
    param([string]$ConfigName)
    
    if (-not (Test-CacheValidity $ConfigName)) {
        return $null
    }
    
    try {
        $cacheKey = Get-CacheKey $ConfigName
        $cacheFile = Get-CacheFilePath $cacheKey
        $configData = Get-Content $cacheFile -Raw | ConvertFrom-Json -AsHashtable
        Write-CcsDebug "从缓存加载配置: $ConfigName"
        return $configData
    }
    catch {
        Write-CcsWarn "缓存读取失败: $($_.Exception.Message)"
        return $null
    }
}

function Clear-ConfigCache {
    try {
        if (Test-Path $Script:CACHE_DIR) {
            Get-ChildItem -Path $Script:CACHE_DIR -Filter "*.cache" | Remove-Item -Force
            Get-ChildItem -Path $Script:CACHE_DIR -Filter "*.meta" | Remove-Item -Force
            Write-CcsSuccess "配置缓存已清理"
        }
    }
    catch {
        Write-CcsError "清理缓存失败: $($_.Exception.Message)"
    }
}

function Get-CacheStats {
    try {
        if (-not (Test-Path $Script:CACHE_DIR)) {
            return @{ Files = 0; Size = 0 }
        }
        
        $cacheFiles = Get-ChildItem -Path $Script:CACHE_DIR -Filter "*.cache"
        $totalSize = ($cacheFiles | Measure-Object -Property Length -Sum).Sum
        
        return @{
            Files = $cacheFiles.Count
            Size = $totalSize
        }
    }
    catch {
        return @{ Files = 0; Size = 0 }
    }
}

# 敏感信息掩码
function Hide-SensitiveInfo {
    param(
        [string]$Value,
        [int]$PrefixLength = 10
    )
    
    if ([string]::IsNullOrEmpty($Value)) {
        return ""
    }
    
    if ($Value.Length -le $PrefixLength) {
        return $Value.Substring(0, 1) + "..."
    }
    else {
        return $Value.Substring(0, $PrefixLength) + "..."
    }
}

# 创建临时文件
function New-CcsTempFile {
    param([string]$Prefix = "ccs_temp")
    
    try {
        Initialize-CcsDirectories
        $tempFile = Join-Path $Script:TEMP_DIR "$Prefix_$(Get-Date -Format 'yyyyMMddHHmmss')_$([System.Guid]::NewGuid().ToString('N').Substring(0,8)).tmp"
        New-Item -ItemType File -Path $tempFile -Force | Out-Null
        return $tempFile
    }
    catch {
        Write-CcsError "创建临时文件失败: $($_.Exception.Message)"
        return $null
    }
}

# 清理临时文件
function Clear-CcsTempFiles {
    try {
        if (Test-Path $Script:TEMP_DIR) {
            $tempFiles = Get-ChildItem -Path $Script:TEMP_DIR -Filter "ccs_temp_*"
            foreach ($file in $tempFiles) {
                # 删除超过1小时的临时文件
                if ((Get-Date) - $file.LastWriteTime -gt [TimeSpan]::FromHours(1)) {
                    Remove-Item $file.FullName -Force
                    Write-CcsDebug "删除临时文件: $($file.Name)"
                }
            }
        }
    }
    catch {
        Write-CcsWarn "清理临时文件失败: $($_.Exception.Message)"
    }
}

# 初始化通用库
Initialize-CcsDirectories
Clear-CcsTempFiles

# 导出函数
Export-ModuleMember -Function *