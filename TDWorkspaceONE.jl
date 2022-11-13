### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 0bb3be4d-ffa1-4958-a482-a3109e3b72e5
begin
	using PlutoUI
	using Base64
	using Dates
	using HTTP
	using JSON3
	using JSONTables
	using DataFrames
	using XLSX
end;

# ╔═╡ 9afd7578-61e9-11ed-3be5-e32eb35c953d
md"""
# Workspace ONE RESTful API 應用範例
使用 Julia + Pluto + PlutoUI 做為快速雛形開發工具的程式範例
```
Rice Li 說：
天啊！有了現成的範例後，這真的就是「工程師」也會用的開發工具吔！
```
"""

# ╔═╡ 2a093f7b-feaa-4620-b9cf-dd6a9a2a41ba
TableOfContents(title = "內容大綱", depth = 4)

# ╔═╡ 51175407-f3f7-4dc5-9844-e207d84e8a17
Resource("https://julialang.org/assets/infra/logo.svg", :width => 400)

# ╔═╡ d6853197-ee2e-4ab9-bb55-de0909d3bde6
md"# 範例程式"

# ╔═╡ 9bc4054a-f0d0-40f6-9260-881bfebb6cce
md"教學使用? $(@bind isForTraning CheckBox(default = false))"

# ╔═╡ a5e8383f-8a37-468a-b20e-9dff88d5231a
md"## 連線準備"

# ╔═╡ bb662f53-0b39-41e5-8e63-f193317df883
md"### 引用套件"

# ╔═╡ bc54c11d-18df-4e04-a078-16304fd14c4a
md"### 填入參數"

# ╔═╡ f2490bce-820c-40d7-97d4-187fa29a8d49
md"""
請填入連接 Workspace ONE API 伺服器所需資訊： $br
Site#: $(@bind site TextField(default = "138")) $br
Username: $(@bind username TextField(default = "")) $br
Password: $(@bind password PasswordField(default = "")) $br
Tenant Code: $(@bind code PasswordField(default = ""))
"""

# ╔═╡ 78c94534-c233-4786-9bf6-545b8411635b
begin
	rsPath = isForTraning ? "./Private/Resources" : "./Resources"
	csURL = "https://cn$site.awmdm.com"
	asURL = "https://as$site.awmdm.com"
	token = base64encode("$username:$password")
	function ln(text, link)
		string="md\"[$text]($link)\""
		return(eval(Meta.parse(string)))
	end
	("Site#" => site, "csURL" => csURL, "asURL" => asURL, "username" => username)
end

# ╔═╡ a3304bb2-f890-4b69-9320-18b64d626dd2
md"""
### 測試連線 (CN$site)
- $(ln("Workspace ONE UEM Console", csURL))
- $(ln("Workspace ONE UEM API Explorer", asURL*"/api/help/#!/apis"))
"""

# ╔═╡ 085b10a5-1596-40a0-a705-d1088ca4e621
md"""
功能項目： $(@bind apiPath Select([
"/api/mdm/devices/litesearch" => "/api/mdm/devices/litesearch (搜尋裝置)",
"/api/mdm/devices?searchby=SerialNumber&id=就是會找不到" => "/api/mdm/devices?searchby=SerialNumber&id=QQ (不用再給參數，就是會找不到)",
"/api/mdm/devices" => "/api/mdm/devices (要給參數)"
])) $br
其他參數： (請用 Parameter=Value 格式分成不同行輸入，程式會自動以「&」符號合併) $br $(@bind query TextField((57,5), default = "")) $br
"""

# ╔═╡ 55ba9af8-122a-4649-904f-585bda70776c
md"執行測試? $(@bind runTest CheckBox())"

# ╔═╡ 9949af3e-a30d-4516-b32c-12d959be31ea
md"### 定義函數"

# ╔═╡ 3aa127ab-ad64-49bc-994e-5e3dc2f5f7e7
begin
	function setURL(baseURL, apiPath, query)
		q = join(split(query, "\n"), "&")
		return (length(q) > 0) ? (baseURL * apiPath * "?" * q) : (baseURL * apiPath)
	end
	
	function setHeaders(token, code)
	    return (
	        ("Authorization", "Basic $token"),
			("aw-tenant-code", "$code"),
	        ("Accept", "application/json"),
	        ("Content-Type", "application/json"),
	    )
	end

	function makeAPICall(url, headers)
	    try
	        response = HTTP.get(url, headers)
	        return response.status, String(response.body)
	    catch e
	        return -1, "$e"
	    end
	end

	headers = setHeaders(token, code)
	url = setURL(asURL, apiPath, query)
	
	md"定義 setHeaders(), makeAPICall() 及設定 url 及 headers"
