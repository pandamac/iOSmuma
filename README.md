# iOSmuma
server.cpp          -----server

rootdaemonserver    -----Trojan

locationdtweak      -----get privilege tweak

Mytest              -----normal App to use 

> **server.cpp:**

> - muma server, recv the return of rootdaemonserver
> - combile :  kali , g++ server.cpp
> - ./a.out

> **Mytest:**

> - normal App to get privilege,has the get privilege code for iOS7 and iOS8
> - click the ok,and get power and copy the deb  to the iOS device

> **rootdaemonserver:**

> - iOS server , specify the IP and port , Reverse Connection
> - combile :  make package install

> **locationdtweak:**

> - iOS tweak, 
> - combile :  make package install
> - locationd is the filter
> - locationd is root app, it has power to dpkg -i deb, and clean。

> **用法:**

> - 首先确定监听机器的IP，配置 rootdaemonserver main.mm 文件中得 serverHost 参数
> - ./make 编辑这个文件可以查看整个流程，编译 locationdtweak 和 rootdaemonserver,不同设备上编译需要修改一些参数，如签名RSA等，最后会成功一个ipa文件
> - 首先需要在 linux 或者 kali 系统上编译服务器端 server.cpp ，监听着端口
> - 然后安装 ipa 到设备上，点击 ipa 显示的ok 按钮，即可 提权安装木马，然后自动运行木马
> - 在服务器端，可以看到下面的参数  

1)command   eg: command ls

2)ListApp   List the App

3)recv more info

4)sendfile  send file to destination /tmp

5)downloadfile  download file from destination

9)quit      exit this connection

0)help   show this message