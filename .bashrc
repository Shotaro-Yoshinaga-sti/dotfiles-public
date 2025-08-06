export LANG=ja_JP.UTF-8

# bash_historyの上限
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '

# Git bash のパス対策
# https://qiita.com/mnrst/items/bb25eae3fcdf5fc53429
export MSYS_NO_PATHCONV=1

# less日本語文字化け対策
export LESSCHARSET=utf-8

# -------------------------------------------------
# エイリアス
# -------------------------------------------------

# 一つ上のディレクトリへ移動
alias ..='cd ..'

# 2つ下のディレクトリへ移動
alias ...='cd ../..'

# bashrcを開く
alias vb='vim ~/.bashrc'

alias vs='vim ~/.ssh/config'

# 自動cd
shopt -s autocd

# タイポ補完
shopt -s cdspell

# auto mkdir_cd
mkdir()
{
    command mkdir -p "$1" && cd "$1"
}

# ------------------------------------
# ls
# ------------------------------------
# ターミナルの表示を色分けする
alias ls="ls -G"

# l:ファイル詳細
# t:更新順並び
# r:逆順
# a:全て表示
alias la="ls -ltra"

# ターミナルクリア
alias cl="clear"

# .bashrc読み込み
alias update='source ~/.bashrc'

# treeコマンドの代用
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'"

# ゴミファイル削除
alias dli='find ./ -type f -name '*:Zone.Identifier' -exec rm {} \;'

# Pythonプロセスを全て強制停止
alias killpy='taskkill /f /im python.exe 2>nul || echo "No python.exe processes found"'

# ------------------------------------
# git
# -----------------------------------
# git branch
alias gb="git branch"

# git fetch
alias gf="git fetch"

# git status
alias gs="git status"

# git add
alias ga="git add"

# git add -A
alias gaa="git add -A"

# git commit
alias gcm="git commit"

# git commit -m
alias gcmm='git commit -m'

# git commit --amend -m
alias gcmam='git commit --amend -m'

# git commit --amend --no-edit
alias gcman='git commit --amend --no-edit'

# git log --oneline --graph
alias glo="git log --oneline --graph"

# git push -f origin HEAD
alias gpo='git push -f origin HEAD'

# git diff
alias gd="git diff"

# git diff HEAD
alias gdh="git diff HEAD"

# git chechout
alias gc="git checkout"

# git checkout -b
alias gcb='git checkout -b'

# git reset
alias grs="git reset"

# git stash apply
function gsa() {
  command git stash apply stash@{$1}
}

# git stash save
alias gss='git stash save'

# git stash list
alias gsl='git stash list'

# git stash
alias gst='git stash'

# git worktree
alias gw='git worktree'

# git rebase
alias gr='git rebase'

# git rebase -i
alias gri='git rebase -i'

# git rebase --continue
alias grc='git rebase --continue'

# git rebase --abort
alias gra='git rebase --abort'

# git merge --continue
alias gmc='git merge --continue'

# git merge --abort
alias gma='git merge --abort'

# git cherry-pick
alias gcp='git cherry-pick'

# git cherry-pick --continue
alias gcpc='git cherry-pick --continue'

# git cherry-pick --abort
alias gca='git cherry-pick --abort'

# git mv
alias gm='git mv'

# git 更新
alias gup='git update-git-for-windows'

# git cherry-pick
alias gcp='git cherry-pick'

# git cherry-pick --continue
alias gcpc='git cherry-pick --continue'

# git update-index --skip-worktree
alias gus='git update-index --skip-worktree'

# git ls-files -v | grep ^S
alias gls='git ls-files -v | grep ^S'

# git update-index --skip-worktree
alias gsk='git update-index --skip-worktree'

# git 改行コードの違いを無視した差分をadd
alias gad='git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -'

# ------------------------------------
# その他
# ------------------------------------

