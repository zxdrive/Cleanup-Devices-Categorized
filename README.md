# Windows 非当前设备清理 PowerShell 脚本 (按类别)

此 PowerShell 脚本旨在帮助高级用户清理 Windows 设备管理器中不再使用的（未连接的、“隐藏的”或“幽灵”）设备。它通过先将这些设备按类别分组来简化清理过程，允许用户查看按类别组织的设备列表，并选择性地批量移除指定类别中的设备。

**⚠️ 请极其谨慎地使用此脚本，并自行承担所有风险！⚠️**

## 功能特性

* 扫描并列出所有“非当前状态”的即插即用设备。
* 按设备管理器中的“类”(Class) 对找到的设备进行分组（例如：USB、监视器、音频设备等）。
* 详细显示每个类别及其包含的具体“非当前状态”设备列表。
* 在用户进行选择操作前，显示措辞严厉的警告信息。
* 允许用户通过输入编号选择一个或多个类别，或输入 'A' 选择所有类别进行清理。
* 在尝试批量移除所选类别中的设备前，需要进行最终确认。
* 使用 Windows 官方的 `pnputil.exe /remove-device` 命令尝试进行设备移除。
* 提供移除操作的摘要报告（成功/失败计数）。
* 交互式提示和彩色输出，以提高可读性。

## 系统要求

* Windows 10 或 Windows 11
* Windows PowerShell (通常随 Windows 系统自带)
* **管理员权限:** 脚本必须在提升的（管理员）PowerShell 会话中运行。

## 如何使用

1.  **下载脚本:** 将 `Cleanup-Devices-Categorized.ps1` 脚本文件下载到您的计算机上（例如：保存到 `C:\Scripts` 目录）。
2.  **以管理员身份打开 PowerShell:**
    * 点击“开始”按钮。
    * 输入 "PowerShell"。
    * 在搜索结果中找到 "Windows PowerShell"，右键单击它。
    * 选择“以管理员身份运行”。
3.  **导航到脚本目录:** 在打开的管理员 PowerShell 窗口中，使用 `cd` 命令切换到您保存脚本的目录。例如：
    ```powershell
    cd C:\Scripts
    ```
