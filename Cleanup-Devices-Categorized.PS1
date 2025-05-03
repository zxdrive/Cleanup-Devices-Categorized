# 需要以管理员权限运行

Write-Host " PowerShell 脚本初始化... " -ForegroundColor Cyan
Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "第 1 步：正在搜索并分类 '非当前状态' (通常是已卸载或未连接的) 设备..." -ForegroundColor Cyan

# 获取所有非当前设备信息
$nonPresentDevices = Get-PnpDevice -PresentOnly:$false | Where-Object { $_.InstanceId -ne $null }

if ($null -eq $nonPresentDevices -or $nonPresentDevices.Count -eq 0) {
    Write-Host "[完成] 未找到任何符合条件的 '非当前状态' 设备。" -ForegroundColor Green
    Start-Sleep -Seconds 3 
    exit
}

Write-Host "[完成] 已找到 $($nonPresentDevices.Count) 个 '非当前状态' 设备，正在按类别分组..." -ForegroundColor Green

# 按设备类别 (Class) 分组，并按类名排序
$groupedDevices = $nonPresentDevices | Group-Object -Property Class | Sort-Object Name

Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "第 2 步：发现以下 '非当前状态' 设备 (按类别详细列出):" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow

$categoryList = @{} 
$i = 1
# 遍历分组，显示类别标题和该类别下的设备列表
foreach ($group in $groupedDevices) {
    $className = $group.Name 
    Write-Host "[$($i)] 类别: $($className) (共 $($group.Count) 个 '非当前' 设备)" -ForegroundColor White -BackgroundColor DarkBlue 
    $deviceCounterInCategory = 1
    foreach ($device in $group.Group) {
        Write-Host "  $($deviceCounterInCategory). 设备名称: $($device.FriendlyName)"
        Write-Host "     状态: $($device.Status)" 
        $deviceCounterInCategory++
    }
    $categoryList[$i] = $group 
    $i++
    Write-Host "--------------------------------------------------" 
}
Write-Host "==================================================" -ForegroundColor Yellow
# === 列表显示结束 ===

# **************************************************
# ***** 严厉警告开始               *****
# **************************************************
Write-Host ""
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red -BackgroundColor Black
Write-Host "!!!                极度危险操作警告            !!!" -ForegroundColor Red -BackgroundColor Black
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red -BackgroundColor Black
Write-Host ""
Write-Warning "您正准备进行一项可能对系统产生深远影响的操作！"
Write-Warning "请务必、务必、务必极其认真地检查上面列出的【每一个】设备！"
Write-Warning "确认它们确实是您不再需要、且可以安全移除的残留信息。"
Write-Host ""
Write-Warning "【潜在风险】错误地移除设备可能导致："
Write-Warning "  - 关键硬件（如主板组件、特殊USB设备等）功能异常或完全失效！"
Write-Warning "  - 系统频繁蓝屏、无法启动或运行极其不稳定！"
Write-Warning "  - 需要花费大量时间重新安装驱动程序、进行复杂的系统修复，甚至被迫重装系统！"
Write-Warning "  - 某些您认为无用或不认识的设备，可能是其他硬件正常工作所依赖的底层组件！"
Write-Host ""
Write-Warning "【强烈建议】在进行任何选择和删除操作之前："
Write-Warning "  1. 立即手动【创建系统还原点】！"
Write-Warning "  2. 备份所有【重要个人文件和数据】到外部存储！"
Write-Warning "  3. 如果您对列表中的任何设备不确定，请【不要选择】包含该设备的类别！宁可不删，不可错删！"
Write-Host ""
Write-Warning "【责任自负】您将对因使用此脚本进行删除操作而可能引发的任何直接或间接损失承担全部责任！"
Write-Host ""
Write-Host "请在完全理解并接受上述风险，并已完成所有必要的备份措施后，才继续进行下一步的选择。" -ForegroundColor Cyan
Write-Host "--------------------------------------------------" # 分隔线，准备进入选择步骤
# **************************************************
# ***** 严厉警告结束               *****
# **************************************************


