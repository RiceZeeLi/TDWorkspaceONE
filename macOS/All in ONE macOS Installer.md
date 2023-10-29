# 製作 macOS 六代同堂安裝姆指碟的程序

## 文件目標

Apple 提供很方便的「[開機組合鍵](https://support.apple.com/zh-tw/102603)」 可以透過網路安裝適用於特定的 MacBook 最新或最舊版本的 macOS。

可惜的是，我剛好遇到一台 MacBook Pro 在安裝過程中一直都卡關在 5101F 的錯誤。參考了如下都沒能解決這個問題，於決定製作一個 macOS 安裝姆指碟來試試是否能跳過這個問題。
- [如果 Mac 沒有順暢地完成啟動 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/HT204156)
- [Fix MacBook Error 5101F With This Quick Guide - AppleToolBox](https://appletoolbox.com/fix-macbook-error-5101f/)
- [GitHub - MuertoGB/MacBRTool: 💻 MacBRTool is used to update Mac BootROM firmware in EFI mode, adding APFS support.](https://github.com/MuertoGB/MacBRTool)

我找到了三個 Cruzer Blade 16G, 一個 PNY DUAL 128G 姆指碟, 也下載了六個版本的 macOS (High Sierra, Mojave, Catalina, Big Sur, Monterey, Ventura)。在測試過「[How to create a macOS 13 Ventura installer on a USB drive](https://www.idownloadblog.com/2022/06/10/how-to-create-bootable-usb-installer-macos-ventura/) 」之後我想到是否可以將六個版本的 macOS 都放在同一個安裝姆指碟？

若可以，那我就可以一次到位安裝我要的 macOS 版本。而且放一些工具及檔案在剩下的姆指碟空間。本份文件提供相關的實作程序及 Shell Script 給有相同需求的網友參考使用。

## 內容摘要

如下為製作程序的摘要：
1. 分割姆指碟成所需的六加一個分割區
1. 製作各版本的 macOS 安裝卷冊
1. 進行安裝

## 準備工作

### 所需設備

- 一個 128GB 的姆指碟
- 一台 MacBook (Intel)，因為需要下載舊版本的 macOS 所以用 Intel 版本的 MacBook 來下載。

### 下載檔案

- 透過 Goolge 掃尋「Download macOS {Version}」，分別下載六個版本的 macOS (High Sierra, Mojave, Catalina, Big Sur, Monterey, Ventura) 

### 安裝工具

- 本文主要使用 Shell Script 來實現。在 Pod 目錄中的 bin 目錄有本文所需的相關 Shell Script 檔案。在「深入解析」一節中會解析一些 Shell Script 的技巧。 etc 目錄則有配置檔案。
- 本文中的指令執行，都假設是在 Pod 的目錄中。

### 減少干擾

- 因為在製作安裝姆指碟過程中時間長且會掛載及卸載卷冊，期間 Spotlight 會佔住卷冊進行索引而無法順利卸載，因此透過如下減少 Spotlight 的干擾。另外的方式則是停止 Spotlight 的服務。

檢視 Shell Script
```shell
more bin/HuntForVolumeLockers
```

```shell
:
while sleep 1
do
        pkill -9 mds mds_stores mdsync
done
```

另開一個視窗，並在 sudo -i 後，以 root 的身份執行。在製作安裝姆指碟完成後以 ctrl-C 中斷 HungForMDS 的執行。

```shell
bin/HuntForVolumeLockers
```

## 詳細內容

### 分割姆指碟成所需的六加一個分割區

#### 進行分割

透過 diskutil 來確認姆指碟是用那一個裝置檔案，本文以 disk2 為例
```shell
diskutil list
```

檢視產生指令的 Shell Script

```shell
more bin/PartitionUSBFlashDrive
```

```shell
:
[ -z "$2" ] && exit

list=`cat $2`

XFS=$IFS
IFS=","
parameters=`echo "$list" | while read v s
do
        echo JHFS+
        echo \"$v\" | tr ' ' '_'
        echo $s
done`
IFS=$XFS

x=`echo "$list" | wc -l`
echo diskutil partitionDisk $1 $x $parameters

XFS=$IFS
IFS=","
echo "$list" | nl -s, -v 2 -ba -n ln -w 1 | while read n v s
do
        l=`echo $v | tr ' ' '_'`
        echo touch \"/Volumes/$l/.metadata_never_index\"
done
IFS=$XFS
```

檢視配置檔案

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

檢視將執行的指令

```shell
bin/PartitionUSBFlashDrive disk2 etc/USBPartitionTable.txt
```

```shell
diskutil partitionDisk disk2 7 JHFS+ "High_Sierra" 8GB JHFS+ "Mojave" 8GB JHFS+ "Catalina" 10GB JHFS+ "Big_Sur" 14GB JHFS+ "Monterey" 16GB JHFS+ "Ventura" 16GB JHFS+ "Pod" R
touch "/Volumes/Sierra,8GB/.metadata_never_index"
touch "/Volumes//.metadata_never_index"
touch "/Volumes//.metadata_never_index"
touch "/Volumes/Sur,14GB/.metadata_never_index"
touch "/Volumes//.metadata_never_index"
touch "/Volumes//.metadata_never_index"
touch "/Volumes//.metadata_never_index"
```

執行指令

```shell
bin/PartitionUSBFlashDrive disk2 etc/USBPartitionTable.txt | sh -x
```
```text
+ diskutil partitionDisk disk2 7 JHFS+ High_Sierra 8GB JHFS+ Mojave 8GB JHFS+ Catalina 10GB JHFS+ Big_Sur 14GB JHFS+ Monterey 16GB JHFS+ Ventura 16GB JHFS+ Pod R
Started partitioning on disk2
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk2s2 as Mac OS Extended (Journaled) with name High_Sierra
Initialized /dev/rdisk2s2 as a 7 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s3 as Mac OS Extended (Journaled) with name Mojave
Initialized /dev/rdisk2s3 as a 7 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s4 as Mac OS Extended (Journaled) with name Catalina
Initialized /dev/rdisk2s4 as a 9 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Could not mount disk2s4 after erase
Formatting disk2s5 as Mac OS Extended (Journaled) with name Big_Sur
Initialized /dev/rdisk2s5 as a 13 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Could not mount disk2s5 after erase
Formatting disk2s6 as Mac OS Extended (Journaled) with name Monterey
Initialized /dev/rdisk2s6 as a 15 GB case-insensitive HFS Plus volume with a 8192k journal
Mounting disk
Formatting disk2s7 as Mac OS Extended (Journaled) with name Ventura
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
   2:                  Apple_HFS High_Sierra             7.9 GB     disk2s2
   3:                  Apple_HFS Mojave                  7.9 GB     disk2s3
   4:                  Apple_HFS Catalina                9.9 GB     disk2s4
   5:                  Apple_HFS Big_Sur                 13.9 GB    disk2s5
   6:                  Apple_HFS Monterey                15.9 GB    disk2s6
   7:                  Apple_HFS Ventura                 15.9 GB    disk2s7
   8:                  Apple_HFS Pod                     51.7 GB    disk2s8
+ touch /Volumes/High_Sierra/.metadata_never_index
+ touch /Volumes/Mojave/.metadata_never_index
+ touch /Volumes/Catalina/.metadata_never_index
+ touch /Volumes/Big_Sur/.metadata_never_index
+ touch /Volumes/Monterey/.metadata_never_index
+ touch /Volumes/Ventura/.metadata_never_index
+ touch /Volumes/Pod/.metadata_never_index
```

#### 停止新建立卷冊的索引

檢視產生指令的 Shell Script

```shell
more bin/NoIndex-mdutil
```

```shell
:
[ -z "$1" ] && exit

df | grep "$1[^0-9]" | sort | while read x1 x2 x3 x4 x5 x6 x7 x8 x9
do
        m="$x9"
        echo mdutil -d -E \"$m\"
done
```

檢視將執行的指令

```shell
bin/NoIndex-mdutil disk2
```

```shell
mdutil -d -E "/Volumes/High_Sierra"
mdutil -d -E "/Volumes/Mojave"
mdutil -d -E "/Volumes/Catalina"
mdutil -d -E "/Volumes/Big_Sur"
mdutil -d -E "/Volumes/Monterey"
mdutil -d -E "/Volumes/Ventura"
mdutil -d -E "/Volumes/Pod"
```

執行指令

```shell
bin/NoIndex-mdutil disk2 | sh -x
```

```text
+ mdutil -d -E /Volumes/High_Sierra
/System/Volumes/Data/Volumes/High_Sierra:
2023-10-29 14:52:28.692 mdutil[2592:51893] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/High_Sierra -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E /Volumes/Mojave
/System/Volumes/Data/Volumes/Mojave:
2023-10-29 14:56:35.987 mdutil[2635:53183] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Mojave -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E /Volumes/Catalina
/System/Volumes/Data/Volumes/Catalina:
2023-10-29 14:59:54.119 mdutil[2651:54179] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Catalina -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E /Volumes/Big_Sur
/System/Volumes/Data/Volumes/Big_Sur:
2023-10-29 15:05:10.313 mdutil[2661:55641] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Big_Sur -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E /Volumes/Monterey
/System/Volumes/Data/Volumes/Monterey:
2023-10-29 15:18:33.289 mdutil[2671:58925] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Monterey -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E /Volumes/Ventura
/System/Volumes/Data/Volumes/Ventura:
2023-10-29 15:25:45.562 mdutil[2688:62214] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Ventura -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E /Volumes/Pod
/System/Volumes/Data/Volumes/Pod:
2023-10-29 15:28:20.198 mdutil[2698:63720] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Pod -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
```
#### 檢視 Spotlight 的索引檔案在停用索引後的情況

執行指令 

```shell
find /Volumes/*/.Spotlight-V100
```

如下可以看到索引檔案是清空的

```text
/Volumes/Big_Sur/.Spotlight-V100
/Volumes/Big_Sur/.Spotlight-V100/Store-V2
/Volumes/Big_Sur/.Spotlight-V100/VolumeConfiguration.plist
/Volumes/Catalina/.Spotlight-V100
/Volumes/Catalina/.Spotlight-V100/Store-V2
/Volumes/Catalina/.Spotlight-V100/VolumeConfiguration.plist
/Volumes/High_Sierra/.Spotlight-V100
/Volumes/High_Sierra/.Spotlight-V100/Store-V2
/Volumes/High_Sierra/.Spotlight-V100/VolumeConfiguration.plist
/Volumes/Mojave/.Spotlight-V100
/Volumes/Mojave/.Spotlight-V100/Store-V2
/Volumes/Mojave/.Spotlight-V100/VolumeConfiguration.plist
/Volumes/Monterey/.Spotlight-V100
/Volumes/Monterey/.Spotlight-V100/Store-V2
/Volumes/Monterey/.Spotlight-V100/VolumeConfiguration.plist
/Volumes/Pod/.Spotlight-V100
/Volumes/Pod/.Spotlight-V100/Store-V2
/Volumes/Pod/.Spotlight-V100/VolumeConfiguration.plist
/Volumes/Ventura/.Spotlight-V100
/Volumes/Ventura/.Spotlight-V100/Store-V2
/Volumes/Ventura/.Spotlight-V100/VolumeConfiguration.plist
```

![All in ONE Partitions](All%20in%20ONE%20macOS%20Installer-Partitions.png "All in ONE Partitions")

### 製作各版本的 macOS 安裝卷冊

#### 製作安裝卷冊

檢視產生指令的 Shell Script

```shell
more bin/MakeMacOSInstallers
```

```shell
:
[ -z "$1" ] && exit

list=`cat $1`

XFS=$IFS
IFS=","
echo "$list" | grep -v Pod | while read v s
do
        l=`echo $v | tr ' ' '_'`
        echo \"/Applications/Install macOS $v.app/Contents/Resources/createinstallmedia\" --volume \"/Volumes/$l\" --nointeraction
        echo touch \"/Volumes/Install macOS $v/.metadata_never_index\"
        echo sleep 60
done
IFS=$XFS
```

檢視將執行的指令
```shell
 bin/MakeMacOSInstallers etc/USBPartitionTable.txt
 ```
 ```shell
"/Applications/Install macOS High Sierra.app/Contents/Resources/createinstallmedia" --volume "/Volumes/High_Sierra" --nointeraction
touch "/Volumes/Install macOS High Sierra/.metadata_never_index"
sleep 60
"/Applications/Install macOS Mojave.app/Contents/Resources/createinstallmedia" --volume "/Volumes/Mojave" --nointeraction
touch "/Volumes/Install macOS Mojave/.metadata_never_index"
sleep 60
"/Applications/Install macOS Catalina.app/Contents/Resources/createinstallmedia" --volume "/Volumes/Catalina" --nointeraction
touch "/Volumes/Install macOS Catalina/.metadata_never_index"
sleep 60
"/Applications/Install macOS Big Sur.app/Contents/Resources/createinstallmedia" --volume "/Volumes/Big_Sur" --nointeraction
touch "/Volumes/Install macOS Big Sur/.metadata_never_index"
sleep 60
"/Applications/Install macOS Monterey.app/Contents/Resources/createinstallmedia" --volume "/Volumes/Monterey" --nointeraction
touch "/Volumes/Install macOS Monterey/.metadata_never_index"
sleep 60
"/Applications/Install macOS Ventura.app/Contents/Resources/createinstallmedia" --volume "/Volumes/Ventura" --nointeraction
touch "/Volumes/Install macOS Ventura/.metadata_never_index"
sleep 60
```

執行指令
```shell
bin/MakeMacOSInstallers etc/USBPartitionTable.txt | time sh -x
```

```text
+ '/Applications/Install macOS High Sierra.app/Contents/Resources/createinstallmedia' --volume /Volumes/High_Sierra --nointeraction
Erasing Disk: 0%... 10%... 20%... 30%...100%...
Copying installer files to disk...
Copy complete.
Making disk bootable...
Copying boot files...
Copy complete.
Done.
+ touch '/Volumes/Install macOS High Sierra/.metadata_never_index'
+ sleep 60
+ '/Applications/Install macOS Mojave.app/Contents/Resources/createinstallmedia' --volume /Volumes/Mojave --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Making disk bootable...
Copying boot files...
Install media now available at "/Volumes/Install macOS Mojave"
+ touch '/Volumes/Install macOS Mojave/.metadata_never_index'
+ sleep 60
+ '/Applications/Install macOS Catalina.app/Contents/Resources/createinstallmedia' --volume /Volumes/Catalina --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Making disk bootable...
Copying boot files...
Install media now available at "/Volumes/Install macOS Catalina"
+ touch '/Volumes/Install macOS Catalina/.metadata_never_index'
+ sleep 60
+ '/Applications/Install macOS Big Sur.app/Contents/Resources/createinstallmedia' --volume /Volumes/Big_Sur --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Making disk bootable...
Install media now available at "/Volumes/Install macOS Big Sur"
+ touch '/Volumes/Install macOS Big Sur/.metadata_never_index'
+ sleep 60
+ '/Applications/Install macOS Monterey.app/Contents/Resources/createinstallmedia' --volume /Volumes/Monterey --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Making disk bootable...
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Install media now available at "/Volumes/Install macOS Monterey"
+ touch '/Volumes/Install macOS Monterey/.metadata_never_index'
+ sleep 60
+ '/Applications/Install macOS Ventura.app/Contents/Resources/createinstallmedia' --volume /Volumes/Ventura --nointeraction
Erasing disk: 0%... 10%... 20%... 30%... 100%
Copying essential files...
Copying the macOS RecoveryOS...
Making disk bootable...
Copying to disk: 0%... 10%... 20%... 30%... 40%... 50%... 60%... 70%... 80%... 90%... 100%
Install media now available at "/Volumes/Install macOS Ventura"
+ touch '/Volumes/Install macOS Ventura/.metadata_never_index'
+ sleep 60
     4288.76 real        58.16 user        58.27 sys
```

附註：在執行過程曾發生失敗。若執行失敗，可以清除特定卷冊並複製指令單獨執行。

```text
Erasing disk: 0%... 10%...
Error erasing disk error number (-69888, 0)
An error occurred erasing the disk.
```

#### 停止安裝卷冊的索引

檢視產生指令的 Shell Script

```shell
more bin/NoIndex-mdutil-d-E
```
```shell
:
[ -z "$1" ] && exit

df | grep "$1[^0-9]" | sort | while read x1 x2 x3 x4 x5 x6 x7 x8 x9
do
        m="$x9"
        echo mdutil -d -E \"$m\"
done
```
檢視將執行的指令

```shell
bin/NoIndex-mdutil-d-E disk2
```

```shell
mdutil -d -E "/Volumes/Install macOS High Sierra"
mdutil -d -E "/Volumes/Install macOS Mojave"
mdutil -d -E "/Volumes/Install macOS Catalina"
mdutil -d -E "/Volumes/Install macOS Big Sur"
mdutil -d -E "/Volumes/Install macOS Monterey"
mdutil -d -E "/Volumes/Install macOS Ventura"
mdutil -d -E "/Volumes/Pod"
```

執行指令

```shell
bin/NoIndex-mdutil-d-E disk2 | sh -x
```

```text
+ mdutil -d -E '/Volumes/Install macOS High Sierra'
/System/Volumes/Data/Volumes/Install macOS High Sierra:
2023-10-29 22:16:05.425 mdutil[30250:330410] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Install macOS High Sierra -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E '/Volumes/Install macOS Mojave'
/System/Volumes/Data/Volumes/Install macOS Mojave:
2023-10-29 22:16:05.498 mdutil[30255:330462] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Install macOS Mojave -> kMDConfigSearchLevelOff
Error: unable to perform operation.  (-1)
	No index.
+ mdutil -d -E '/Volumes/Install macOS Catalina'
/System/Volumes/Data/Volumes/Install macOS Catalina:
2023-10-29 22:16:15.774 mdutil[30258:330471] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Install macOS Catalina -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E '/Volumes/Install macOS Big Sur'
/System/Volumes/Data/Volumes/Install macOS Big Sur:
2023-10-29 22:16:15.872 mdutil[30280:330605] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Install macOS Big Sur -> kMDConfigSearchLevelOff
Error: unable to perform operation.  (-1)
	No index.
+ mdutil -d -E '/Volumes/Install macOS Monterey'
/System/Volumes/Data/Volumes/Install macOS Monterey:
2023-10-29 22:16:26.162 mdutil[30283:330613] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Install macOS Monterey -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
+ mdutil -d -E '/Volumes/Install macOS Ventura'
/System/Volumes/Data/Volumes/Install macOS Ventura:
2023-10-29 22:16:26.248 mdutil[30305:330769] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Install macOS Ventura -> kMDConfigSearchLevelOff
Error: unable to perform operation.  (-1)
	No index.
+ mdutil -d -E /Volumes/Pod
/System/Volumes/Data/Volumes/Pod:
2023-10-29 22:16:36.533 mdutil[30308:330779] mdutil disabling Spotlight: /System/Volumes/Data/Volumes/Pod -> kMDConfigSearchLevelOff
	Indexing and searching disabled.
Rices-MacBook-Pro:Pod root#
```
#### 檢視安裝卷冊的索引狀態

檢視產生指令的 Shell Script
```shell
more bin/NoIndex-mdutil-s
```
```shell
:
[ -z "$1" ] && exit

df | grep "$1[^0-9]" | sort | while read x1 x2 x3 x4 x5 x6 x7 x8 x9
do
        m="$x9"
        echo mdutil -s \"$m\"
done
```

檢視將執行的指令
```shell
bin/NoIndex-mdutil-s disk2
```
```shell
mdutil -s "/Volumes/Install macOS High Sierra"
mdutil -s "/Volumes/Install macOS Mojave"
mdutil -s "/Volumes/Install macOS Catalina"
mdutil -s "/Volumes/Install macOS Big Sur"
mdutil -s "/Volumes/Install macOS Monterey"
mdutil -s "/Volumes/Install macOS Ventura"
mdutil -s "/Volumes/Pod"
```

執行指令
```shell
bin/NoIndex-mdutil-s disk2 | sh -x
```
```text
+ mdutil -s '/Volumes/Install macOS High Sierra'
/System/Volumes/Data/Volumes/Install macOS High Sierra:
	Indexing and searching disabled.
+ mdutil -s '/Volumes/Install macOS Mojave'
/System/Volumes/Data/Volumes/Install macOS Mojave:
	Indexing and searching disabled.
+ mdutil -s '/Volumes/Install macOS Catalina'
/System/Volumes/Data/Volumes/Install macOS Catalina:
	Indexing and searching disabled.
+ mdutil -s '/Volumes/Install macOS Big Sur'
/System/Volumes/Data/Volumes/Install macOS Big Sur:
	Indexing and searching disabled.
+ mdutil -s '/Volumes/Install macOS Monterey'
/System/Volumes/Data/Volumes/Install macOS Monterey:
	Indexing and searching disabled.
+ mdutil -s '/Volumes/Install macOS Ventura'
/System/Volumes/Data/Volumes/Install macOS Ventura:
	Indexing and searching disabled.
+ mdutil -s /Volumes/Pod
/System/Volumes/Data/Volumes/Pod:
	Indexing and searching disabled.
```

![All in ONE Done](All%20in%20ONE%20macOS%20Installer-Done.png "All in ONE Done")

### 進行安裝

將安裝姆指碟接上電腦，壓住 option 鍵，然後按一下電源鍵。若您可以順利看到如下那就讚啦！👍

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

## 深入解析

附註：其他說明後續補上。

### bin/HuntForVolumeLockers

### bin/MakeMacOSInstallers

### bin/MountUSBVolumes

### bin/NoIndex-mdutil-d-E

### bin/NoIndex-mdutil-s

### bin/NoIndex-touch

### bin/PartitionUSBFlashDrive

### bin/RenameUSBVolumes

此一 Shell Script 用來將姆指碟上的所有卷冊更名回剛分割後的名稱，如此不用重新分割就可以重新製作各版本的 macOS 安裝卷冊。nl 指令用於將輸入的分割區配置資料加上行號，透過行號來配合切片(slice)的編號，藉此對應到正確的裝置檔案。關於 nl 的參數，可以透過 man nl 指令了解其意義。

檢視產生指令的 Shell Script

```shell
more bin/RenameUSBVolumes
```

```shell
:
[ -z "$2" ] && exit

list=`cat $2`

XFS=$IFS
IFS=","
echo "$list" | nl -s, -v 2 -ba -n ln -w 1 | while read n v s
do
        l=`echo $v | tr ' ' '_'`
        echo diskutil rename \"$1s$n\" \"$l\"
done
IFS=$XFS
```

檢視將執行的指令

```shell
bin/RenameUSBVolumes disk2 etc/USBPartitionTable.txt
```
```shell
diskutil rename "disk2s2" "High_Sierra"
diskutil rename "disk2s3" "Mojave"
diskutil rename "disk2s4" "Catalina"
diskutil rename "disk2s5" "Big_Sur"
diskutil rename "disk2s6" "Monterey"
diskutil rename "disk2s7" "Ventura"
diskutil rename "disk2s8" "Pod"
```

執行指令

```shell
bin/RenameUSBVolumes disk2 etc/USBPartitionTable.txt | sh -x
```
```text
+ diskutil rename disk2s2 High_Sierra
Volume on disk2s2 renamed to High_Sierra
+ diskutil rename disk2s3 Mojave
Volume on disk2s3 renamed to Mojave
+ diskutil rename disk2s4 Catalina
Volume on disk2s4 renamed to Catalina
+ diskutil rename disk2s5 Big_Sur
Volume on disk2s5 renamed to Big_Sur
+ diskutil rename disk2s6 Monterey
Volume on disk2s6 renamed to Monterey
+ diskutil rename disk2s7 Ventura
Volume on disk2s7 renamed to Ventura
+ diskutil rename disk2s8 Pod
Volume on disk2s8 renamed to Pod
```

## 參考資料

### 文件目標

[開機組合鍵 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/102603)
[如果 Mac 沒有順暢地完成啟動 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/HT204156)
[Fix MacBook Error 5101F With This Quick Guide - AppleToolBox](https://appletoolbox.com/fix-macbook-error-5101f/)
[GitHub - MuertoGB/MacBRTool: 💻 MacBRTool is used to update Mac BootROM firmware in EFI mode, adding APFS support.](https://github.com/MuertoGB/MacBRTool)
[How to create a macOS 13 Ventura installer on a USB drive](https://www.idownloadblog.com/2022/06/10/how-to-create-bootable-usb-installer-macos-ventura/)

### 準備工作
[MacOS Sierra: Enable/Disable Spotlight Indexing - Technipages](https://www.technipages.com/macos-sierra-enable-disable-spotlight/)
[macos - Preventing Spotlight from Indexing Files & Folders? - Ask Different](https://apple.stackexchange.com/questions/92784/preventing-spotlight-from-indexing-files-folders)

### 其他資料

[Apple Regulatory Information](https://regulatoryinfo.apple.com/tw/rfexposure)
[macOS version history - Wikipedia](https://en.wikipedia.org/wiki/MacOS_version_history)
[辨識 MacBook Pro 機型 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/HT201300)
[Mac OS Compatibility Guide by Mac Model](https://eshop.macsales.com/guides/Mac_OS_X_Compatibility)
[How to find out macOS version using terminal command - nixCraft](https://www.cyberciti.biz/faq/mac-osx-find-tell-operating-system-version-from-bash-prompt/)
[若無法在外接顯示器上看見 Mac 桌面 - Apple 支援 (台灣)](https://support.apple.com/zh-tw/guide/mac-help/mchlp2615/10.13/mac/10.13)
