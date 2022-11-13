# TDWorkspaceONE

提供 Workspace ONE RESTful API 應用範例，使用 Julia + Pluto + PlutoUI 做為快速雛形開發工具的程式範例。

```
Rice Li 說：
天啊！有了現成的範例後，這真的就是「工程師」也會用的開發工具吔！
```

也期盼藉此推廣 Julia 的應用，並與網路上的朋友們一起交流分享，再請透過新增「issues」的方式回饋交流。

請透過 Pluto 開啟 TDWorkspaceONE.jl 來使用程式範例。關於 Julia 及 Pluto 的安裝再請參考如下的簡要說明或網路資源。

## 安裝 Julia 及 Pluto.jl (以 macOS 為例)
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
