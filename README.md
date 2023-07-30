# TDWorkspaceONE

## TDWorkspaceONEAPIs.jl - 為工程師寫的 Julia 程式

提供 Workspace ONE RESTful API 應用範例，使用 Julia + Pluto + PlutoUI 做為快速雛形開發工具的程式範例。

```
Rice Li 說：
有了現成的範例後，希望這可以是「工程師」也會用的開發工具！👌
```

也期盼藉此推廣 Julia 的應用，並與網路上的朋友們一起交流分享，再請透過新增「[Issues](https://github.com/RiceZeeLi/TDWorkspaceONE/issues)」的方式回饋交流。

請透過 Pluto 開啟 TDWorkspaceONE.jl 來使用程式範例。關於 Julia 及 Pluto 的安裝再請參考如下的簡要說明或網路資源。

### 安裝 Julia 及 Pluto.jl (以 macOS 為例)
Shell 的部份
``` shell
brew install juliaup
juliaup help
juliaup status
juliaup add +lts
julia
```
Julia 的部份
``` julia
]
add Pluto, PlutoUI, Base64, Dates, HTTP, JSON3, JSONTables, DataFrames, XLSX
status
[← Backspace]
using Pluto
Pluto.run()
```

## Troubleshooting Workspace ONE issues - 為工程師寫的問題查找技巧

如下文章盼藉此推廣 Workspace ONE 的應用，並與網路上的朋友們一起交流分享，再請透過新增「[Issues](https://github.com/RiceZeeLi/TDWorkspaceONE/issues)」的方式回饋交流。

- [[技巧] 在 Android 平台上排除與 Workspace ONE 有關的問題](TroubleshootingWorkspaceONEOnAndroid.md)
- [[技巧] 在 iOS 平台上排除與 Workspace ONE 有關的問題](TroubleshootingWorkspaceONEOniOS.md)
- [[技巧] 在 macOS 平台上排除與 Workspace ONE 有關的問題](TroubleshootingWorkspaceONEOnmacOS.md)
- [[技巧] 在 Windows 平台上排除與 Workspace ONE 有關的問題](TroubleshootingWorkspaceONEOnWindows.md)
- [[技巧] 在 Linux 平台上排除與 Workspace ONE 有關的問題](TroubleshootingWorkspaceONEOnLinux.md)
