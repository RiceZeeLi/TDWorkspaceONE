# 製作 macOS 六代同堂安裝姆指碟的程序

v2.0 - 改以「簡易程序」、「進階應用」及「深入解析」來說明。知其然，知其所以然。

## 文件目標

Apple 提供很方便的「[開機組合鍵](https://support.apple.com/zh-tw/102603)」 可以透過網路安裝適用於特定的 MacBook 最新或最舊版本的 macOS。

可惜的是，我剛好遇到一台 MacBook Pro 在安裝過程中一直都卡關在 5101F 的錯誤。參考了如下都沒能解決這個問題，於決定製作一個 macOS 安裝姆指碟來試試是否能跳過這個問題。
- [如果 Mac 沒有順暢地完成啟動 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/HT204156)
- [Fix MacBook Error 5101F With This Quick Guide - AppleToolBox](https://appletoolbox.com/fix-macbook-error-5101f/)
- [GitHub - MuertoGB/MacBRTool: 💻 MacBRTool is used to update Mac BootROM firmware in EFI mode, adding APFS support.](https://github.com/MuertoGB/MacBRTool)

我找到了三個 Cruzer Blade 16G, 一個 PNY DUAL 128G 姆指碟, 也下載了六個版本的 macOS (High Sierra, Mojave, Catalina, Big Sur, Monterey, Ventura)。在測試過「[How to create a macOS 13 Ventura installer on a USB drive](https://www.idownloadblog.com/2022/06/10/how-to-create-bootable-usb-installer-macos-ventura/) 」之後我想到是否可以將六個版本的 macOS 都放在同一個安裝姆指碟？

若可以，那我就可以一次到位安裝我要的 macOS 版本。而且放一些工具及檔案在剩下的姆指碟空間。本份文件提供相關的實作程序及外殼腳本(Shell Script)給有相同需求的朋友參考使用。

## 內容摘要

如下為簡易程序的摘要：
1. 將姆指碟分割成六加一個分割區
1. 製作 macOS 各版本的安裝卷冊
1. 進行安裝

## 準備工作

### 所需設備

- 一個 128GB 的姆指碟
- 一台 MacBook (Intel)，因為需要下載舊版本的 macOS 所以用 Intel 版本的 MacBook 來下載。

### 下載檔案

- 透過 Goolge 掃尋「Download macOS {Version}」，分別下載六個版本的 macOS (High Sierra, Mojave, Catalina, Big Sur, Monterey, Ventura) 

### 安裝工具

- 本文主要使用外殼腳本來實現。請下載 Pod 目錄中的相關檔案到本地的 Pod 目錄中。在 Pod 目錄中的 bin 目錄有本文所需的相關外殼腳本檔案。在「深入解析」一節中會解析一些外殼腳本的技巧。 etc 目錄則有配置檔案。 
  
- 本文中外殼腳本會透過如下兩個方式來使用，在此先行補充說明：

以外殼腳本的輸出做為指令`sh`的輸入且顯示所執行的指令(`-x`)：
```shell
... | sh -x
```
以外殼腳本的輸出做為指令`sh`的輸入且顯示所執行的指令(`-x`)，並以`time`量測全部的執行時間：
```shell
... | time sh -x
```

- 若不想個別下載所需檔案，如下為快速複製整個 TDWorkspaceONE 儲存庫到目前目錄中 TDWorkspaceONE 子目錄的指令：

```shell
gh repo clone RiceZeeLi/TDWorkspaceONE
```

```
正複製到 'TDWorkspaceONE'...
remote: Enumerating objects: 148, done.
remote: Counting objects: 100% (148/148), done.
remote: Compressing objects: 100% (107/107), done.
remote: Total 148 (delta 75), reused 104 (delta 39), pack-reused 0
接收物件中: 100% (148/148), 1.52 MiB | 1.48 MiB/s, 完成.
處理 delta 中: 100% (75/75), 完成.
```

- 若曾經下載過 TDWorkspaceONE 儲存庫, 則可以在 TDWorkspaceONE 目錄中透過同步的指令更新。

```
gh repo sync
```

``` text
✓ Synced the "main" branch from RiceZeeLi/TDWorkspaceONE to local repository
```
- 本文中的指令執行，都假設是在 Pod 的目錄中。

### 減少干擾

- 停止 Spotlight 的服務。

因為在製作安裝姆指碟的過程時間長且會掛載及卸載卷冊，期間 Spotlight 可能會佔住卷冊進行索引而無法順利卸載卷冊。為了減少可能的干擾， 請參考針對您的 macOS 版本所需的程序來停止 Spotlight 的服務，如「 [MacOS Sierra: Enable/Disable Spotlight Indexing - Technipages](https://www.technipages.com/macos-sierra-enable-disable-spotlight/) 」中的「Option 2 – Completely Disable Spotlight Indexing」。

## 簡易程序

整個程序透過 PartitionUSBFlashDrive 及 MakeMacOSInstallers 這兩個外殼腳本來完成。配置檔案則為 USBPartitionTable.txt 。 

### 將姆指碟分割成六加一個分割區

#### 確認姆指碟的裝置檔案

透過`diskutil list`指令或「磁碟工具程式」來確認姆指碟是用那一個裝置檔案，本文以 disk2 為例。

```shell
diskutil list
```
```text
...（略。請在姆指碟接上電腦前後分別執行 diskutil list 然後比較一下輸出的差別。）
```

#### 檢視分割配置檔案
```shell
more etc/USBPartitionTable.txt
```
```text
High Sierra,8GB
Mojave,8GB
Catalina,10GB
Big Sur,14GB
Monterey,16GB
Ventura,16GB
Pod,R
```
#### 進行分割
```shell
bin/PartitionUSBFlashDrive disk2 etc/USBPartitionTable.txt | time sh -x
```
```text
+ diskutil partitionDisk disk2 7 JHFS+ 'For High Sierra' 8GB JHFS+ 'For Mojave' 8GB JHFS+ 'For Catalina' 10GB JHFS+ 'For Big Sur' 14GB JHFS+ 'For Monterey' 16GB JHFS+ 'For Ventura' 16GB JHFS+ Pod R
Started partitioning on disk2
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk2s2 as Mac OS Extended (Journaled) with name For High Sierra
Initialized /dev/rdisk2s2 as a 7 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s3 as Mac OS Extended (Journaled) with name For Mojave
Initialized /dev/rdisk2s3 as a 7 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s4 as Mac OS Extended (Journaled) with name For Catalina
Initialized /dev/rdisk2s4 as a 9 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s5 as Mac OS Extended (Journaled) with name For Big Sur
Initialized /dev/rdisk2s5 as a 13 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s6 as Mac OS Extended (Journaled) with name For Monterey
Initialized /dev/rdisk2s6 as a 15 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s7 as Mac OS Extended (Journaled) with name For Ventura
Initialized /dev/rdisk2s7 as a 15 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s8 as Mac OS Extended (Journaled) with name Pod
Initialized /dev/rdisk2s8 as a 48 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Finished partitioning on disk2
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *124.0 GB   disk2
   1:                        EFI EFI                     209.7 MB   disk2s1
   2:                  Apple_HFS For High Sierra         7.9 GB     disk2s2
   3:                  Apple_HFS For Mojave              7.9 GB     disk2s3
   4:                  Apple_HFS For Catalina            9.9 GB     disk2s4
   5:                  Apple_HFS For Big Sur             13.9 GB    disk2s5
   6:                  Apple_HFS For Monterey            15.9 GB    disk2s6
   7:                  Apple_HFS For Ventura             15.9 GB    disk2s7
   8:                  Apple_HFS Pod                     51.7 GB    disk2s8
sh -x  0.34s user 0.22s system 0% cpu 4:54.70 total
```

### 製作 macOS 各版本的安裝卷冊

#### 製作安裝卷冊

```shell
bin/MakeMacOSInstallers etc/USBPartitionTable.txt | time sh -x
```
```text
+ '/Applications/Install macOS High Sierra.app/Contents/Resources/createinstallmedia' --volume '/Volumes/For High Sierra' --nointeraction
Erasing Disk: 0%... 10%... 20%... 30%...100%...
Copying installer files to disk...
Copy complete.
Making disk bootable...
Copying boot files...
Copy complete.
Done.
+ touch '/Volumes/Install macOS High Sierra/.metadata_never_index'
+ sleep 60
+ df
+ grep 'Shared Support'
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil list external virtual
+ grep '(disk image)'
+ read x1 z
+ diskutil unmount force '/Volumes/Install macOS High Sierra'
Volume Install macOS High Sierra on disk2s2 force-unmounted
+ '/Applications/Install macOS Mojave.app/Contents/Resources/createinstallmedia' --volume '/Volumes/For Mojave' --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Making disk bootable...
Copying boot files...
Install media now available at "/Volumes/Install macOS Mojave"
+ touch '/Volumes/Install macOS Mojave/.metadata_never_index'
+ sleep 60
+ df
+ grep 'Shared Support'
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil list external virtual
+ grep '(disk image)'
+ read x1 z
+ diskutil unmount force '/Volumes/Install macOS Mojave'
Volume Install macOS Mojave on disk2s3 force-unmounted
+ '/Applications/Install macOS Catalina.app/Contents/Resources/createinstallmedia' --volume '/Volumes/For Catalina' --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Making disk bootable...
Copying boot files...
Install media now available at "/Volumes/Install macOS Catalina"
+ touch '/Volumes/Install macOS Catalina/.metadata_never_index'
+ sleep 60
+ df
+ grep 'Shared Support'
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil list external virtual
+ grep '(disk image)'
+ read x1 z
+ diskutil unmount force '/Volumes/Install macOS Catalina'
Volume Install macOS Catalina on disk2s4 force-unmounted
+ '/Applications/Install macOS Big Sur.app/Contents/Resources/createinstallmedia' --volume '/Volumes/For Big Sur' --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Making disk bootable...
Install media now available at "/Volumes/Install macOS Big Sur"
+ touch '/Volumes/Install macOS Big Sur/.metadata_never_index'
+ sleep 60
+ df
+ grep 'Shared Support'
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil unmount force '/Volumes/Shared Support'
Volume Shared Support on disk3s2 force-unmounted
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil unmount force '/Volumes/Shared Support 1'
Volume Shared Support on disk4s2 force-unmounted
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil list external virtual
+ grep '(disk image)'
+ read x1 z
+ diskutil unmount force '/Volumes/Install macOS Big Sur'
Volume Install macOS Big Sur on disk2s5 force-unmounted
+ '/Applications/Install macOS Monterey.app/Contents/Resources/createinstallmedia' --volume '/Volumes/For Monterey' --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Making disk bootable...
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Install media now available at "/Volumes/Install macOS Monterey"
+ touch '/Volumes/Install macOS Monterey/.metadata_never_index'
+ sleep 60
+ df
+ grep 'Shared Support'
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil unmount force '/Volumes/Shared Support'
Volume Shared Support on disk5s2 force-unmounted
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil list external virtual
+ grep '(disk image)'
+ read x1 z
+ diskutil unmount force '/Volumes/Install macOS Monterey'
Volume Install macOS Monterey on disk2s6 force-unmounted
+ '/Applications/Install macOS Ventura.app/Contents/Resources/createinstallmedia' --volume '/Volumes/For Ventura' --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying essential files...
Copying the macOS RecoveryOS...
Making disk bootable...
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Install media now available at "/Volumes/Install macOS Ventura"
+ touch '/Volumes/Install macOS Ventura/.metadata_never_index'
+ sleep 60
+ df
+ grep 'Shared Support'
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil unmount force '/Volumes/Shared Support'
Volume Shared Support on disk6s2 force-unmounted
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil list external virtual
+ grep '(disk image)'
+ read x1 z
+ diskutil unmount force '/Volumes/Install macOS Ventura'
Volume Install macOS Ventura on disk2s7 force-unmounted
sh -x  107.76s user 86.19s system 2% cpu 2:08:08.90 total
```

如上可以看到執行時間為 2:08:08.90 ，2 小時 8 分鐘 8.90 秒。

如下則是透過「磁碟工具程式」看到的成果：
![All in ONE Done](All%20in%20ONE%20macOS%20Installer-Done.png "All in ONE Done")

### 進行安裝

將安裝姆指碟接上電腦，壓住 option 鍵，然後按一下電源鍵讓 MacBook 開機。若您可以順利看到如下那就「讚👍」啦！

![All in ONE boot](All%20in%20ONE%20macOS%20Installer-Boot.png "All in ONE boot")

安裝後檢視硬體版本資訊

```shell
system_profiler SPHardwareDataType
```

輸出範例一：

```text
Hardware:

    Hardware Overview:
      Model Name: MacBook Pro
      Model Identifier: MacBookPro13,2
      ...
```

輸出範例二：

```text
Hardware:

    Hardware Overview:

      Model Name: MacBook Pro
      Model Identifier: MacBookPro14,2
      ...
```

安裝後檢視作業系統版本資訊

```shell
sw_vers
```
```text
ProductName:		macOS
ProductVersion:		13.6
BuildVersion:		22G120
```

## 進階應用

如下的程序將只製作 macOS High Sierra 的安裝卷冊。

### 將姆指碟分割成一加一個分割區

#### 檢視分割配置檔案
```shell
more etc/USBPartitionTable-High\ Sierra.txt
```
```text
High Sierra,8GB
Pod,R
```
#### 進行分割
```shell
bin/PartitionUSBFlashDrive disk2 etc/USBPartitionTable-High\ Sierra.txt | sh -x
```
```text
+ diskutil partitionDisk disk2 2 JHFS+ 'For High Sierra' 8GB JHFS+ Pod R
Started partitioning on disk2
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk2s2 as Mac OS Extended (Journaled) with name For High Sierra
Initialized /dev/rdisk2s2 as a 7 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s3 as Mac OS Extended (Journaled) with name Pod
Initialized /dev/rdisk2s3 as a 7 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Finished partitioning on disk2
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *16.0 GB    disk2
   1:                        EFI EFI                     209.7 MB   disk2s1
   2:                  Apple_HFS For High Sierra         7.9 GB     disk2s2
   3:                  Apple_HFS Pod                     7.7 GB     disk2s3
```
### 製作 macOS High Sierra 的安裝卷冊

#### 製作安裝卷冊

```shell
bin/MakeMacOSInstallers etc/USBPartitionTable-High\ Sierra.txt | time sh -x
```
```text
+ '/Applications/Install macOS High Sierra.app/Contents/Resources/createinstallmedia' --volume '/Volumes/For High Sierra' --nointeraction
Erasing Disk: 0%... 10%... 20%... 30%...100%...
Copying installer files to disk...
Copy complete.
Making disk bootable...
Copying boot files...
Copy complete.
Done.
+ touch '/Volumes/Install macOS High Sierra/.metadata_never_index'
+ sync
+ sleep 60
+ df
+ grep 'Shared Support'
+ read x1 x2 x3 x4 x5 x6 x7 x8 x9
+ diskutil list external virtual
+ grep '(disk image)'
+ read x1 z
+ diskutil unmount force '/Volumes/Install macOS High Sierra'
Volume Install macOS High Sierra on disk2s2 force-unmounted
sh -x  0.25s user 4.77s system 0% cpu 24:39.79 total
```

### 突發奇想

若您的配置檔案是如下，則執行`PartitionUSBFlashDrive`後就會只有一個 Pod 的分割區。

```shell
more etc/USBPartitionTable-Pod.txt
```
```text
Pod,R
```
```shell
bin/PartitionUSBFlashDrive disk2 etc/USBPartitionTable-Pod.txt | sh -x
```
```
...（略）
```

## 深入解析

### bin/MakeMacOSInstallers

此一外殼腳本用來將各個版本的 macOS 安裝檔安裝至姆指碟對應預留的卷冊。由於會重新格式化卷冊，因此採用產生外殼腳本的方式，在檢視確認外殼腳本後再用管道`|`的方式交由`sh`、 `sh -x` 或 `time sh -x` 來執行。

如下指令的目的如`#`之後文字所加註，因為分割配置檔案是用`,`來分隔欄位，而不是一般的空白字元，如此欄位中的資料可以用空白字元：
```shell
XFS=$IFS # 保留輸入欄位分隔符(Input Field Separator)
IFS="," # 設定輸入欄位分隔符為逗號
IFS=$XFS # 還原輸入欄位分隔符
```

如下指令是為了讀取`df`輸出內容的第 9 個欄位，將其值指派到 `x9`。
```shell
read x1 x2 x3 x4 x5 x6 x7 x8 x9
```

如下指令，將 `cat "$1"` 的執行結果指派給 `list`
```shell
list=`cat "$1"`
```

如下指令在 `$list` 前後的`"`用以確保換行字元會被保留下來。
```shell
echo "$list" | ... 
```

剛剛想到，若`$list`只會被用到一次，其實也可以刪去`` list=`cat "$1"` ``指令，然後將上面的指令改為如下：
```shell
cat "$1" | ...
```

如下指令是為了讀取 diskutil 輸出內容的第 1 個欄位，將其值指派到`x1`，因為其他欄位都不重要，就指派到 `z`。
```shell
read x1 z
```

如下指令的`\"`是為了保留`"` ，如此產生的外殼腳本才能保有字串前後的`"`，因為有些字串中有空白，透過前後的`"`來確保完整的字串會被當成一個字串處理。加上`force`參數的目的則是為了強制卸載卷冊。
```shell
 echo diskutil unmount force \"/Volumes/$m\"
```

在腳本最後做了幾件事，包括：
- `touch \"/Volumes/$m/.metadata_never_index\"` 這是用來避免姆指碟在其他 macOS 上掛載後 Spotlight 對此一卷冊進行索引。
- 卸載名為「Shared Support」的卷冊及退出磁碟映像檔案。 這是因為 macOS Big Sur 之後製作安裝卷冊的過程會掛載名為「Shared Support」的卷冊。

檢視產生指令的外殼腳本
```shell
more bin/MakeMacOSInstallers
```
```shell
:
[ -z "$1" ] && exit

list=`cat "$1"`

XFS=$IFS
IFS=","
echo "$list" | grep -v Pod | while read v s
do
        l=`echo "For $v"`
        m="Install macOS $v"
        echo \"/Applications/$m.app/Contents/Resources/createinstallmedia\" --volume \"/Volumes/$l\" --nointeraction
        echo touch \"/Volumes/$m/.metadata_never_index\"
        echo sync
        echo sleep 60
cat << EOF
df | grep "Shared Support" | while read x1 x2 x3 x4 x5 x6 x7 x8 x9
do
        diskutil unmount force "\$x9"
done

diskutil list external virtual | grep "(disk image)" | while read x1 z
do
        diskutil eject "\$x1"
done
EOF
        echo diskutil unmount force \"/Volumes/$m\"
done
IFS=$XFS
```

檢視將執行的指令
```shell
bin/MakeMacOSInstallers etc/USBPartitionTable.txt
```
```shell
"/Applications/Install macOS High Sierra.app/Contents/Resources/createinstallmedia" --volume "/Volumes/For High Sierra" --nointeraction
touch "/Volumes/Install macOS High Sierra/.metadata_never_index"
sync
sleep 60
df | grep "Shared Support" | while read x1 x2 x3 x4 x5 x6 x7 x8 x9
do
	diskutil unmount force "$x9"
done

diskutil list external virtual | grep "(disk image)" | while read x1 z
do
	diskutil eject "$x1"
done
...(其餘省略)
```

### bin/MountUSBVolumes

此一外殼腳本用來掛載姆指碟上的所有卷冊。nl 指令用於將輸入的分割區配置資料加上行號，透過行號來配合切片(slice)的編號，藉此對應到正確的裝置檔案。關於 nl 的參數，可以透過 man nl 指令了解其意義。

檢視產生指令的外殼腳本
```shell
more bin/MountUSBVolumes
```
```shell
:
[ -z "$2" ] && exit

list=`cat "$2"`

XFS=$IFS
IFS=","
echo "$list" | nl -s, -v 2 -ba -n ln -w 1 | while read n v s
do
        echo diskutil mount \"$1s$n\"
done
IFS=$XFS
```

檢視將執行的指令
```shell
bin/MountUSBVolumes disk2 etc/USBPartitionTable.txt
```
```shell
diskutil mount "disk2s2"
diskutil mount "disk2s3"
diskutil mount "disk2s4"
diskutil mount "disk2s5"
diskutil mount "disk2s6"
diskutil mount "disk2s7"
diskutil mount "disk2s8"
```

### bin/PartitionUSBFlashDrive

此一外殼腳本用來產生分割姆指碟上的指令。

檢視產生指令的外殼腳本
```shell
more bin/PartitionUSBFlashDrive
```
```shell
:
[ -z "$2" ] && exit

list=`cat "$2"`

XFS=$IFS
IFS=","
parameters=`echo "$list" | while read v s
do
        echo JHFS+
        if [ "$v" = "Pod" ]
        then
                echo \"$v\"
        else
                echo \"For $v\"
        fi
        echo $s
done`
IFS=$XFS

x=`echo "$list" | wc -l`
echo diskutil partitionDisk $1 $x $parameters
```

檢視將執行的指令
```shell
bin/PartitionUSBFlashDrive disk2 etc/USBPartitionTable.txt
```
```shell
diskutil partitionDisk disk2 7 JHFS+ "For High Sierra" 8GB JHFS+ "For Mojave" 8GB JHFS+ "For Catalina" 10GB JHFS+ "For Big Sur" 14GB JHFS+ "For Monterey" 16GB JHFS+ "For Ventura" 16GB JHFS+ "Pod" R
```

### bin/RenameUSBVolumes

此一外殼腳本用來將姆指碟上的所有卷冊更名回剛分割後的名稱，如此不用重新分割就可以重新製作各版本的 macOS 安裝卷冊。

檢視產生指令的外殼腳本
```shell
more bin/RenameUSBVolumes
```
```shell
:
[ -z "$2" ] && exit

list=`cat "$2"`

XFS=$IFS
IFS=","
echo "$list" | nl -s, -v 2 -ba -n ln -w 1 | while read n v s
do
        if [ "$v" = "Pod" ]
        then
                l="$v"
        else
                l="For $v"
        fi
        echo diskutil rename \"$1s$n\" \"$l\"
done
IFS=$XFS
```

檢視將執行的指令
```shell
bin/RenameUSBVolumes disk2 etc/USBPartitionTable.txt
```
```shell
diskutil rename "disk2s2" "For High Sierra"
diskutil rename "disk2s3" "For Mojave"
diskutil rename "disk2s4" "For Catalina"
diskutil rename "disk2s5" "For Big Sur"
diskutil rename "disk2s6" "For Monterey"
diskutil rename "disk2s7" "For Ventura"
diskutil rename "disk2s8" "Pod"
```

### bin/UnmountUSBVolumes

此一外殼腳本用來卸載姆指碟上的所有卷冊。

檢視產生指令的外殼腳本
```shell
more bin/UnmountUSBVolumes
```
```shell
:
[ -z "$1" ] && exit

df | grep "$1[^0-9]" | sort | while read x1 x2 x3 x4 x5 x6 x7 x8 x9
do
        m=$x9
        echo diskutil unmount force \"$m\"
done
```

檢視將執行的指令
```shell
bin/UnmountUSBVolumes disk2
```
```shell
diskutil unmount force "/Volumes/Install macOS High Sierra"
...（略）
diskutil unmount force "/Volumes/Pod"
```

## 幕後花絮

### 錯誤訊息 -69888
```text
Erasing Disk: 0%... 10%...
Error erasing disk error number (-69888, 0)
A error occurred erasing the disk.
```
若出現如上的錯誤訊息，或許可以用 `ls /Volumes`看一下是否有同名的卷冊。

### 開機畫面

為了截取開機畫面，本來是用手機拍照，後來是接了外接 USB 鍵盤並以 HDMI 輸出接到影像擷取卡透過 OBS 來截圖。

## 參考資料

### 文件目標

- [開機組合鍵 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/102603)
- [如果 Mac 沒有順暢地完成啟動 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/HT204156)
- [Fix MacBook Error 5101F With This Quick Guide - AppleToolBox](https://appletoolbox.com/fix-macbook-error-5101f/)
- [GitHub - MuertoGB/MacBRTool: 💻 MacBRTool is used to update Mac BootROM firmware in EFI mode, adding APFS support.](https://github.com/MuertoGB/MacBRTool)
- [How to create a macOS 13 Ventura installer on a USB drive](https://www.idownloadblog.com/2022/06/10/how-to-create-bootable-usb-installer-macos-ventura/)

### 準備工作
- [MacOS Sierra: Enable/Disable Spotlight Indexing - Technipages](https://www.technipages.com/macos-sierra-enable-disable-spotlight/)
- [macos - Preventing Spotlight from Indexing Files & Folders? - Ask Different](https://apple.stackexchange.com/questions/92784/preventing-spotlight-from-indexing-files-folders)

### 其他資料

- [Apple Regulatory Information](https://regulatoryinfo.apple.com/tw/rfexposure)
- [macOS version history - Wikipedia](https://en.wikipedia.org/wiki/MacOS_version_history)
- [辨識 MacBook Pro 機型 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/HT201300)
- [Mac OS Compatibility Guide by Mac Model](https://eshop.macsales.com/guides/Mac_OS_X_Compatibility)
- [How to find out macOS version using terminal command - nixCraft](https://www.cyberciti.biz/faq/mac-osx-find-tell-operating-system-version-from-bash-prompt/)
- [若無法在外接顯示器上看見 Mac 桌面 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/guide/mac-help/mchlp2615/10.13/mac/10.13)
