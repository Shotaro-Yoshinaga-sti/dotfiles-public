# 1. Dotfiles

Windows環境用のdotfilesリポジトリです。設定ファイルの管理とセットアップを自動化します。

## 1.1. 📁 構成

```txt
dotfiles/
├── README.md                    # このファイル
├── .bash_profile                # Bash ログインシェル用設定
├── .bashrc                      # Bash インタラクティブシェル用設定
├── .vimrc                       # Vim 設定
├── .minttyrc                    # MinTTY ターミナル設定
├── .wslconfig                   # WSL2 グローバル設定
├── .gitconfig                   # Git設定
└── setup.ps1                    # セットアップ用スクリプト
```

## 1.2. 🚀 セットアップ手順

### 1.2.1. Windows環境

#### 1.2.1.1. シンボリックリンクの作成

管理者権限でPowerShellを開き、以下のコマンドを実行してください：

```powershell
# PowerShellを管理者として実行
.\setup.ps1
```

このスクリプトは以下の設定ファイルにシンボリックリンクを作成します：

- **shell設定**: `.bashrc`, `.bash_profile`, `.vimrc` など

#### 1.2.1.2. Hack Nard Fontの導入

下記からダウンロードしてフォントをインストール
<https://www.nerdfonts.com/font-downloads>

**注意**: この操作後、システムの再起動が必要です。

## 1.3. ⚙️ オプション

### 1.3.1. Windows環境のオプション

#### 1.3.1.1. 強制上書きモード

既存のファイルを強制的に置き換える場合：

```powershell
.\setup.ps1 -Force
```

#### 1.3.1.2. カスタムパス指定

dotfilesディレクトリが異なる場所にある場合：

```powershell
.\setup.ps1 -DotfilesPath "C:\path\to\your\dotfiles"
```

## 1.4. 📝 設定ファイルの編集

設定を変更する場合は、このリポジトリ内のファイルを直接編集してください。シンボリックリンクにより、変更は自動的に適用されます。

## 1.5. 🔧 トラブルシューティング

### 1.5.1. Windowsでのトラブルシューティング

#### 1.5.1.1. 管理者権限が必要なエラー

PowerShellまたはコマンドプロンプトを「管理者として実行」で開いてください。

#### 1.5.1.2. シンボリックリンクの作成に失敗

1. ターゲットディレクトリが存在することを確認
2. 既存のファイルがある場合は `-Force` オプションを使用
3. ウイルス対策ソフトが干渉していないか確認