end

# ╔═╡ e7a28bef-e18d-40f7-a8d8-38e2d87b7171
md"### 執行結果"

# ╔═╡ 5efae899-77de-40a1-a6bb-4329b80702ab
begin
	if runTest
		status, body = makeAPICall(url, headers)
	else
		status, body = -1, ""
	end;
	with_terminal() do
		println("status: $status")
		if status ≠ -1
			print("body: ")
			JSON3.pretty(JSON3.read(body))
		else
			println("body: $body")
		end
	end
end

# ╔═╡ 29cf395d-b1fe-4379-b1df-c1aef99a1a80
md"## 範例一、讀取資料並存入試算表"

# ╔═╡ 2fcaa116-9f3b-4e61-9c17-4dbadfe25d5d
LocalResource("$rsPath/Banner-01.png", :height => 80)

# ╔═╡ 5f15aa65-5cd9-45e4-82b3-4d53096f465a
md"""
### 填入參數
功能項目: $(@bind case01 Select([
"/api/mdm/devices/litesearch" => "/api/mdm/devices/litesearch"
])) $br
輸出檔名: $(@bind case01OutputFile TextField((50, 1); default = "TDWorkspaceONE-Case01Output.xlsx")) $br
"""

# ╔═╡ 0ae787f5-a7ad-4ac3-9526-f9c990a3ad1c
md"執行功能項目? $(@bind runCase01 CheckBox())"

# ╔═╡ 210e476f-9a76-46a6-9276-0e3caf5ddaa2
md"### 定義函數"

# ╔═╡ 51ccf417-946f-4c53-abae-9ecc3a2d30ea
begin
	# XLSX Supported Types are Union{Missing, Bool, Float64, Int64, Dates.Date, Dates.DateTime, Dates.Time, String} 
	function isXSLXSupported(type)
		type in [Missing, Bool, Float64, Int64, Dates.Date, Dates.DateTime, Dates.Time, String]
	end
	md"定義 isXSLXSupported()"
end

# ╔═╡ 5ac612cd-83a5-4eb5-8d77-a90becabb55a
md"### 讀取資料"

# ╔═╡ b446c9eb-e517-4803-a5cb-db14cdc27620
begin
	if runCase01
		case01Url = asURL * case01
		case01Status, case01Body = makeAPICall(case01Url, headers)
	else
		case01Status, case01Body = -1, "{}"
	end
	data01 = JSON3.read(case01Body)
	if "Devices" in keys(data01)
		table01 = jsontable(data01["Devices"])
		df01 = DataFrame(table01)
	end
end

# ╔═╡ 751c735f-aa4b-416a-8637-3e32639a9394
md"### 處理資料"

# ╔═╡ 315d90ec-2acd-4fe6-ae62-75a44b4020a6
begin
	#= 刪去 XSLX 套件不支手援的欄
	isXSLXSupported.(eltype.(eachcol(df))) # 測試是否有被支援
	select!(df, Not([:DeviceNetworkInfo, :CustomAttributes])); # 以指定欄名的方式，無法通用
	=#
	df01Excel = select(df01, isXSLXSupported.(eltype.(eachcol(df01))));
end

# ╔═╡ 24c6999a-7b3c-499b-aa23-eb89f364e247
md"### 輸出資料(寫入試算表)"

# ╔═╡ db55ef9c-76d6-459f-bb30-8d9bbf3021c9
with_terminal() do
	case01Output = expanduser("~/tmp/$case01OutputFile")
	rm(case01Output, force = true)
	XLSX.writetable(case01Output, collect(eachcol(df01Excel)), names(df01Excel))
	println("已輸出到 $case01Output")
end

# ╔═╡ d7daea03-3e49-4f54-a7ed-e8a3e73b2460
md"## 範例二、依試算表查詢資料"

# ╔═╡ 07c453d8-5973-4618-94da-3818542b2dc7
LocalResource("$rsPath/Banner-02.png", :height => 80)

# ╔═╡ 11193569-9af9-4cbb-8313-b428118e4d9d
md"""
### 填入參數
功能項目: $(@bind case02 Select([
"/api/mdm/devices/litesearch" => "/api/mdm/devices/litesearch"
])) $br
輸入檔名: $(@bind case02InputFile TextField((50, 1); default = "TDWorkspaceONE-Case02Input.xlsx")) $br
輸出檔名: $(@bind case02OutputFile TextField((50, 1); default = "TDWorkspaceONE-Case02Output.xlsx"))
"""