# 第 3 步：获取用户选择要清理的类别
$selectedCategories = @() 
while ($true) {
    $input = Read-Host "请输入您想要清理的类别编号 (可输入多个编号，用英文逗号','分隔; 输入 'A' 选择全部; 直接按 Enter 键取消操作)"
    if ([string]::IsNullOrWhiteSpace($input)) {
        Write-Host "操作已取消。" -ForegroundColor Yellow
        exit
    }
    if ($input -match '^[Aa]$') {
         Write-Host "确认选择: [全部类别]" -ForegroundColor Magenta
         $selectedCategories = $groupedDevices 
         break 
    }
    $selectedNumbers = $input -split ',' | ForEach-Object { $_.Trim() } 
    $validSelection = $true
    $tempSelectedGroups = @() 
    foreach ($numStr in $selectedNumbers) {
        if ($numStr -match '^\d+$' -and $categoryList.ContainsKey([int]$numStr)) {
            $num = [int]$numStr
            if (-not ($tempSelectedGroups.Name -contains $categoryList[$num].Name)) { 
                 $tempSelectedGroups += $categoryList[$num]
            }
        } else {
            Write-Warning "输入无效: '$($numStr)'。 请确保输入的是上面列表中的有效编号，并用逗号分隔。"
            $validSelection = $false 
            $tempSelectedGroups = @() 
            break 
        }
    }
    if ($validSelection) {
        $selectedCategories = $tempSelectedGroups 
        break 
    }
}

if ($selectedCategories.Count -eq 0) {
     Write-Host "未选择任何有效类别，操作终止。" -ForegroundColor Yellow
     exit
}

# 第 4 步：汇总并确认将要删除的设备
$devicesToRemove = @() 
Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "第 4 步：确认操作 - 您已选择清理以下类别的 '非当前' 设备:" -ForegroundColor Cyan
foreach ($selectedGroup in $selectedCategories) {
    Write-Host "- 类别: $($selectedGroup.Name) (包含 $($selectedGroup.Count) 个设备)"
    $devicesToRemove += $selectedGroup.Group 
}
$totalToRemove = $devicesToRemove.Count
Write-Host "总计将尝试移除 $($totalToRemove) 个设备。" -ForegroundColor Cyan
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

# 第 5 步：最终确认
Write-Warning "请最终确认！此操作将尝试移除您选定的 $($selectedCategories.Count) 个类别中的共 $($totalToRemove) 个 '非当前' 设备。"
$finalConfirmation = Read-Host "是否确定执行批量移除操作? (输入 'Y' 确认, 输入其他任意内容或直接按 Enter 取消)"

if ($finalConfirmation -match '^[Yy]$') {
    # 第 6 步：执行批量移除
    Write-Host "--------------------------------------------------" -ForegroundColor Green
    Write-Host "第 6 步：正在执行批量移除..." -ForegroundColor Green
    Write-Host "--------------------------------------------------" -ForegroundColor Green
    $removedCount = 0
    $failedCount = 0
    foreach ($device in $devicesToRemove) {
        Write-Host "  正在尝试移除: $($device.FriendlyName) (类别: $($device.Class)) ..." -NoNewline
        try {
            $process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/remove-device `"$($device.InstanceId)`"" -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) { 
                Write-Host "[成功]" -ForegroundColor Green
                $removedCount++
            } else {
                Write-Host "[失败 - PnPUtil 退出代码: $($process.ExitCode)]" -ForegroundColor Red
                $failedCount++
            }
        } catch {
            Write-Host "[执行错误: $($_.Exception.Message)]" -ForegroundColor Red
            $failedCount++
        }
    }
    # 输出总结报告
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "批量移除操作完成。" -ForegroundColor Cyan
    Write-Host "成功请求移除: $removedCount 个" -ForegroundColor Green
    Write-Host "失败或出错: $failedCount 个" -ForegroundColor Yellow
    if ($failedCount -gt 0) {
         Write-Host "提示：失败的条目可能是因为设备正在被使用、权限不足或其他原因。您可以尝试手动删除或重启后重试。" -ForegroundColor Yellow
    }
    Write-Host "注意：某些设备的完全移除可能需要重新启动计算机。" -ForegroundColor Cyan

} else {
    Write-Host "操作已取消，未移除任何设备。" -ForegroundColor Yellow
}

Write-Host "--------------------------------------------------"
Write-Host "脚本执行完毕。"
Write-Host "--------------------------------------------------"

# # 可选暂停
# Read-Host "按 Enter 键退出..."
