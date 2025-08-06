<#
.SYNOPSIS
    dotfilesフォルダ内のファイルのシンボリックリンクを作成するスクリプト

.DESCRIPTION
    dotfilesフォルダ内にある設定ファイルを、適切な場所にシンボリックリンクとして作成します。
    管理者権限が必要です。

.PARAMETER DotfilesPath
    dotfilesフォルダのパス（デフォルト: .）

.PARAMETER Force
    既存のファイルを上書きするかどうか

.EXAMPLE
    .\Create-DotfilesSymlinks.ps1
    
.EXAMPLE
    .\Create-DotfilesSymlinks.ps1 -DotfilesPath "C:\dotfiles" -Force
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$DotfilesPath = ".",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# 管理者権限チェック
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# シンボリックリンク作成関数
function New-SymbolicLink {
    param(
        [string]$LinkPath,
        [string]$TargetPath
    )
    
    try {
        # リンク先のディレクトリが存在しない場合は作成
        $linkDir = Split-Path -Parent $LinkPath
        if (-not (Test-Path $linkDir)) {
            New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
            Write-Host "ディレクトリを作成しました: $linkDir" -ForegroundColor Green
        }
        
        # 既存のファイル/リンクをチェック
        if (Test-Path $LinkPath) {
            # 既存のパスがシンボリックリンクかどうか確認
            $item = Get-Item -Path $LinkPath -Force
            $isSymLink = $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint
            
            if ($isSymLink) {
                # シンボリックリンクの場合はスキップ
                Write-Warning "シンボリックリンクが既に存在します: $LinkPath (スキップ)"
                return $false
            } else {
                # 既存ファイルは削除
                Remove-Item $LinkPath -Force
                Write-Host "既存のファイルを削除しました: $LinkPath" -ForegroundColor Yellow
            }
        }
        
        # シンボリックリンクを作成
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
        Write-Host "シンボリックリンクを作成しました: $LinkPath -> $TargetPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "シンボリックリンクの作成に失敗しました: $LinkPath -> $TargetPath"
        Write-Error $_.Exception.Message
        return $false
    }
}

# ファイルコピー関数
function Copy-File {
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )
    
    try {
        # ターゲットディレクトリが存在しない場合は作成
        $targetDir = Split-Path -Parent $TargetPath
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Write-Host "ディレクトリを作成しました: $targetDir" -ForegroundColor Green
        }
        
        # ファイルをコピー
        Copy-Item -Path $SourcePath -Destination $TargetPath -Force
        Write-Host "ファイルをコピーしました: $SourcePath -> $TargetPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "ファイルのコピーに失敗しました: $SourcePath -> $TargetPath"
        Write-Error $_.Exception.Message
        return $false
    }
}

# メイン処理
function Main {
    Write-Host "=== Dotfiles シンボリックリンク作成スクリプト ===" -ForegroundColor Cyan
    
    # 管理者権限チェック
    if (-not (Test-Administrator)) {
        Write-Error "このスクリプトは管理者権限で実行する必要があります。"
        Write-Host "PowerShellを管理者として実行してから再度お試しください。" -ForegroundColor Yellow
        exit 1
    }
    
    # dotfilesフォルダの存在チェック
    if (-not (Test-Path $DotfilesPath)) {
        Write-Error "dotfilesフォルダが見つかりません: $DotfilesPath"
        exit 1
    }
    
    $DotfilesPath = Resolve-Path $DotfilesPath
    Write-Host "dotfilesフォルダ: $DotfilesPath" -ForegroundColor Cyan
    
    # ファイルマッピング定義
    # 必要に応じて追加・変更してください
    $fileMappings = @{
        # Git設定
        ".gitconfig" = "$env:USERPROFILE\.gitconfig"
        
        # その他の設定
        ".bashrc" = "$env:USERPROFILE\.bashrc"
        ".bash_profile" = "$env:USERPROFILE\.bash_profile"
        ".vimrc" = "$env:USERPROFILE\.vimrc"
        ".minttyrc" = "$env:USERPROFILE\.minttyrc"
        ".wslconfig" = "$env:USERPROFILE\.wslconfig"
    }
    
    $successCount = 0
    $skipCount = 0
    $errorCount = 0
    
    Write-Host "`n--- シンボリックリンクの作成を開始します ---" -ForegroundColor Cyan
    
    foreach ($mapping in $fileMappings.GetEnumerator()) {
        $sourcePath = Join-Path $DotfilesPath $mapping.Key
        $targetPath = $mapping.Value
        
        # ソースファイルの存在チェック
        if (-not (Test-Path $sourcePath)) {
            Write-Warning "ソースファイルが見つかりません: $sourcePath (スキップ)"
            $skipCount++
            continue
        }
        
        Write-Host "`n処理中: $($mapping.Key)"
        
        # hostsファイルの場合は特別処理（コピー）
        if ($mapping.Key -eq "drivers\etc\hosts") {
            $result = Copy-File -SourcePath $sourcePath -TargetPath $targetPath
        } else {
            # その他のファイルはシンボリックリンク
            $result = New-SymbolicLink -LinkPath $targetPath -TargetPath $sourcePath -ForceOverwrite $Force
        }
        
        if ($result) {
            $successCount++
        } else {
            if ((Test-Path $targetPath) -and -not $Force) {
                $skipCount++
            } else {
                $errorCount++
            }
        }
    }
    
    # 結果サマリー
    Write-Host "`n=== 処理結果 ===" -ForegroundColor Cyan
    Write-Host "成功: $successCount" -ForegroundColor Green
    Write-Host "スキップ: $skipCount" -ForegroundColor Yellow
    Write-Host "エラー: $errorCount" -ForegroundColor Red
    
    if ($errorCount -eq 0) {
        Write-Host "`nシンボリックリンクの作成が完了しました！" -ForegroundColor Green
    } else {
        Write-Host "`n一部のシンボリックリンクの作成に失敗しました。上記のエラーメッセージを確認してください。" -ForegroundColor Yellow
    }
}

# スクリプト実行
Main