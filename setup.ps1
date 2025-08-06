<#
.SYNOPSIS
    dotfiles�t�H���_���̃t�@�C���̃V���{���b�N�����N���쐬����X�N���v�g

.DESCRIPTION
    dotfiles�t�H���_���ɂ���ݒ�t�@�C�����A�K�؂ȏꏊ�ɃV���{���b�N�����N�Ƃ��č쐬���܂��B
    �Ǘ��Ҍ������K�v�ł��B

.PARAMETER DotfilesPath
    dotfiles�t�H���_�̃p�X�i�f�t�H���g: .�j

.PARAMETER Force
    �����̃t�@�C�����㏑�����邩�ǂ���

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

# �Ǘ��Ҍ����`�F�b�N
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# �V���{���b�N�����N�쐬�֐�
function New-SymbolicLink {
    param(
        [string]$LinkPath,
        [string]$TargetPath
    )
    
    try {
        # �����N��̃f�B���N�g�������݂��Ȃ��ꍇ�͍쐬
        $linkDir = Split-Path -Parent $LinkPath
        if (-not (Test-Path $linkDir)) {
            New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
            Write-Host "�f�B���N�g�����쐬���܂���: $linkDir" -ForegroundColor Green
        }
        
        # �����̃t�@�C��/�����N���`�F�b�N
        if (Test-Path $LinkPath) {
            # �����̃p�X���V���{���b�N�����N���ǂ����m�F
            $item = Get-Item -Path $LinkPath -Force
            $isSymLink = $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint
            
            if ($isSymLink) {
                # �V���{���b�N�����N�̏ꍇ�̓X�L�b�v
                Write-Warning "�V���{���b�N�����N�����ɑ��݂��܂�: $LinkPath (�X�L�b�v)"
                return $false
            } else {
                # �����t�@�C���͍폜
                Remove-Item $LinkPath -Force
                Write-Host "�����̃t�@�C�����폜���܂���: $LinkPath" -ForegroundColor Yellow
            }
        }
        
        # �V���{���b�N�����N���쐬
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
        Write-Host "�V���{���b�N�����N���쐬���܂���: $LinkPath -> $TargetPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "�V���{���b�N�����N�̍쐬�Ɏ��s���܂���: $LinkPath -> $TargetPath"
        Write-Error $_.Exception.Message
        return $false
    }
}

# �t�@�C���R�s�[�֐�
function Copy-File {
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )
    
    try {
        # �^�[�Q�b�g�f�B���N�g�������݂��Ȃ��ꍇ�͍쐬
        $targetDir = Split-Path -Parent $TargetPath
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Write-Host "�f�B���N�g�����쐬���܂���: $targetDir" -ForegroundColor Green
        }
        
        # �t�@�C�����R�s�[
        Copy-Item -Path $SourcePath -Destination $TargetPath -Force
        Write-Host "�t�@�C�����R�s�[���܂���: $SourcePath -> $TargetPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "�t�@�C���̃R�s�[�Ɏ��s���܂���: $SourcePath -> $TargetPath"
        Write-Error $_.Exception.Message
        return $false
    }
}

# ���C������
function Main {
    Write-Host "=== Dotfiles �V���{���b�N�����N�쐬�X�N���v�g ===" -ForegroundColor Cyan
    
    # �Ǘ��Ҍ����`�F�b�N
    if (-not (Test-Administrator)) {
        Write-Error "���̃X�N���v�g�͊Ǘ��Ҍ����Ŏ��s����K�v������܂��B"
        Write-Host "PowerShell���Ǘ��҂Ƃ��Ď��s���Ă���ēx���������������B" -ForegroundColor Yellow
        exit 1
    }
    
    # dotfiles�t�H���_�̑��݃`�F�b�N
    if (-not (Test-Path $DotfilesPath)) {
        Write-Error "dotfiles�t�H���_��������܂���: $DotfilesPath"
        exit 1
    }
    
    $DotfilesPath = Resolve-Path $DotfilesPath
    Write-Host "dotfiles�t�H���_: $DotfilesPath" -ForegroundColor Cyan
    
    # �t�@�C���}�b�s���O��`
    # �K�v�ɉ����Ēǉ��E�ύX���Ă�������
    $fileMappings = @{
        # Git�ݒ�
        ".gitconfig" = "$env:USERPROFILE\.gitconfig"
        
        # ���̑��̐ݒ�
        ".bashrc" = "$env:USERPROFILE\.bashrc"
        ".bash_profile" = "$env:USERPROFILE\.bash_profile"
        ".vimrc" = "$env:USERPROFILE\.vimrc"
        ".minttyrc" = "$env:USERPROFILE\.minttyrc"
        ".wslconfig" = "$env:USERPROFILE\.wslconfig"
    }
    
    $successCount = 0
    $skipCount = 0
    $errorCount = 0
    
    Write-Host "`n--- �V���{���b�N�����N�̍쐬���J�n���܂� ---" -ForegroundColor Cyan
    
    foreach ($mapping in $fileMappings.GetEnumerator()) {
        $sourcePath = Join-Path $DotfilesPath $mapping.Key
        $targetPath = $mapping.Value
        
        # �\�[�X�t�@�C���̑��݃`�F�b�N
        if (-not (Test-Path $sourcePath)) {
            Write-Warning "�\�[�X�t�@�C����������܂���: $sourcePath (�X�L�b�v)"
            $skipCount++
            continue
        }
        
        Write-Host "`n������: $($mapping.Key)"
        
        # hosts�t�@�C���̏ꍇ�͓��ʏ����i�R�s�[�j
        if ($mapping.Key -eq "drivers\etc\hosts") {
            $result = Copy-File -SourcePath $sourcePath -TargetPath $targetPath
        } else {
            # ���̑��̃t�@�C���̓V���{���b�N�����N
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
    
    # ���ʃT�}���[
    Write-Host "`n=== �������� ===" -ForegroundColor Cyan
    Write-Host "����: $successCount" -ForegroundColor Green
    Write-Host "�X�L�b�v: $skipCount" -ForegroundColor Yellow
    Write-Host "�G���[: $errorCount" -ForegroundColor Red
    
    if ($errorCount -eq 0) {
        Write-Host "`n�V���{���b�N�����N�̍쐬���������܂����I" -ForegroundColor Green
    } else {
        Write-Host "`n�ꕔ�̃V���{���b�N�����N�̍쐬�Ɏ��s���܂����B��L�̃G���[���b�Z�[�W���m�F���Ă��������B" -ForegroundColor Yellow
    }
}

# �X�N���v�g���s
Main