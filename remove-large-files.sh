#/bin/sh

set -o errexit

bfgver=1.11.6
bfgjar=bfg-$bfgver.jar
bfgjarPath=$(pwd)/$bfgjar
wget --timestamping http://repo1.maven.org/maven2/com/madgag/bfg/$bfgver/$bfgjar

bannedlist=$(pwd)/banned.txt

rm -rf /tmp/nsis-streambox3.git
rm -rf /tmp/nsis-streambox3
rm -rf /tmp/nsis-streambox3b

git clone --mirror ~/pdev/nsis-streambox2 /tmp/nsis-streambox3.git
git clone /tmp/nsis-streambox3.git /tmp/nsis-streambox3

cd /tmp/nsis-streambox3

git config -l | grep -i url

rm -f autoit-v3-setup.exe
rm -f nsis-2.46-Unicode-setup.exe
rm -f nsis-2.46-setup.exe
rm -f sed-4.2-1-bin.zip
rm -f sed-4.2-1-dep.zip
rm -f 7z920.msi

git commit -am "Deleting large files"
git push

echo ***REMOVED*** >$bannedlist

java \
    -jar $bfgjarPath \
    --strip-blobs-bigger-than 1M \
    --replace-text $bannedlist \
    /tmp/nsis-streambox3.git

cd /tmp/nsis-streambox3.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

git clone /tmp/nsis-streambox3.git /tmp/nsis-streambox3b

du -sh ~/pdev/nsis-streambox2
du -sh /tmp/nsis-streambox3.git
du -sh /tmp/nsis-streambox3b
