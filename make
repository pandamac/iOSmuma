cd locationdtweak
make clean
rm *.deb
make package
cd ..
cd rootdaemonserver
make clean
rm *.deb
make package
cd ..

cp ./locationdtweak/_/Library/MobileSubstrate/DynamicLibraries/locationdtweak.dylib ./LatestBuild/Mytest.app/locationd.db
cp ./rootdaemonserver/*.deb ./LatestBuild/Mytest.app/muma.db

mkdir -p ipa/Payload
cp -r ./LatestBuild/Mytest.app ./ipa/Payload/
cd ipa
zip -r Mytest.ipa *
rm -rf Payload

#Step1 : 
unzip Mytest.ipa
#Step2:  
rm -rf Payload/Mytest.app/_CodeSignature
#Step3:  
cp ~/Desktop/xcq.mobileprovision Payload/Mytest.app/embedded.mobileprovision
#Step4:  
/usr/bin/codesign -f -s E7682C9864057896FC82B589085EF4A2B5F65A51 Payload/Mytest.app
#Step 5: 
zip -r MytestNew.ipa Payload
rm -rf Payload
rm -rf Mytest.ipa

#* xcq.mobileprovision 是你要用来签名的provision文件
#* E7682C9864057896FC82B589085EF4A2B5F65A51 是指该签名对应的证书的sha1值。这个可以在keychain中或者xcode中找到

#ideviceinstaller -u 584854604abd404e06d4d383890a081a499a0ec9 -i ./ipa/MytestNew.ipa