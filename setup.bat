@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0" 2>nul

where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 未找到 Python，请先安装 Python 3.8+
    pause
    exit /b 1
)

:menu
cls
echo ================================
echo   Codex-5.5 破甲工具管理器
echo ================================
echo.
echo   [1] 安装 - 部署破限指令
echo   [2] 卸载 - 清除破限指令
echo   [3] 状态 - 检查部署情况
echo   [Q] 退出
echo.
set "c="
set /p "c=  > "
if "%c%"=="1" goto install
if "%c%"=="2" goto uninstall
if "%c%"=="3" goto status
if /i "%c%"=="q" exit /b
goto menu

:install
echo.
echo [1/3] 运行部署脚本 ...
python "%~dp0codex-instruct.py"
if errorlevel 1 (
    echo [ERROR] 部署失败，请检查 Python 环境
    pause
    goto menu
)
echo.
echo [2/3] 验证配置 ...
set "CFG="
if exist "%USERPROFILE%\.codex\config.toml" set "CFG=%USERPROFILE%\.codex\config.toml"
if not defined CFG if exist "%LOCALAPPDATA%\OpenAI\Codex\.codex\config.toml" set "CFG=%LOCALAPPDATA%\OpenAI\Codex\.codex\config.toml"
if defined CFG (
    findstr "model_instructions_file" "!CFG!" >nul && echo   配置项: 已添加 || echo   ^^! 配置项未添加
)
if exist "%USERPROFILE%\.codex\gpt5.5-unrestricted.md" (
    echo   指令文件: 已部署
) else if exist "%LOCALAPPDATA%\OpenAI\Codex\.codex\gpt5.5-unrestricted.md" (
    echo   指令文件: 已部署
)
echo.
echo ================================
echo   安装完成！
echo   请完全退出 Codex 后重新打开
echo   (任务栏右键 ^> 退出)
echo ================================
pause
goto menu

:uninstall
echo.
echo [1/2] 清理指令文件和备份 ...
set "DELETED="
for %%d in ("%USERPROFILE%\.codex" "%LOCALAPPDATA%\OpenAI\Codex\.codex") do (
    if exist "%%~d\gpt5.5-unrestricted.md" (
        del "%%~d\gpt5.5-unrestricted.md"
        set "DELETED=1"
        echo   已删除: %%~d\gpt5.5-unrestricted.md
    )
    del "%%~d\config.toml.bak*" 2>nul
)
if not defined DELETED echo   指令文件不存在，跳过

echo [2/2] 清理配置项 ...
set "CFG="
if exist "%USERPROFILE%\.codex\config.toml" set "CFG=%USERPROFILE%\.codex\config.toml"
if not defined CFG if exist "%LOCALAPPDATA%\OpenAI\Codex\.codex\config.toml" set "CFG=%LOCALAPPDATA%\OpenAI\Codex\.codex\config.toml"
if defined CFG (
    powershell -Command "(Get-Content """!CFG!""" | Where-Object { $_ -notmatch '^\s*model_instructions_file' }) | Set-Content """!CFG!""" -Encoding Default" >nul 2>&1
    echo   已清理: model_instructions_file 配置项
) else (
    echo   未找到 config.toml，跳过
)
echo.
echo ================================
echo   已卸载，重启 Codex 后恢复默认
echo ================================
pause
goto menu

:status
echo.
echo ====== 指令文件 ======
set "FOUND="
set "CODEX_PATH="
if exist "%USERPROFILE%\.codex\gpt5.5-unrestricted.md" (
    set "FOUND=1"
    set "CODEX_PATH=%USERPROFILE%\.codex"
)
if exist "%LOCALAPPDATA%\OpenAI\Codex\.codex\gpt5.5-unrestricted.md" (
    set "FOUND=1"
    set "CODEX_PATH=%LOCALAPPDATA%\OpenAI\Codex\.codex"
)
if defined FOUND (
    echo   状态: 已部署
    echo   路径: !CODEX_PATH!\gpt5.5-unrestricted.md
) else (
    echo   状态: 未部署
)

echo.
echo ====== config.toml ======
set "CFG="
if exist "%USERPROFILE%\.codex\config.toml" set "CFG=%USERPROFILE%\.codex\config.toml"
if not defined CFG if exist "%LOCALAPPDATA%\OpenAI\Codex\.codex\config.toml" set "CFG=%LOCALAPPDATA%\OpenAI\Codex\.codex\config.toml"
if defined CFG (
    echo   路径: !CFG!
    echo.
    echo   --- 文件内容 ---
    type "!CFG!"
    echo.
    echo   --- 配置检查 ---
    findstr "model_instructions_file" "!CFG!" >nul
    if errorlevel 1 (
        echo   model_instructions_file: 未配置
    ) else (
        echo   model_instructions_file: 已配置
    )
) else (
    echo   未找到 config.toml
    echo   请先安装 Codex CLI
)
pause
goto menu
