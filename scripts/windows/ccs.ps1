# Claude Code Configuration Switcher (CCS) for PowerShell
# 此脚本用于切换不同的Claude Code API配置

# 配置文件路径
$CONFIG_FILE = "$env:USERPROFILE\.ccs_config.toml"

# 检查配置文件是否存在
if (-not (Test-Path $CONFIG_FILE)) {
    Write-Host "错误: 配置文件 $CONFIG_FILE 不存在" -ForegroundColor Red
    Write-Host "请先运行安装脚本来创建配置文件"
    exit 1
}

# 显示帮助信息
function Show-Help {
    Write-Host "Claude Code Configuration Switcher (CCS)"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  ccs [配置名称]    - 切换到指定配置"
    Write-Host "  ccs list          - 列出所有可用配置"
    Write-Host "  ccs current       - 显示当前配置"
    Write-Host "  ccs uninstall     - 卸载ccs工具"
    Write-Host "  ccs help          - 显示此帮助信息"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  ccs anyrouter     - 切换到anyrouter配置"
    Write-Host "  ccs glm           - 切换到智谱GLM配置"
    Write-Host "  ccs list          - 查看所有可用配置"
    Write-Host "  ccs uninstall     - 完全卸载ccs工具"
}

# 解析TOML配置文件
function Parse-Toml {
    param([string]$configName)
    
    $configContent = @()
    $inSection = $false
    
    # 读取配置文件
    $lines = Get-Content $CONFIG_FILE
    
    foreach ($line in $lines) {
        $trimmedLine = $line.Trim()
        
        if ($trimmedLine -match "^\[$configName\]") {
            $inSection = $true
            continue
        } elseif ($trimmedLine -match "^\[.+\]") {
            if ($inSection) {
                break
            }
        } elseif ($inSection -and $trimmedLine -ne "" -and -not $trimmedLine.StartsWith("#")) {
            $configContent += $trimmedLine
        }
    }
    
    if ($configContent.Count -eq 0) {
        Write-Host "错误: 配置 '$configName' 不存在" -ForegroundColor Red
        exit 1
    }
    
    # 清理环境变量
    Remove-Item Env:ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
    Remove-Item Env:ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue
    Remove-Item Env:ANTHROPIC_MODEL -ErrorAction SilentlyContinue
    Remove-Item Env:ANTHROPIC_SMALL_FAST_MODEL -ErrorAction SilentlyContinue
    
    # 解析配置项
    foreach ($line in $configContent) {
        if ($line -match "^(.+?)\s*=\s*(.+)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # 移除引号
            if ($value.StartsWith('"') -and $value.EndsWith('"')) {
                $value = $value.Substring(1, $value.Length - 2)
            } elseif ($value.StartsWith("'") -and $value.EndsWith("'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            
            switch ($key) {
                "base_url" {
                    $env:ANTHROPIC_BASE_URL = $value
                    [Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $value, "User")
                    Write-Host "设置 ANTHROPIC_BASE_URL=$value" -ForegroundColor Green
                }
                "auth_token" {
                    $env:ANTHROPIC_AUTH_TOKEN = $value
                    [Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $value, "User")
                    Write-Host "设置 ANTHROPIC_AUTH_TOKEN=$($value.Substring(0, 10))..." -ForegroundColor Green
                }
                "model" {
                    $env:ANTHROPIC_MODEL = $value
                    [Environment]::SetEnvironmentVariable("ANTHROPIC_MODEL", $value, "User")
                    Write-Host "设置 ANTHROPIC_MODEL=$value" -ForegroundColor Green
                }
                "small_fast_model" {
                    $env:ANTHROPIC_SMALL_FAST_MODEL = $value
                    [Environment]::SetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", $value, "User")
                    Write-Host "设置 ANTHROPIC_SMALL_FAST_MODEL=$value" -ForegroundColor Green
                }
            }
        }
    }
    
    Write-Host "已切换到配置: $configName" -ForegroundColor Green
}

# 列出所有可用配置
function List-Configs {
    Write-Host "可用的配置:" -ForegroundColor Cyan
    Write-Host ""
    
    # 提取所有配置节
    $lines = Get-Content $CONFIG_FILE
    $configs = @()
    
    foreach ($line in $lines) {
        if ($line -match "^\[(.+)\]$") {
            $configName = $matches[1]
            if ($configName -ne "default_config") {
                $configs += $configName
            }
        }
    }
    
    foreach ($config in $configs) {
        # 获取配置描述
        $description = ""
        $inSection = $false
        
        foreach ($line in $lines) {
            $trimmedLine = $line.Trim()
            
            if ($trimmedLine -match "^\[$config\]") {
                $inSection = $true
                continue
            } elseif ($trimmedLine -match "^\[.+\]") {
                if ($inSection) {
                    break
                }
            } elseif ($inSection -and $trimmedLine -match "^description\s*=\s*(.+)$") {
                $descValue = $matches[1].Trim()
                if ($descValue.StartsWith('"') -and $descValue.EndsWith('"')) {
                    $descValue = $descValue.Substring(1, $descValue.Length - 2)
                } elseif ($descValue.StartsWith("'") -and $descValue.EndsWith("'")) {
                    $descValue = $descValue.Substring(1, $descValue.Length - 2)
                }
                $description = $descValue
                break
            }
        }
        
        if ($description) {
            Write-Host "  $config - $description" -ForegroundColor White
        } else {
            Write-Host "  $config" -ForegroundColor White
        }
    }
    
    Write-Host ""
    
    # 显示默认配置
    foreach ($line in $lines) {
        if ($line -match "^default_config\s*=\s*(.+)$") {
            $defaultConfig = $matches[1].Trim()
            if ($defaultConfig.StartsWith('"') -and $defaultConfig.EndsWith('"')) {
                $defaultConfig = $defaultConfig.Substring(1, $defaultConfig.Length - 2)
            } elseif ($defaultConfig.StartsWith("'") -and $defaultConfig.EndsWith("'")) {
                $defaultConfig = $defaultConfig.Substring(1, $defaultConfig.Length - 2)
            }
            Write-Host "默认配置: $defaultConfig" -ForegroundColor Yellow
            break
        }
    }
}

# 显示当前配置
function Show-Current {
    Write-Host "当前配置:" -ForegroundColor Cyan
    
    if ($env:ANTHROPIC_BASE_URL) {
        Write-Host "  ANTHROPIC_BASE_URL=$env:ANTHROPIC_BASE_URL" -ForegroundColor White
    } else {
        Write-Host "  ANTHROPIC_BASE_URL=(未设置)" -ForegroundColor Gray
    }
    
    if ($env:ANTHROPIC_AUTH_TOKEN) {
        $token = $env:ANTHROPIC_AUTH_TOKEN
        Write-Host "  ANTHROPIC_AUTH_TOKEN=$($token.Substring(0, 10))..." -ForegroundColor White
    } else {
        Write-Host "  ANTHROPIC_AUTH_TOKEN=(未设置)" -ForegroundColor Gray
    }
    
    if ($env:ANTHROPIC_MODEL) {
        Write-Host "  ANTHROPIC_MODEL=$env:ANTHROPIC_MODEL" -ForegroundColor White
    } else {
        Write-Host "  ANTHROPIC_MODEL=(未设置)" -ForegroundColor Gray
    }
    
    if ($env:ANTHROPIC_SMALL_FAST_MODEL) {
        Write-Host "  ANTHROPIC_SMALL_FAST_MODEL=$env:ANTHROPIC_SMALL_FAST_MODEL" -ForegroundColor White
    } else {
        Write-Host "  ANTHROPIC_SMALL_FAST_MODEL=(未设置)" -ForegroundColor Gray
    }
}

# 卸载ccs工具
function Uninstall-CCS {
    Write-Host "正在卸载Claude Code Configuration Switcher..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[*] 开始卸载ccs..." -ForegroundColor Cyan
    
    # 删除整个.ccs目录（除了配置文件）
    $ccsDir = "$env:USERPROFILE\.ccs"
    if (Test-Path $ccsDir) {
        # 删除脚本文件
        $batFile = "$ccsDir\ccs.bat"
        if (Test-Path $batFile) {
            Remove-Item $batFile -Force
            Write-Host "[OK] 删除bat脚本文件" -ForegroundColor Green
        }
        
        $ps1File = "$ccsDir\ccs.ps1"
        if (Test-Path $ps1File) {
            Remove-Item $ps1File -Force
            Write-Host "[OK] 删除PowerShell脚本文件" -ForegroundColor Green
        }
        
        # 删除web文件
        $webDir = "$ccsDir\web"
        if (Test-Path $webDir) {
            Remove-Item $webDir -Recurse -Force
            Write-Host "[OK] 删除web文件" -ForegroundColor Green
        }
        
        # 检查.ccs目录是否为空（除了配置文件）
        $remainingFiles = Get-ChildItem $ccsDir | Where-Object { $_.Name -ne ".ccs_config.toml" }
        
        if ($remainingFiles.Count -eq 0) {
            # 如果没有配置文件,删除整个目录
            if (-not (Test-Path $CONFIG_FILE)) {
                Remove-Item $ccsDir -Recurse -Force
                Write-Host "[OK] 删除.ccs目录" -ForegroundColor Green
            } else {
                Write-Host "[!] 保留.ccs目录（包含配置文件）" -ForegroundColor Yellow
            }
        }
    }
    
    # 删除配置文件（询问用户）
    if (Test-Path $CONFIG_FILE) {
        $reply = Read-Host "是否要删除配置文件 $CONFIG_FILE? (y/N)"
        if ($reply -eq "y" -or $reply -eq "Y") {
            Remove-Item $CONFIG_FILE -Force
            Write-Host "[OK] 删除配置文件" -ForegroundColor Green
            # 如果删除了配置文件且.ccs目录为空,删除目录
            if (Test-Path $ccsDir) {
                $remainingItems = Get-ChildItem $ccsDir
                if ($remainingItems.Count -eq 0) {
                    Remove-Item $ccsDir -Force
                    Write-Host "[OK] 删除空的.ccs目录" -ForegroundColor Green
                }
            }
        }
    }
    
    # 从PATH环境变量中移除ccs目录
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -and $currentPath.Contains($ccsDir)) {
        $newPath = $currentPath -replace [regex]::Escape($ccsDir + ";"), ""
        $newPath = $newPath -replace [regex]::Escape(";" + $ccsDir), ""
        $newPath = $newPath -replace [regex]::Escape($ccsDir), ""
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "[OK] 从PATH环境变量中移除ccs目录" -ForegroundColor Green
    } else {
        Write-Host "[!] 未在PATH环境变量中找到ccs目录" -ForegroundColor Yellow
    }
    
    Write-Host "[OK] 卸载完成！请重新打开PowerShell" -ForegroundColor Green
    Write-Host ""
    Write-Host "[!] 注意：当前PowerShell会话中的ccs命令仍然可用,直到重新打开" -ForegroundColor Yellow
}

# 主函数
function ccs {
    param([string]$command = "")
    
    switch ($command) {
        "" {
            # 如果没有参数,使用默认配置
            $lines = Get-Content $CONFIG_FILE
            $defaultConfig = ""
            
            foreach ($line in $lines) {
                if ($line -match "^default_config\s*=\s*(.+)$") {
                    $defaultConfig = $matches[1].Trim()
                    if ($defaultConfig.StartsWith('"') -and $defaultConfig.EndsWith('"')) {
                        $defaultConfig = $defaultConfig.Substring(1, $defaultConfig.Length - 2)
                    } elseif ($defaultConfig.StartsWith("'") -and $defaultConfig.EndsWith("'")) {
                        $defaultConfig = $defaultConfig.Substring(1, $defaultConfig.Length - 2)
                    }
                    break
                }
            }
            
            if ($defaultConfig) {
                Parse-Toml -configName $defaultConfig
            } else {
                Write-Host "错误: 没有指定配置名称且没有默认配置" -ForegroundColor Red
                Show-Help
                exit 1
            }
        }
        "list" {
            List-Configs
        }
        "current" {
            Show-Current
        }
        "uninstall" {
            Uninstall-CCS
        }
        "help" {
            Show-Help
        }
        "-h" {
            Show-Help
        }
        "--help" {
            Show-Help
        }
        default {
            Parse-Toml -configName $command
        }
    }
}

# 如果直接运行此脚本,则执行主函数
if ($MyInvocation.InvocationName -ne ".") {
    ccs $args[0]
}