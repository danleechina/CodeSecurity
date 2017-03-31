需要阅读中文文档的可以点击跳转到这 [`CodeSecurity` 中文文档](https://github.com/danleechina/CodeSecurity/blob/master/README.md)

# CodeSecurity

A plugin for supporting object c code obfuscation in Xcode 8+

<p align="center"><img src ="./Demo.gif" /></p>

# Features

1. encrypt obfuscation plain text
2. encrypt obfuscation class name, method name
3. encrypt obfuscation property name
4. decrypt encrypted plain text

# Some using advices
 
 1. Not recommend for obfuscation in header file
 2. Every time you obfuscate a symbol, unless you know the theory about obfuscation, or you'd better compile and run the code. Make sure no error happend
 3. You can obfuscate symbol in header file, but make sure the code which imports the header file will not be affected
 4. Don't obfuscate symbols in subclass which was defined in super class, obfuscate it in super class
 5. If you obfuscate plain text, I recommend you to use dl_getRealText method in [mixplaintext](https://github.com/danleechina/mixplaintext/blob/master/MixIosDemo/MixOC/MixDecrypt.h), to help decrypt in running time
 6. Obfuscate class name in header file.

## Requirements

It requires `Xcode` 8.0+

## Installation

1. On OS X 10.11 El Capitan, run the following command and restart your Mac:

        sudo /usr/libexec/xpccachectl

1. Open ``CodeSecurity.xcodeproj``
1. Enable target signing for both the Application and the Source Code Extension using your own developer ID
1. Product > Archive
1. Right click archive > Show in Finder
1. Right click archive > Show Package Contents
1. Open Products, Applications
1. Drag ``CodeSecurity.app`` to your Applications folder
1. Run ``CodeSecurity.app`` and exit again.
1. Go to System Preferences -> Extensions -> Xcode Source Editor and enable the extension
1. The menu-item should now be available from Xcode's Editor menu.

## TODO

1. Support Swift code
2. Obfuscation macro should be putted after all the import header files

## Contributors

Author: [@粉碎音箱的音乐(weibo)](http://weibo.com/u/1172595722) 

Blog: [Blog](http://danleechina.github.io/)

## Starring is caring

Please star if you think it is helpful to you. Thank you. 😄

