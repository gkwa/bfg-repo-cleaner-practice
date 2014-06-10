#/bin/sh


rm -rf /tmp/nsis-streambox3
rm -rf /tmp/nsis-streambox3b
rm -rf /tmp/nsis-streambox3a
rm -rf /tmp/nsis-streambox3.git

git clone --mirror ~/pdev/nsis-streambox2 /tmp/nsis-streambox3a
git clone /tmp/nsis-streambox3a /tmp/nsis-streambox3b

cd /tmp/nsis-streambox3b && git fetch --all

rm -f autoit-v3-setup.exe
rm -f nsis-2.46-Unicode-setup.exe
rm -f nsis-2.46-setup.exe
rm -f sed-4.2-1-bin.zip
rm -f sed-4.2-1-dep.zip

git commit -am "Deleting large files"

echo ***REMOVED*** >banned.txt
exit 1
java \
    -jar /Users/demo/Downloads/bfg-1.11.6.jar \
    --strip-blobs-bigger-than 1M \
    --replace-text banned.txt \
    /tmp/nsis-streambox3.git