# ╔═╡ 48929f71-047e-46ee-89b3-b1413f95fcc6
md"執行功能項目? $(@bind runCase02 CheckBox())"

# ╔═╡ 19231aaf-7c08-4275-9176-921d15e46982
md"### 定義函數"

# ╔═╡ de4caf52-09ad-40c8-9be7-c0f404779598
begin
	md"定義 "
end

# ╔═╡ d70c8e75-3ad2-48e4-b25d-0e7ed9e052c7
md"### 讀取資料"

# ╔═╡ b9940643-7759-40a0-8d74-4e2a38409b43


# ╔═╡ 6a4d19fa-204d-42e6-969c-f69beea8df36
md"### 處理資料"

# ╔═╡ 014d4977-5dff-457e-ada8-18502ad8c9c1


# ╔═╡ 99938645-2346-4962-b287-1a9ac47b631d
md"## 範例三、依試算表更新資料"

# ╔═╡ 13704898-ba73-4505-9954-93c3e2c0cf92
LocalResource("$rsPath/Banner-03.png", :height => 80)

# ╔═╡ 53355cb0-0293-49e8-8450-869fa269225d
md"""
### 填入參數
功能項目: $(@bind case03 Select([
"/api/mdm/devices/litesearch" => "/api/mdm/devices/litesearch"
])) $br
輸入檔名: $(@bind case03InputFile TextField((50, 1); default = "TDWorkspaceONE-Case03Input.xlsx")) $br
輸出檔名: $(@bind case03OutputFile TextField((50, 1); default = "TDWorkspaceONE-Case03Output.xlsx"))
"""

# ╔═╡ 1a464fd6-c2c0-4cd3-a363-f84f8dcc997c
md"執行功能項目? $(@bind runCase03 CheckBox())"

# ╔═╡ 2b731f3a-d345-4c26-8b7f-ec1f80f7c070
md"### 定義函數"

# ╔═╡ b768650e-2338-43f7-83c6-9343a79afe15
begin
	md"定義 "
end

# ╔═╡ f05c2758-df02-4e89-be91-3f00f4f55472
md"### 讀取資料"

# ╔═╡ 2f0a9927-76af-42e8-92ac-191550656a55


# ╔═╡ df7c921f-4cef-4246-94a9-5b1532cb0eed
md"### 處理資料"

# ╔═╡ 2dc7b708-7c97-4676-803d-8f0c4dd0eade


# ╔═╡ 66773ae8-6e8c-4949-9082-a19463215051
md"""
# 語法範例
提供前面程式所用到元件的補充範例
"""

# ╔═╡ 2b62de3a-8d99-4e44-b8fe-aff11b39a3b1
md"""
PlutoUI 為以下「輸入類型」提供了方便使用的 「Julia 物件」，如下範例分別將五個不同的輸入類型綁定到 a, b, c, d, e 五個變數。\$ 符號用來執行表達式並將結果轉為字串。

a: $(@bind a Slider(1:9))
b: $(@bind b TextField())
c: $(@bind c Button("🎈"))
d: $(@bind d CheckBox())
e: $(@bind e Select(["first" => "👍", "second" => "✌️" ]))

範例來源：
1. 套件來源：[JuliaPluto/PlutoUI.jl](https://github.com/JuliaPluto/PlutoUI.jl)
1. 套件說明：[Readme · PlutoUI.jl](https://docs.juliahub.com/PlutoUI/abXFp/0.7.48/)
1. 詳細範例：[https://juliapluto.github.io/sample-notebook-previews/PlutoUI.jl.html](https://juliapluto.github.io/sample-notebook-previews/PlutoUI.jl.html)
"""

# ╔═╡ f6084608-91db-4a3f-b124-e03a6adb4df0
md"以元組(Tuple)的方式顯示取得的值"

# ╔═╡ 2c4d8b69-35c0-46f7-be15-46deff26238c
(a, b, c, d, e)

# ╔═╡ 4ff585eb-f729-4897-a184-ae17839ca133
md"獨立使用 @bind 的範例"

# ╔═╡ bbdcd891-3cab-43dc-a29a-a5000f96f0a0
@bind f MultiSelect(["potato", "carrot", "boerenkool"])

# ╔═╡ 89e69050-98e6-43d6-9d77-c8391c7f4e27
f

