# 快速下载器 - 开发经验总结

## 目标
制作一个双击即用的便携下载器，支持中文界面，换电脑复制文件夹即可运行。

## 最终方案

```
下载器.bat       ← ASCII 编码，3行启动器
downloader.ps1   ← UTF-8 BOM，中文主程序
aria2c.exe        ← 普通下载引擎
N_m3u8DL-RE.exe   ← M3U8 下载引擎
ffmpeg.exe        ← 分片合并
```

## 踩过的坑

### 坑1：PowerShell 内嵌在 bat 的 `-Command` 中 → 闪退
- **尝试**：把 ps1 逻辑全部用 `-Command "..."` 内嵌在 bat 里
- **现象**：双击闪退，无任何提示
- **原因**：`%~dp0` 是 CMD 变量，在 PowerShell 单引号/双引号嵌套中转义复杂，路径含中文时更容易崩
- **解决**：ps1 独立文件，bat 用 `-File` 调用。参考 `D:\01_工作项目\five\speedtest\启动优选IP.bat`

### 坑2：ps1 文件名用中文 → bat 中乱码
- **尝试**：bat 中写 `-File "%~dp0下载器.ps1"`
- **现象**：bat 保存为 ASCII 后中文文件名变成 `??.ps1`，双击闪退
- **原因**：bat 文件是 ASCII/ANSI，`下载器` 这三个中文字符不在 ASCII 范围内，写入后丢失
- **解决**：ps1 用英文命名 `downloader.ps1`，中文全放在 ps1 内部

### 坑3：bat 内嵌中文用 chcp 65001 → 乱码
- **尝试**：bat 里加 `chcp 65001` 然后直接写中文 echo
- **现象**：CMD 窗口中文显示为乱码
- **原因**：bat 文件编码与 chcp 不匹配。`chcp 65001` 要求 bat 文件本身是 UTF-8，但 write_file 工具写入的 UTF-8 无 BOM 在 CMD 下不稳定
- **正确用法**：`chcp 65001` 的作用是**切换控制台代码页**，使后续输出的 UTF-8 流能正确渲染。所以 bat 保持 ASCII（只写英文和 chcp 命令），实际中文输出交给 UTF-8 BOM 编码的 ps1

### 坑4：ps1 用 `$MyInvocation.MyCommand.Path` 取脚本路径
- **尝试**：早期版本用这个变量
- **问题**：某些场景下不稳
- **解决**：改用 `$PSScriptRoot`，这是 PowerShell 3.0+ 的标准做法

### 坑5：纯 CMD bat + 中文 → 几乎不可能完美
- **结论**：CMD 对 UTF-8 支持极差，中文 bat 的正确姿势就是 **bat 启动器 + ps1 主程序**，别再尝试纯 CMD 中文

## 关键规则（给 AI Agent）

1. **bat 文件必须是 ASCII**：不要往 bat 里写非 ASCII 字符（中文、emoji 等）
2. **ps1 文件必须是 UTF-8 BOM**：PowerShell 5.1 需要 BOM 才能正确识别 UTF-8
3. **文件名全英文**：bat 和 ps1 都别用中文文件名
4. **路径用 `$PSScriptRoot`**：获取脚本所在目录
5. **bat 启动器模板**：
```bat
@echo off
chcp 65001 >nul
cd /d "%~dp0"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0xxx.ps1"
```
6. **不依赖 Python**：本工具全 exe，Windows 原生可运行
7. **便携原则**：所有 exe 放同目录，用相对路径引用，换电脑复制文件夹即可