4.  **处理执行策略 (如果需要):** PowerShell 的默认安全设置（执行策略）可能会阻止运行脚本。如果您在尝试运行脚本时遇到关于执行策略的错误，请先**在同一个管理员 PowerShell 窗口中**运行以下命令，以允许当前会话运行脚本（这通常是最安全的方法）：
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    ```
    或者，您也可以使用以下命令来运行脚本，该命令会单次绕过策略：
    ```powershell
    powershell.exe -ExecutionPolicy Bypass -File ".\Cleanup-Devices-Categorized.ps1"
    ```
5.  **运行脚本:** 输入以下命令执行脚本：
    ```powershell
    .\Cleanup-Devices-Categorized.ps1
    ```
6.  **遵循屏幕指示:**
    * 脚本将扫描并按类别显示设备列表。
    * **请极其仔细地阅读屏幕上显示的严重警告信息！**
    * 输入您想要清理的类别的编号（可以输入多个，用英文逗号 `,` 分隔，例如 `1,5,8`），或者输入 'A' 选择所有类别。直接按 Enter 键可以取消操作。
    * 检查脚本汇总的已选类别和将要移除的设备总数。
    * 输入 'Y' 进行最终确认，以开始尝试移除。输入任何其他内容将取消操作。
    * 脚本将尝试移除设备并报告结果。移除操作可能需要重新启动计算机才能完全生效。

## ⚠️ 重要警告与免责声明 ⚠️

* **务必极其谨慎:** 本脚本执行可能对系统造成损害的操作。移除错误的设备可能导致硬件故障、系统不稳定、蓝屏甚至无法启动 Windows。
* **操作可能无法撤销:** 设备移除尝试一旦执行，可能无法轻易撤销，除非您事先创建了系统还原点或需要进行复杂的故障排除。
* **仔细检查列表:** 在选择任何类别进行移除之前，请一丝不苟地检查该类别下显示的每一个设备。如果您不确定某个设备的功能或其是否可以安全移除，请【不要】选择包含该设备的类别。宁可不删，不可错删！尤其要小心“系统设备”等底层类别。
* **用户责任:** 您将对使用此脚本执行的任何操作及其可能导致的任何后果（包括数据丢失或系统损坏）承担全部责任。
* **备份至关重要:** **在运行此脚本之前，请务必：**
    * **创建系统还原点！**
    * **将所有重要的个人数据备份**到外部硬盘或云存储！
* **无法保证成功:** 本脚本使用标准的 Windows 工具 (`pnputil`) 尝试移除设备。并不保证能够成功移除每一个设备（某些设备可能受到系统保护或正在被间接使用）。

# Windows Non-Present Device Cleanup PowerShell Script (Categorized)

This PowerShell script helps advanced users clean up non-present (disconnected or "ghost") devices from the Windows Device Manager by categorizing them first. It allows users to review devices grouped by class and selectively choose which categories to attempt removing in bulk.

**⚠️ Use this script with extreme caution and at your own risk! ⚠️**

## Features

* Scans for and lists all non-present Plug-and-Play devices.
* Groups found devices by their Device Manager Class (e.g., USB, Monitor, Audio devices).
* Displays a detailed list showing each category and the specific non-present devices within it.
* Prompts the user with severe warnings before proceeding.
* Allows selection of one or more categories (by number) or all categories ('A') for cleanup.
* Requires final confirmation before attempting bulk removal of devices in selected categories.
* Uses the official `pnputil.exe /remove-device` command for removal attempts.
* Provides a summary of removal attempts (success/failure count).
* Interactive prompts and colored output for better readability.

## Requirements

* Windows 10 or Windows 11
* Windows PowerShell (usually included with Windows)
* **Administrator Privileges:** The script must be run from an elevated PowerShell session.

## How to Use

1.  **Download:** Download the `Cleanup-Devices-Categorized.ps1` script file to your computer (e.g., to `C:\Scripts`).
2.  **Open PowerShell as Administrator:**
    * Click the Start button.
    * Type "PowerShell".
    * Right-click "Windows PowerShell" in the results.
    * Select "Run as administrator".
3.  **Navigate to Script Directory:** In the Administrator PowerShell window, change to the directory where you saved the script using the `cd` command. Example:
    ```powershell
    cd C:\Scripts
    ```
4.  **Address Execution Policy (If Necessary):** By default, PowerShell might prevent running scripts. If you encounter an error about execution policy when trying to run the script, run the following command first **in the same Administrator PowerShell window** to allow scripts for the current session only (this is generally the safest method):
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    ```
    Alternatively, you can run the script using:
    ```powershell
    powershell.exe -ExecutionPolicy Bypass -File ".\Cleanup-Devices-Categorized.ps1"
    ```
5.  **Run the Script:** Execute the script using:
    ```powershell
    .\Cleanup-Devices-Categorized.ps1
    ```
6.  **Follow On-Screen Instructions:**
    * The script will scan for devices and display them grouped by category.
    * **READ THE SEVERE WARNINGS CAREFULLY.**
    * Enter the number(s) of the categories you wish to clean up (comma-separated, e.g., `1,5,8`), or 'A' for all. Press Enter to cancel.
    * Review the summary of selected categories and the total device count.
    * Provide final confirmation ('Y') to proceed with the removal attempt. Any other input cancels.
    * The script will attempt removal and report the results. A system reboot might be required for changes to fully take effect.

## ⚠️ IMPORTANT WARNINGS & DISCLAIMER ⚠️

* **EXTREME CAUTION ADVISED:** This script performs potentially dangerous system modifications. Removing the wrong device can lead to hardware malfunction, system instability, blue screens, or prevent Windows from booting.
* **IRREVERSIBLE ACTION:** Device removal attempts may not be easily reversible without a System Restore point or significant troubleshooting.
* **REVIEW CAREFULLY:** Meticulously review the list of devices presented in each category **before** selecting any category for removal. Do not remove devices if you are unsure of their function. Some system devices or components might appear "non-present" but are still required.
* **USER RESPONSIBILITY:** You are solely responsible for any actions taken by this script and any resulting consequences, including data loss or system damage.
* **BACKUP ESSENTIAL:** **BEFORE RUNNING THIS SCRIPT:**
    * **CREATE A SYSTEM RESTORE POINT.**
    * **BACK UP ALL IMPORTANT PERSONAL DATA** to an external drive or cloud storage.
* **NO GUARANTEE:** This script attempts removal using standard Windows tools (`pnputil`). Success is not guaranteed for every device (some may be protected or in use).