# ╔═╡ 22865dbe-2d84-4aea-a481-453645e5468b
md"# 環境準備"

# ╔═╡ 3ce1746d-9a62-4db4-ba9e-25c03ed89be0
md"""
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
"""

# ╔═╡ 0b25141b-63bc-4b9a-9b4f-d347ceb3f48a
md"""
## 了解 Workspace ONE UEM API
1. VMware TestDrive - [Workspace ONE UEM API Explorer](https://testdrive.awmdm.com/api/help/#!/apis)
1. VMware Workspace ONE - [Code Samples and PowerCLI Example Scripts | VMware - VMware {code}](https://developer.vmware.com/samples?categories=Sample&keywords=Workspace%20ONE&tags=&groups=&filters=&sort=&page=1)
"""

# ╔═╡ 68a3a478-35b6-4f14-a342-a49e110a2a23
md"""
# 參考資料
提供前面程式相關的參考資料，內容區分為 Workspace ONE、eSIM 及 Julia 幾個部份

## Workspace ONE
1. [Let’s Git Commit(ted) to Resources: Getting Started with the Workspace ONE UEM REST APIs | VMware](https://techzone.vmware.com/blog/lets-git-committed-resources-getting-started-workspace-one-uem-rest-apis)
1. [將 UEM 功能與 REST API 搭配使用](https://docs.vmware.com/tw/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-BF20C949-5065-4DCF-889D-1E0151016B5A.html)
1. [Getting Started with Workspace ONE Intelligence APIs: Workspace ONE Operational Tutorial | VMware](https://techzone.vmware.com/getting-started-workspace-one-intelligence-apis-workspace-one-operational-tutorial#introduction-b)
1. [Use API server URL for Workspace ONE UEM REST API calls (82724)](https://kb.vmware.com/s/article/82724)
1. [Workspace ONE UEM API Explorer (as1174)](https://as1174.awmdm.com/api/help/#!/apis)

## eSIM

1. [Simplifying eSIM Cellular Plan Activation with Workspace ONE UEM - Samples - VMware {code}](https://developer.vmware.com/samples/7423/simplifying-esim-cellular-plan-activation-with-workspace-one-uem?h=Workspace%20ONE)

## Julia
1. [How To Make REST API Calls In Julia | CodeHandbook](https://codehandbook.org/make-rest-api-calls-julia/)
1. [PlutoUI.jl](https://docs.juliahub.com/PlutoUI/abXFp/0.7.22/)
1. [JSON3.jl](https://quinnj.github.io/JSON3.jl/stable/)
1. [HTTP.jl](https://juliaweb.github.io/HTTP.jl/stable/)
1. [Julia Taiwan | Facebook](https://www.facebook.com/groups/JuliaTaiwan)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Base64 = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
JSONTables = "b9914132-a727-11e9-1322-f18e41205b0b"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
DataFrames = "~1.4.2"
HTTP = "~1.5.3"
JSON3 = "~1.11.1"
JSONTables = "~1.0.3"
PlutoUI = "~0.7.48"
XLSX = "~0.8.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "629c6e4a7be8f427d268cebef2a5e3de6c50d462"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.6"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5b93f1b47eec9b7194814e40542752418546679f"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "8c7e6b82abd41364b8ffe40ffc63b33e590c8722"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.3"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "SnoopPrecompile", "StructTypes", "UUIDs"]
git-tree-sha1 = "65edf3850efb9cb4ca3b0bf488e29c6c38a23d2d"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.11.1"

[[deps.JSONTables]]
deps = ["JSON3", "StructTypes", "Tables"]
git-tree-sha1 = "13f7485bb0b4438bb5e83e62fcadc65c5de1d1bb"
uuid = "b9914132-a727-11e9-1322-f18e41205b0b"
version = "1.0.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "5628f092c6186a80484bfefdf89ff64efdaec552"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "98ac42c9127667c2731072464fcfef9b819ce2fa"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.XLSX]]
deps = ["Artifacts", "Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "ccd1adf7d0b22f762e1058a8d73677e7bd2a7274"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.8.4"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "ef4f23ffde3ee95114b461dc667ea4e6906874b2"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─9afd7578-61e9-11ed-3be5-e32eb35c953d
# ╟─2a093f7b-feaa-4620-b9cf-dd6a9a2a41ba
# ╟─51175407-f3f7-4dc5-9844-e207d84e8a17
# ╟─d6853197-ee2e-4ab9-bb55-de0909d3bde6
# ╟─9bc4054a-f0d0-40f6-9260-881bfebb6cce
# ╟─a5e8383f-8a37-468a-b20e-9dff88d5231a
# ╟─bb662f53-0b39-41e5-8e63-f193317df883
# ╠═0bb3be4d-ffa1-4958-a482-a3109e3b72e5
# ╠═bc54c11d-18df-4e04-a078-16304fd14c4a
# ╟─f2490bce-820c-40d7-97d4-187fa29a8d49
# ╟─78c94534-c233-4786-9bf6-545b8411635b
# ╟─a3304bb2-f890-4b69-9320-18b64d626dd2
# ╠═085b10a5-1596-40a0-a705-d1088ca4e621
# ╟─55ba9af8-122a-4649-904f-585bda70776c
# ╟─9949af3e-a30d-4516-b32c-12d959be31ea
# ╟─3aa127ab-ad64-49bc-994e-5e3dc2f5f7e7
# ╟─e7a28bef-e18d-40f7-a8d8-38e2d87b7171
# ╟─5efae899-77de-40a1-a6bb-4329b80702ab
# ╟─29cf395d-b1fe-4379-b1df-c1aef99a1a80
# ╟─2fcaa116-9f3b-4e61-9c17-4dbadfe25d5d
# ╠═5f15aa65-5cd9-45e4-82b3-4d53096f465a
# ╠═0ae787f5-a7ad-4ac3-9526-f9c990a3ad1c
# ╟─210e476f-9a76-46a6-9276-0e3caf5ddaa2
# ╠═51ccf417-946f-4c53-abae-9ecc3a2d30ea
# ╟─5ac612cd-83a5-4eb5-8d77-a90becabb55a
# ╠═b446c9eb-e517-4803-a5cb-db14cdc27620
# ╟─751c735f-aa4b-416a-8637-3e32639a9394
# ╠═315d90ec-2acd-4fe6-ae62-75a44b4020a6
# ╟─24c6999a-7b3c-499b-aa23-eb89f364e247
# ╠═db55ef9c-76d6-459f-bb30-8d9bbf3021c9
# ╟─d7daea03-3e49-4f54-a7ed-e8a3e73b2460
# ╟─07c453d8-5973-4618-94da-3818542b2dc7
# ╟─11193569-9af9-4cbb-8313-b428118e4d9d
# ╟─48929f71-047e-46ee-89b3-b1413f95fcc6
# ╠═19231aaf-7c08-4275-9176-921d15e46982
# ╠═de4caf52-09ad-40c8-9be7-c0f404779598
# ╟─d70c8e75-3ad2-48e4-b25d-0e7ed9e052c7
# ╠═b9940643-7759-40a0-8d74-4e2a38409b43
# ╟─6a4d19fa-204d-42e6-969c-f69beea8df36
# ╠═014d4977-5dff-457e-ada8-18502ad8c9c1
# ╟─99938645-2346-4962-b287-1a9ac47b631d
# ╟─13704898-ba73-4505-9954-93c3e2c0cf92
# ╟─53355cb0-0293-49e8-8450-869fa269225d
# ╟─1a464fd6-c2c0-4cd3-a363-f84f8dcc997c
# ╟─2b731f3a-d345-4c26-8b7f-ec1f80f7c070
# ╠═b768650e-2338-43f7-83c6-9343a79afe15
# ╟─f05c2758-df02-4e89-be91-3f00f4f55472
# ╠═2f0a9927-76af-42e8-92ac-191550656a55
# ╟─df7c921f-4cef-4246-94a9-5b1532cb0eed
# ╠═2dc7b708-7c97-4676-803d-8f0c4dd0eade
# ╟─66773ae8-6e8c-4949-9082-a19463215051
# ╠═2b62de3a-8d99-4e44-b8fe-aff11b39a3b1
# ╠═f6084608-91db-4a3f-b124-e03a6adb4df0
# ╠═2c4d8b69-35c0-46f7-be15-46deff26238c
# ╠═4ff585eb-f729-4897-a184-ae17839ca133
# ╠═bbdcd891-3cab-43dc-a29a-a5000f96f0a0
# ╠═89e69050-98e6-43d6-9d77-c8391c7f4e27
# ╟─22865dbe-2d84-4aea-a481-453645e5468b
# ╟─3ce1746d-9a62-4db4-ba9e-25c03ed89be0
# ╟─0b25141b-63bc-4b9a-9b4f-d347ceb3f48a
# ╟─68a3a478-35b6-4f14-a342-a49e110a2a23
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
