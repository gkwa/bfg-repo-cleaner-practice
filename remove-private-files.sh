#/bin/sh

# git filter-branch \
#     --force \
#     --index-filter 'git rm --cached --ignore-unmatch notes.txt' \
#     --prune-empty --tag-name-filter cat -- --all

set -o errexit

# http://rtyley.github.io/bfg-repo-cleaner/
# http://repo1.maven.org/maven2/com/madgag/bfg/1.11.6/bfg-1.11.6.jar

bfgver=1.11.6
bfgjar=bfg-$bfgver.jar
wget --timestamping http://repo1.maven.org/maven2/com/madgag/bfg/$bfgver/$bfgjar

rm -rf /tmp/dotfiles.git
rm -rf /tmp/dotfiles
rm -f /tmp/dotfiles.bundle
rm -rf /tmp/dotfiles.git.bfg-report

git clone --mirror --no-hardlinks --reference /Users/demo ssh://boxstream@development.streambox.com:5979/var/www/html/proj/emacs.git /tmp/dotfiles.git
du -sh /tmp/dotfiles.git
java -jar $bfgjar --delete-files '{kee.kdb,notes.txt,.alias,unzip.exe}' \
    --delete-folders '{.ssh,.info,emacs,notes}' /tmp/dotfiles.git
cd /tmp/dotfiles.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
du -sh /tmp/dotfiles.git
git clone /tmp/dotfiles.git /tmp/dotfiles
du -sh /tmp/dotfiles

cd /tmp/dotfiles
git bundle create /tmp/dotfiles.bundle --all
du -sh /tmp/dotfiles.bundle