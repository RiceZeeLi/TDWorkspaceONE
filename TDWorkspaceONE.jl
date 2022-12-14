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

# âââ¡ 0bb3be4d-ffa1-4958-a482-a3109e3b72e5
begin
	using PlutoUI # ð Live docs
	using Base64
	using Dates
	using HTTP
	using JSON3
	using JSONTables
	using DataFrames
	using XLSX
	using Pipe
end;

# âââ¡ 9afd7578-61e9-11ed-3be5-e32eb35c953d
md"""
# Workspace ONE RESTful API æç¨ç¯ä¾
ä½¿ç¨ Julia + Pluto + PlutoUI åçºå¿«ééå½¢éç¼å·¥å·çç¨å¼ç¯ä¾
```
Rice Li èªªï¼ð
æäºç¾æçç¯ä¾å¾ï¼å¸æéå¯ä»¥æ¯ãå·¥ç¨å¸«ãä¹æç¨çéç¼å·¥å·ï¼ð
```
"""

# âââ¡ 9bc4054a-f0d0-40f6-9260-881bfebb6cce
md"æå­¸ç¤ºç¯? $(@bind isForTraining CheckBox(default = false)) ð ååæ¨¡å¼"

# âââ¡ 713a287f-98b8-461d-8c95-8493c9796971
if isForTraining 
	md"""
# æå­¸æè¦
1. éãä¸é ãæåä¾èªªãç¨å¼ãï¼One Page Aheadã
1. èªªæå·²ç¶æ Postman, API Explorerï¼çºä»éº¼éè¦ä»ç´¹ä»å¤©çå§å®¹ï¼
1. ç°¡ä» Juliaï¼ä¸¦èªªæãè¡¨ç¤ºå¼ï¼Expressionï¼ããä»¥æ­£ç¢ºçãè¡¨éï¼è¡¨ç¤ºãè« Julia å¹«å¿ã
1. ç°¡ä» Pluto & PlutoUIï¼ä¸¦èªªæ (å¥çæ/Pluto, æ¨æ/Jupiter)$br Jupyter notebook $br Markdown, JavaScript, HTML, $br Interactive Programming Environment $br Meta Programming
1. èªªæ VMware Workspace ONE çæç¨éæ±èç¯ä¾ä¸­çéä¿
1. èªªæä½¿ç¨ Ubuntu åçºç´ç®¡è¨­åçåå 
1. èªªææç¨å¨ VMware Horizon çå¯è½æ§
1. èªªæå°ä»¥ Genie.jl ð§ çµå°¾ 
1. ä¸èµ·æ¾ãðãæåé¡è«é¨æææ·ï¼æå¨ç·ä¸èå¤©å®¤ç¼è¨æ¯ã
	Julia solves the two language problem by combining the ease of use of Python and R with the speed of C++.
	
	Jupyter - the three core programming languages supported by Jupyter, which are Julia, Python and R
"""
end

# âââ¡ 2a093f7b-feaa-4620-b9cf-dd6a9a2a41ba
(println("ð"); true) && if isForTraining 
	TableOfContents(title = "å§å®¹å¤§ç¶±", depth = 2)
else
	TableOfContents(title = "å§å®¹å¤§ç¶±", depth = 3)
end

# âââ¡ 51175407-f3f7-4dc5-9844-e207d84e8a17
Resource("https://julialang.org/assets/infra/logo.svg", :width => 400)

# âââ¡ d6853197-ee2e-4ab9-bb55-de0909d3bde6
md"# ç¯ä¾ç¨å¼"

# âââ¡ a5e8383f-8a37-468a-b20e-9dff88d5231a
md"## ç°å¢æºå"

# âââ¡ bb662f53-0b39-41e5-8e63-f193317df883
md"### å¼ç¨å¥ä»¶"

# âââ¡ d47d861f-c69a-4352-a3a5-8c8456a1e301
md"## åºæ¬æ¸¬è©¦"

# âââ¡ bc54c11d-18df-4e04-a078-16304fd14c4a
md"### å¡«å¥åæ¸"

# âââ¡ f2490bce-820c-40d7-97d4-187fa29a8d49
md"""
è«å¡«å¥é£æ¥ Workspace ONE API ä¼ºæå¨æéè³è¨ï¼ $br
ä¸»æ©ï¼CN $(@bind site TextField(default = "1768")) $br
å¸³èï¼ $(@bind username TextField(default = "")) $br
å¯ç¢¼ï¼ $(@bind password PasswordField(default = "")) $br
ç§æ¶ä»£ç¢¼ï¼ $(@bind codeText PasswordField(default = "")) æç±
$(@bind codeFile Select([
	"./Training/TenantCode-02.txt" => "./Training/TenantCode-02.txt",
	"./Training/TenantCode-01.txt" => "./Training/TenantCode-01.txt"
])) è®å
"""

# âââ¡ 78c94534-c233-4786-9bf6-545b8411635b
begin
	rsPath = isForTraining ? "./Training/Resources" : "./Resources"
	csURL = "https://cn$site.awmdm.com"
	asURL = "https://as$site.awmdm.com"
	token = base64encode("$username:$password")
	code = isempty(codeText) ? open(codeFile) do f return s = strip(join(readlines(f))) end : codeText
	("Site#" => site, "csURL" => csURL, "asURL" => asURL, "username" => username)
end

# âââ¡ 9949af3e-a30d-4516-b32c-12d959be31ea
md"### å®ç¾©å½æ¸"

# âââ¡ 3aa127ab-ad64-49bc-994e-5e3dc2f5f7e7
( # ð tuple of functions, (f1, f2, f3)
		function ln(text, link)
		string="md\"[$text]($link)\""
		return(eval(Meta.parse(string)))
		end,

	function setURL(baseURL, apiPath, parameters)
		q = join(split(strip(parameters), "\n"), "&")
		# ð ? : expression
		return (length(q) > 0) ? (baseURL * apiPath * "?" * q) : (baseURL * apiPath)
	end,
	
	function setHeaders(token, code)
	    return (
	        ("Authorization", "Basic $token"),
			("aw-tenant-code", "$code"),
	        ("Accept", "application/json"),
	        ("Content-Type", "application/json"),
	    )
	end,

	function makeAPICall(method, url, headers)
	    try
	        response = method(url, headers)
	        return response.status, String(response.body) # ð multiple return values 
	    catch e
	        return -1, "$e"
	    end
	end,
) 

# âââ¡ a3304bb2-f890-4b69-9320-18b64d626dd2
md"""
### æ¸¬è©¦é£ç· (CN$site)
- $(ln("Workspace ONE UEM Console", csURL))
- $(ln("Workspace ONE UEM API Explorer", asURL*"/api/help/#!/apis"))
"""

# âââ¡ 085b10a5-1596-40a0-a705-d1088ca4e621
md"""
åè½é ç®ï¼ $(@bind apiPath00 Select([
"/api/mdm/devices/litesearch" => "/api/mdm/devices/litesearch (æå°è£ç½®)",
"/api/mdm/devices?searchby=SerialNumber&id=å°±æ¯ææ¾ä¸å°" => "/api/mdm/devices?searchby=SerialNumber&id=QQ (ä¸ç¨åçµ¦åæ¸ï¼å°±æ¯ææ¾ä¸å°)",
"/api/mdm/devices" => "/api/mdm/devices (è¦çµ¦åæ¸)"
])) $br
å¶ä»åæ¸ï¼ (è«ç¨ Parameter=Value æ ¼å¼åæä¸åè¡è¼¸å¥ï¼ç¨å¼æèªåä»¥ã&ãç¬¦èåä½µ) $br $(@bind parameters00 TextField((57,5), default = "")) $br
"""

# âââ¡ 55ba9af8-122a-4649-904f-585bda70776c
md"æ¨¡æ¬æ¸¬è©¦? $(@bind dryRun00 CheckBox(default = true)) å·è¡æ¸¬è©¦? $(@bind runTest CheckBox())"

# âââ¡ e7a28bef-e18d-40f7-a8d8-38e2d87b7171
md"### å·è¡çµæ"

# âââ¡ 5efae899-77de-40a1-a6bb-4329b80702ab
begin
	headers = setHeaders(token, code)
	if runTest
		url = setURL(asURL, apiPath00, parameters00)
		if dryRun00
			println(url)
		else
			status, body = makeAPICall(HTTP.get, url, headers)
			with_terminal() do
				println("status: $status")
				if status â  -1 â  # ð â  \ne <tab><tab> \ge <tab><tab> â¥
					print("body: ")
					JSON3.pretty(JSON3.read(body))
				else
					println("body: $body")
				end
			end	
		end
	end
end

# âââ¡ 29cf395d-b1fe-4379-b1df-c1aef99a1a80
md"## ç¯ä¾ä¸ãè®åè³æä¸¦å­å¥è©¦ç®è¡¨"

# âââ¡ 2fcaa116-9f3b-4e61-9c17-4dbadfe25d5d
LocalResource("$rsPath/Banner-01.png", :height => 80)

# âââ¡ 5f15aa65-5cd9-45e4-82b3-4d53096f465a
md"""
### å¡«å¥åæ¸
åè½é ç®: $(@bind apiPath01 Select([
	"/api/mdm/devices/litesearch" => "/api/mdm/devices/litesearch(è¼éæå°)"
])) $br
å¶ä»åæ¸ï¼ (è«ç¨ Parameter=Value æ ¼å¼åæä¸åè¡è¼¸å¥ï¼ç¨å¼æèªåä»¥ã&ãç¬¦èåä½µ) $br 
$(@bind parameters01 TextField((57,5), default = "")) $br
è¼¸åºæªå: $(@bind outputFile01 TextField((50, 1); default = "TDWorkspaceONE-Output01.xlsx")) $br
"""

# âââ¡ 0ae787f5-a7ad-4ac3-9526-f9c990a3ad1c
md"æ¨¡æ¬æ¸¬è©¦? $(@bind dryRun01 CheckBox(default = true)) å·è¡åè½é ç®? $(@bind runCase01 CheckBox())"

# âââ¡ 210e476f-9a76-46a6-9276-0e3caf5ddaa2
md"### å®ç¾©å½æ¸"

# âââ¡ 51ccf417-946f-4c53-abae-9ecc3a2d30ea
(
	# XLSX å¥ä»¶æ¯æ´çåå¥çº Union{Missing, Bool, Float64, Int64, Dates.Date, Dates.DateTime, Dates.Time, String}
	function isXSLXSupported(type)
		! occursin("Array", "$type") # ð interpolation
	end,
)

# âââ¡ 5ac612cd-83a5-4eb5-8d77-a90becabb55a
md"### è®åè³æ"

# âââ¡ b446c9eb-e517-4803-a5cb-db14cdc27620
if runCase01
	url01 = setURL(asURL, apiPath01, parameters01)
	status01, body01 = makeAPICall(HTTP.get, url01, headers)
	if status01 == 200
		data01 = JSON3.read(body01)
		hasData01 = "Devices" in keys(data01)
		if hasData01
			table01 = jsontable(data01["Devices"])
			df01 = DataFrame(table01)
		end
	else
		hasData01 = false
		print("$status01: ")
		println(replace(body01, r"(?s)\n.*" => s""))
	end
end

# âââ¡ 751c735f-aa4b-416a-8637-3e32639a9394
md"### èçè³æ"

# âââ¡ 14acd856-b638-4b69-a87b-d7c52afd400a
runCase01 && ! dryRun01 && hasData01 && isXSLXSupported.(eltype.(eachcol(df01))) # æ¸¬è©¦æ¯å¦æè¢«æ¯æ´ ð && logical and

# âââ¡ 5219ff79-1b39-49c9-95ae-84f85cc0d113
# å° XSLS å¥ä»¶ä¸æ¯æçæ¬ä½ä»¥ JSON å­ä¸²è¡¨ç¤º
runCase01 && ! dryRun01 && hasData01 && for i in names(df01)
	if ! isXSLXSupported(eltype(df01[!, i]))
		df01[!, "$(i)JSON"] = JSON3.write.(df01[!, i]) # ð JSON3.write Live docs
	end
end

# âââ¡ 1899b982-85e6-44a3-9577-928eabc63b4c
runCase01 && ! dryRun01 && hasData01 && df01

# âââ¡ 315d90ec-2acd-4fe6-ae62-75a44b4020a6
runCase01 && ! dryRun01 && hasData01 &&
begin
	#= åªå» XSLX å¥ä»¶ä¸æ¯ææ´çæ¬
	isXSLXSupported.(eltype.(eachcol(df))) # æ¸¬è©¦æ¯å¦æè¢«æ¯æ´
	select!(df, Not([:DeviceNetworkInfo, :CustomAttributes])); # ä»¥æå®æ¬åçæ¹å¼ï¼ç¡æ³éç¨
	=#
	dfExcel01 = select(df01, isXSLXSupported.(eltype.(eachcol(df01))))
end # èªªæãï¼ã 

# âââ¡ 24c6999a-7b3c-499b-aa23-eb89f364e247
md"### è¼¸åºè³æ(å¯«å¥è©¦ç®è¡¨)"

# âââ¡ db55ef9c-76d6-459f-bb30-8d9bbf3021c9
runCase01 && ! dryRun01 && hasData01 &&
with_terminal() do
	output01 = expanduser("~/tmp/$outputFile01")
	rm(output01, force = true)
	XLSX.writetable(output01, collect(eachcol(dfExcel01)), names(dfExcel01))
	println("å·²è¼¸åºå° $output01")
end

# âââ¡ d7daea03-3e49-4f54-a7ed-e8a3e73b2460
md"## ç¯ä¾äºãä¾è©¦ç®è¡¨æ¥è©¢è³æ"

# âââ¡ 07c453d8-5973-4618-94da-3818542b2dc7
LocalResource("$rsPath/Banner-02.png", :height => 80)

# âââ¡ 11193569-9af9-4cbb-8313-b428118e4d9d
begin
	é è¨­åè½æ¸å®02 = 
	[
		"/api/mdm/devices/extensivesearch" => "/api/mdm/devices/extensivesearch (æç´¢å®æ´è³æ)"
	]
	å¶ä»åæ¸æç¤º02 = "(è«ç¨ Parameter={Field} æ ¼å¼åæä¸åè¡è¼¸å¥ï¼ç¨å¼æèªåä»¥ã&ãç¬¦èåä½µï¼{Field} æä»¥è©¦ç®è¡¨ååæ¬ä½ Field ç½®æï¼ä¸è¦æ³¨æå¤§å°å¯«é å®å¨ç¸åã)"
	é è¨­æ¥è©¢åæ¸02 = 
	"""
	deviceid={DeviceId}	
	"""
	è¼¸åºæ¬åæç¤º02 = "(è«åæä¸åè¡è¼¸å¥æ¬åï¼ è¥è¼¸å¥çºãåææ¬å => æ°çæ¬åãåå¨è¼¸åºææ´æ¹æ¬åã)"
	é è¨­è¼¸åºæ¬ä½02 = 
	"""
	é¨é
	DeviceId => è£ç½®è­å¥
	UserName => ç¨æ¶åç¨±
	Compliant => åè¦èå¦
	SerialNumber => åºè
	AssetNumber => è²¡ç¢ç·¨è
	EnrollmentStatus => è¨»åçæ
	"""
	é è¨­è¼¸å¥æªå02 = "TDWorkspaceONE-Input02.xlsx"
	é è¨­è¼¸åºæªå02 = "TDWorkspaceONE-Output02.xlsx"
	
	md"""
	### å¡«å¥åæ¸ ð
	åè½é ç®ï¼ $(@bind apiPath02 Select(é è¨­åè½æ¸å®02)) $br
	å¶ä»åæ¸ï¼ $å¶ä»åæ¸æç¤º02 $br 
	$(@bind parameters02 TextField((57,3), default = é è¨­æ¥è©¢åæ¸02)) $br
	è¼¸å¥æªåï¼ $(@bind inputFile02 TextField((50, 1); default = é è¨­è¼¸å¥æªå02)) $br
	è¼¸åºæªåï¼ $(@bind outputFile02 TextField((50, 1); default = é è¨­è¼¸åºæªå02)) $br
	è¼¸åºæ¬åï¼ $è¼¸åºæ¬åæç¤º02 $br
	$(@bind outputFields02 TextField((57, 10); default = é è¨­è¼¸åºæ¬ä½02)) $br
	"""
end

# âââ¡ 48929f71-047e-46ee-89b3-b1413f95fcc6
md"æ¨¡æ¬æ¸¬è©¦? $(@bind dryRun02 CheckBox(default = true)) å·è¡åè½é ç®? $(@bind runCase02 CheckBox())"

# âââ¡ 19231aaf-7c08-4275-9176-921d15e46982
md"### å®ç¾©å½æ¸"

# âââ¡ de4caf52-09ad-40c8-9be7-c0f404779598
(
	function replaceKeywordWithFieldValue(text, list, df, i)
		pairs = []
		for j in list
			p = j
			v = df[i, p]
			# r{DeviceId} => s"12345"
			push!(pairs, eval(Meta.parse("r\"{$p}\" => s\"$v\"")))
		end
		println(pairs)
		@pipe strip(text) |> replace(_, pairs...) # ð macro pipe & _
	end,

	function getKeywordList(parameters)
		x = [
			r"(?m)^[^{}]*$" => s"",
			r"(?m)^.*=" => s"", 
			r"(?m)[{}]" => s""
		] # ð regex
		@pipe strip(parameters) |> split(replace(_, x...), '\n') |> filter(!isempty, _)
	end,
	
	function updateDFWithQueryResults(df, apiPath, parameters, headers)

		results = []
		println("è®å¥ç­æ¸ï¼ $(nrow(df))")

		list = getKeywordList(parameters)
	
		for i in 1:nrow(df)
			# ð access a cell in an DataFrame
			# println(df[i, "DeviceId"])
			# println(df[i, :DeviceId])
			# println(df[i, Symbol("DeviceId")])
			# println(df[!, "DeviceId"][i])
			u = setURL(asURL, apiPath, strip(parameters))
			url = replaceKeywordWithFieldValue(u, list, df, i)
			if dryRun02
				println(url)
			else
				status, body = makeAPICall(HTTP.get, url, headers)
				if status == 200
					data = JSON3.read(body)
					hasData = "Devices" in keys(data)
					if hasData
						table = jsontable(data["Devices"])
						x = DataFrame(table)
						e = select(x, isXSLXSupported.(eltype.(eachcol(x))))
						push!(results, e)
					end
				else
					print("$status: ")
					println(replace(body, r"\n.*" => s"")) # èªåæ¨è²æåé¡
				end
			end
		end 

		if length(results) > 0
			dfX = vcat(results..., cols = :union)			
			dfJ = leftjoin(df, dfX, on = [:DeviceId	 => :DeviceId], makeunique = true)
			return dfJ
		else
			return df
		end
	end,

	function getFieldList(fields)
		@pipe strip(fields) |> replace(_, r" *=>.*" => "") |> split(_, '\n')
	end,

	function getFieldMappingList(fields)
		pairs = [
			r"(?m)^[^=>\n]*(?!=>)[^=>]*$" => s"",
			r"(?m)^" => s"\"",
			r"(?m) *=> *" => s"\" => \"",
			r"(?m)$" => s"\""
		]
		expression = @pipe strip(fields) |> replace(_, pairs...) |> split(_, '\n') |> filter(!isempty, _) |> ("Dict(" * join(_, ",") * ")") |> Meta.parse # ð meta programming
		eval(expression) # ð evaluation
	end,
)

# âââ¡ 4b116a2c-3c9a-47fc-9e91-7668d2f05333
Print(outputFields02) # ð PlutoUI Live docs

# âââ¡ 05035b0d-6440-4137-9d36-c411e8c3438a
getFieldList(outputFields02)

# âââ¡ f88c3742-35ac-4fea-b966-63009530b323
getFieldMappingList(outputFields02)

# âââ¡ d70c8e75-3ad2-48e4-b25d-0e7ed9e052c7
md"### è®åè³æ"

# âââ¡ 5cc55004-a7e6-4f9e-9e8b-cbbcbc46bb99
if runCase02
	input02 = expanduser("~/tmp/$inputFile02")
	df02 = DataFrame(XLSX.readtable(input02, "Sheet1", first_row = 1))
end

# âââ¡ b9940643-7759-40a0-8d74-4e2a38409b43
if runCase02
	result02 = updateDFWithQueryResults(df02, apiPath02, parameters02, headers)
end

# âââ¡ 5e77e163-b055-408a-8655-968d6ff40d53
runCase02 && result02

# âââ¡ 6a4d19fa-204d-42e6-969c-f69beea8df36
md"### èçè³æ"

# âââ¡ 48787c10-5cc0-403a-b0f2-ef1e25db73cb
if runCase02 && ! dryRun02
	println(outputFields02)
	hasData02 = ncol(result02) > ncol(df02)
	if hasData02
		# å° XSLS ä¸æ¯æçæ¬ä½ä»¥ JSON å­ä¸²è¡¨ç¤º
		for i in names(result02)
			if ! isXSLXSupported(eltype(result02[!, i]))
				result02[!, i*"JSON"] = JSON3.write.(result02[!, i]) # ð . broadcast
			end
		end
		# æé¸æ¬ä½
		dfExcel02 = select(result02, getFieldList(outputFields02))
		# æ´æ¹æ¬å
		# åèèªæ³ï¼ names!(df, [:c1,:c2,:c3]) (all) æ rename!(df, Dict(:c1 => :newCol))
		rename!(dfExcel02, getFieldMappingList(outputFields02))
	end
end

# âââ¡ 73d5db2a-c2ff-41af-849c-b2aa76198d5b
runCase02 && ! dryRun02 && hasData02 && dfExcel02

# âââ¡ 1a9afe1a-1236-4840-9eb7-50516de8194a
md"### è¼¸åºè³æ(å¯«å¥è©¦ç®è¡¨)"

# âââ¡ 9a0d9238-b1a7-4a7d-9ed6-d7cc356b202e
runCase02 && ! dryRun02 && hasData02 &&
with_terminal() do
	output02 = expanduser("~/tmp/$outputFile02")
	rm(output02, force = true)
	XLSX.writetable(output02, collect(eachcol(dfExcel02)), names(dfExcel02))
	println("å·²è¼¸åºå° $output02")
end

# âââ¡ 99938645-2346-4962-b287-1a9ac47b631d
md"## ç¯ä¾ä¸ãä¾è©¦ç®è¡¨å·è¡æä»¤ ð"

# âââ¡ 13704898-ba73-4505-9954-93c3e2c0cf92
LocalResource("$rsPath/Banner-03.png", :height => 80)

# âââ¡ 53355cb0-0293-49e8-8450-869fa269225d
begin
	é è¨­åè½æ¸å®03 = 
	[
		"/api/mdm/devices/{DeviceId}/commands" => "/api/mdm/devices/{DeviceId}/commands (å·è¡æä»¤)"
	]
	å¶ä»åæ¸æç¤º03 = "(è«ç¨ Parameter={Field} æ ¼å¼åæä¸åè¡è¼¸å¥ï¼ç¨å¼æèªåä»¥ã&ãç¬¦èåä½µï¼{Field} æä»¥è©¦ç®è¡¨ååæ¬ä½ Field ç½®æï¼ä¸è¦æ³¨æå¤§å°å¯«é å®å¨ç¸åãè¥åªæ)"
	é è¨­æ¥è©¢åæ¸03 = 
	"""
	deviceid={DeviceId}
	command=DeviceQuery
	"""
	è¼¸åºæ¬åæç¤º03 = "(è«åæä¸åè¡è¼¸å¥æ¬åï¼ è¥è¼¸å¥çºãåææ¬å => æ°çæ¬åãåå¨è¼¸åºææ´æ¹æ¬åã)"
	é è¨­è¼¸åºæ¬ä½03 = 
	"""
	é¨é
	DeviceId => è£ç½®è­å¥
	Status => çµæ
	"""
	é è¨­è¼¸å¥æªå03 = "TDWorkspaceONE-Input03.xlsx"
	é è¨­è¼¸åºæªå03 = "TDWorkspaceONE-Output03.xlsx"
	
	md"""
	### å¡«å¥åæ¸
	åè½é ç®ï¼ $(@bind apiPath03 Select(é è¨­åè½æ¸å®03)) $br
	å¶ä»åæ¸ï¼ $å¶ä»åæ¸æç¤º03 $br
	$(@bind parameters03 TextField((57,3), default = é è¨­æ¥è©¢åæ¸03)) $br
	è¼¸å¥æªåï¼ $(@bind inputFile03 TextField((50, 1); default = é è¨­è¼¸å¥æªå03)) $br
	è¼¸åºæªåï¼ $(@bind outputFile03 TextField((50, 1); default = é è¨­è¼¸åºæªå03)) $br
	è¼¸åºæ¬åï¼ $è¼¸åºæ¬åæç¤º03 $br
	$(@bind outputFields03 TextField((57, 10); default = é è¨­è¼¸åºæ¬ä½03)) $br
	"""
end

# âââ¡ 1a464fd6-c2c0-4cd3-a363-f84f8dcc997c
md"æ¨¡æ¬æ¸¬è©¦? $(@bind dryRun03 CheckBox(default = true)) å·è¡åè½é ç®? $(@bind runCase03 CheckBox())"

# âââ¡ 2b731f3a-d345-4c26-8b7f-ec1f80f7c070
md"### å®ç¾©å½æ¸"

# âââ¡ b768650e-2338-43f7-83c6-9343a79afe15
(
	function updateDFWithCommandResults(df, apiPath, parameters, headers)

		results = []
		println("è®å¥ç­æ¸ï¼ $(nrow(df))")

		list = getKeywordList(parameters)

		! ("Status" in names(df)) && insertcols!(df, "Status" => 0)
		
		for i in 1:nrow(df)
			u = setURL(asURL, apiPath, parameters)
			url = replaceKeywordWithFieldValue(u, list, df, i)
			if dryRun03
				df[i, "Status"] = 0
				println(url)
			else
				status, body = makeAPICall(HTTP.post, url, headers)
				df[i, "Status"] = status
			end
		end 

		return df
	end,
)

# âââ¡ f05c2758-df02-4e89-be91-3f00f4f55472
md"### å·è¡æä»¤"

# âââ¡ 6beaed3c-b7aa-4c41-a977-5ca7c64ed756
runCase03 && begin
	input03 = expanduser("~/tmp/$inputFile03")
	df03 = DataFrame(XLSX.readtable(input03, "Sheet1", first_row = 1))
end

# âââ¡ 2f0a9927-76af-42e8-92ac-191550656a55
runCase03 && begin
	result03 = updateDFWithCommandResults(df03, apiPath03, parameters03, headers)
end

# âââ¡ df7c921f-4cef-4246-94a9-5b1532cb0eed
md"### èçè³æ"

# âââ¡ 2dc7b708-7c97-4676-803d-8f0c4dd0eade
runCase03 && ! dryRun03 && begin
	println(outputFields03)
	# æé¸æ¬ä½
	dfExcel03 = select(result03, getFieldList(outputFields03))
	# æ´æ¹æ¬å
	# åèèªæ³ï¼ names!(df, [:c1,:c2,:c3]) (all) æ rename!(df, Dict(:c1 => :newCol))
	rename!(dfExcel03, getFieldMappingList(outputFields03))
end

# âââ¡ 3160896c-eae4-4758-9aa8-308cf067a25f
md"### è¼¸åºè³æ(å¯«å¥è©¦ç®è¡¨)"

# âââ¡ 4e104b36-a809-4094-9163-6cff67eb9db4
runCase03 && ! dryRun03 &&
with_terminal() do
	output03 = expanduser("~/tmp/$outputFile03")
	rm(output03, force = true)
	XLSX.writetable(output03, collect(eachcol(dfExcel03)), names(dfExcel03))
	println("å·²è¼¸åºå° $output03")
end

# âââ¡ 66773ae8-6e8c-4949-9082-a19463215051
md"""
# èªæ³ç¯ä¾
æä¾åé¢ç¨å¼æç¨å°åä»¶çè£åç¯ä¾
"""

# âââ¡ 2b62de3a-8d99-4e44-b8fe-aff11b39a3b1
md"""
PlutoUI çºä»¥ä¸ãè¼¸å¥é¡åãæä¾äºæ¹ä¾¿ä½¿ç¨ç ãJulia ç©ä»¶ãï¼å¦ä¸ç¯ä¾åå¥å°äºåä¸åçè¼¸å¥é¡åç¶å®å° a, b, c, d, e äºåè®æ¸ã\$ ç¬¦èç¨ä¾å·è¡è¡¨éå¼ä¸¦å°çµæè½çºå­ä¸²ã

a: $(@bind a Slider(1:9))
b: $(@bind b TextField())
c: $(@bind c Button("ð"))
d: $(@bind d CheckBox())
e: $(@bind e Select(["first" => "ð", "second" => "âï¸" ]))

ç¯ä¾ä¾æºï¼
1. å¥ä»¶ä¾æºï¼[JuliaPluto/PlutoUI.jl](https://github.com/JuliaPluto/PlutoUI.jl)
1. å¥ä»¶èªªæï¼[Readme Â· PlutoUI.jl](https://docs.juliahub.com/PlutoUI/abXFp/0.7.48/)
1. è©³ç´°ç¯ä¾ï¼[https://juliapluto.github.io/sample-notebook-previews/PlutoUI.jl.html](https://juliapluto.github.io/sample-notebook-previews/PlutoUI.jl.html)
"""

# âââ¡ f6084608-91db-4a3f-b124-e03a6adb4df0
md"ä»¥åçµ(Tuple)çæ¹å¼é¡¯ç¤ºåå¾çå¼"

# âââ¡ 2c4d8b69-35c0-46f7-be15-46deff26238c
(a, b, c, d, e)

# âââ¡ 4ff585eb-f729-4897-a184-ae17839ca133
md"ç¨ç«ä½¿ç¨ @bind çç¯ä¾"

# âââ¡ bbdcd891-3cab-43dc-a29a-a5000f96f0a0
@bind f MultiSelect(["potato", "carrot", "boerenkool"])

# âââ¡ 89e69050-98e6-43d6-9d77-c8391c7f4e27
f

# âââ¡ 22865dbe-2d84-4aea-a481-453645e5468b
md"# ç°å¢æºå"

# âââ¡ 3ce1746d-9a62-4db4-ba9e-25c03ed89be0
md"""
## å®è£ Julia å Pluto.jl (ä»¥ macOS çºä¾)
Shell çé¨ä»½
``` shell
brew install juliaup
juliaup help
juliaup status
juliaup add +lts
julia
```
Julia çé¨ä»½
``` julia
]
add Pluto, PlutoUI, Base64, Dates, HTTP, JSON3, JSONTables, DataFrames, XLSX
status
[â Backspace]
using Pluto
Pluto.run()
```
"""

# âââ¡ 0b25141b-63bc-4b9a-9b4f-d347ceb3f48a
md"""
## äºè§£ Workspace ONE UEM API
1. VMware TestDrive - [Workspace ONE UEM API Explorer](https://testdrive.awmdm.com/api/help/#!/apis)
1. VMware Workspace ONE - [Code Samples and PowerCLI Example Scripts | VMware - VMware {code}](https://developer.vmware.com/samples?categories=Sample&keywords=Workspace%20ONE&tags=&groups=&filters=&sort=&page=1)
"""

# âââ¡ 68a3a478-35b6-4f14-a342-a49e110a2a23
md"""
# åèè³æ
æä¾åé¢ç¨å¼ç¸éçåèè³æï¼å§å®¹ååçº Workspace ONEãeSIM å Julia å¹¾åé¨ä»½

## Workspace ONE
1. [Letâs Git Commit(ted) to Resources: Getting Started with the Workspace ONE UEM REST APIs | VMware](https://techzone.vmware.com/blog/lets-git-committed-resources-getting-started-workspace-one-uem-rest-apis)
1. [å° UEM åè½è REST API æ­éä½¿ç¨](https://docs.vmware.com/tw/VMware-Workspace-ONE-UEM/services/UEM_ConsoleBasics/GUID-BF20C949-5065-4DCF-889D-1E0151016B5A.html)
1. [Getting Started with Workspace ONE Intelligence APIs: Workspace ONE Operational Tutorial | VMware](https://techzone.vmware.com/getting-started-workspace-one-intelligence-apis-workspace-one-operational-tutorial#introduction-b)
1. [Use API server URL for Workspace ONE UEM REST API calls (82724)](https://kb.vmware.com/s/article/82724)
1. [Workspace ONE UEM API Explorer (as1174)](https://as1174.awmdm.com/api/help/#!/apis)
1. [Enroll Your Linux Devices](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/Linux_Device_Management/GUID-C155A8D9-039C-4CDB-9694-4B839F1E3CD7.html)

## eSIM

1. [Simplifying eSIM Cellular Plan Activation with Workspace ONE UEM - Samples - VMware {code}](https://developer.vmware.com/samples/7423/simplifying-esim-cellular-plan-activation-with-workspace-one-uem?h=Workspace%20ONE)

## Julia
1. [How To Make REST API Calls In Julia | CodeHandbook](https://codehandbook.org/make-rest-api-calls-julia/)
1. [Introduction - Julia language: a concise tutorial](https://syl1.gitbook.io/julia-language-a-concise-tutorial/)
1. [Julia Documentation Â· The Julia Language](https://docs.julialang.org/en/v1/)
1. [PlutoUI.jl](https://docs.juliahub.com/PlutoUI/abXFp/0.7.22/)
1. [JSON3.jl](https://quinnj.github.io/JSON3.jl/stable/)
1. [Working with nested JSON strings/files inÂ Julia - Julia Community ð£](https://forem.julialang.org/atantos/working-with-nested-json-stringsfiles-in-julia-42a7)
1. [HTTP.jl](https://juliaweb.github.io/HTTP.jl/stable/)
1. [Regex Tutorial - Turning Modes On and Off for Only Part of The Regular Expression](https://www.regular-expressions.info/modifiers.html)
1. [æ­£è¦è¡¨ç¤ºå¼ - ç¶­åºç¾ç§ï¼èªç±çç¾ç§å¨æ¸](https://zh.m.wikipedia.org/zh-tw/%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F)
1. [JuliaProgrammingForNervousBeginners/Course Notes/Translation/Traditional Chinese at main Â· ysaereve/JuliaProgrammingForNervousBeginners](https://github.com/ysaereve/JuliaProgrammingForNervousBeginners/tree/main/Course%20Notes/Translation/Traditional%20Chinese)
1. [Unicode Input Â· The Julia Language](https://docs.julialang.org/en/v1/manual/unicode-input/)
1. [How to Build Your First Web App in Julia with Genie.jlÂ ð§ââï¸ ð](https://www.freecodecamp.org/news/how-to-build-web-apps-in-julia/)
1. [RiceZeeLi/TDWorkspaceONE ð](https://github.com/RiceZeeLi/TDWorkspaceONE)
1. [Julia Taiwan | Facebook ð](https://www.facebook.com/groups/JuliaTaiwan) 
"""

# âââ¡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Base64 = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
JSONTables = "b9914132-a727-11e9-1322-f18e41205b0b"
Pipe = "b98c9c47-44ae-5843-9183-064241ee97a0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
DataFrames = "~1.4.2"
HTTP = "~1.5.3"
JSON3 = "~1.11.1"
JSONTables = "~1.0.3"
Pipe = "~1.3.0"
PlutoUI = "~0.7.48"
XLSX = "~0.8.4"
"""

# âââ¡ 00000000-0000-0000-0000-000000000002
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

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

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

# âââ¡ Cell order:
# ââ9afd7578-61e9-11ed-3be5-e32eb35c953d
# ââ9bc4054a-f0d0-40f6-9260-881bfebb6cce
# ââ713a287f-98b8-461d-8c95-8493c9796971
# â â2a093f7b-feaa-4620-b9cf-dd6a9a2a41ba
# ââ51175407-f3f7-4dc5-9844-e207d84e8a17
# ââd6853197-ee2e-4ab9-bb55-de0909d3bde6
# ââa5e8383f-8a37-468a-b20e-9dff88d5231a
# ââbb662f53-0b39-41e5-8e63-f193317df883
# â â0bb3be4d-ffa1-4958-a482-a3109e3b72e5
# ââd47d861f-c69a-4352-a3a5-8c8456a1e301
# ââbc54c11d-18df-4e04-a078-16304fd14c4a
# ââf2490bce-820c-40d7-97d4-187fa29a8d49
# ââ78c94534-c233-4786-9bf6-545b8411635b
# ââ9949af3e-a30d-4516-b32c-12d959be31ea
# ââ3aa127ab-ad64-49bc-994e-5e3dc2f5f7e7
# ââa3304bb2-f890-4b69-9320-18b64d626dd2
# ââ085b10a5-1596-40a0-a705-d1088ca4e621
# ââ55ba9af8-122a-4649-904f-585bda70776c
# ââe7a28bef-e18d-40f7-a8d8-38e2d87b7171
# ââ5efae899-77de-40a1-a6bb-4329b80702ab
# ââ29cf395d-b1fe-4379-b1df-c1aef99a1a80
# ââ2fcaa116-9f3b-4e61-9c17-4dbadfe25d5d
# â â5f15aa65-5cd9-45e4-82b3-4d53096f465a
# â â0ae787f5-a7ad-4ac3-9526-f9c990a3ad1c
# ââ210e476f-9a76-46a6-9276-0e3caf5ddaa2
# â â51ccf417-946f-4c53-abae-9ecc3a2d30ea
# ââ5ac612cd-83a5-4eb5-8d77-a90becabb55a
# â âb446c9eb-e517-4803-a5cb-db14cdc27620
# ââ751c735f-aa4b-416a-8637-3e32639a9394
# â â14acd856-b638-4b69-a87b-d7c52afd400a
# â â5219ff79-1b39-49c9-95ae-84f85cc0d113
# â â1899b982-85e6-44a3-9577-928eabc63b4c
# â â315d90ec-2acd-4fe6-ae62-75a44b4020a6
# ââ24c6999a-7b3c-499b-aa23-eb89f364e247
# â âdb55ef9c-76d6-459f-bb30-8d9bbf3021c9
# ââd7daea03-3e49-4f54-a7ed-e8a3e73b2460
# ââ07c453d8-5973-4618-94da-3818542b2dc7
# â â11193569-9af9-4cbb-8313-b428118e4d9d
# ââ48929f71-047e-46ee-89b3-b1413f95fcc6
# ââ19231aaf-7c08-4275-9176-921d15e46982
# â âde4caf52-09ad-40c8-9be7-c0f404779598
# â â4b116a2c-3c9a-47fc-9e91-7668d2f05333
# â â05035b0d-6440-4137-9d36-c411e8c3438a
# â âf88c3742-35ac-4fea-b966-63009530b323
# ââd70c8e75-3ad2-48e4-b25d-0e7ed9e052c7
# â â5cc55004-a7e6-4f9e-9e8b-cbbcbc46bb99
# â âb9940643-7759-40a0-8d74-4e2a38409b43
# â â5e77e163-b055-408a-8655-968d6ff40d53
# ââ6a4d19fa-204d-42e6-969c-f69beea8df36
# â â48787c10-5cc0-403a-b0f2-ef1e25db73cb
# â â73d5db2a-c2ff-41af-849c-b2aa76198d5b
# ââ1a9afe1a-1236-4840-9eb7-50516de8194a
# â â9a0d9238-b1a7-4a7d-9ed6-d7cc356b202e
# ââ99938645-2346-4962-b287-1a9ac47b631d
# ââ13704898-ba73-4505-9954-93c3e2c0cf92
# â â53355cb0-0293-49e8-8450-869fa269225d
# â â1a464fd6-c2c0-4cd3-a363-f84f8dcc997c
# ââ2b731f3a-d345-4c26-8b7f-ec1f80f7c070
# â âb768650e-2338-43f7-83c6-9343a79afe15
# ââf05c2758-df02-4e89-be91-3f00f4f55472
# â â6beaed3c-b7aa-4c41-a977-5ca7c64ed756
# â â2f0a9927-76af-42e8-92ac-191550656a55
# ââdf7c921f-4cef-4246-94a9-5b1532cb0eed
# â â2dc7b708-7c97-4676-803d-8f0c4dd0eade
# ââ3160896c-eae4-4758-9aa8-308cf067a25f
# â â4e104b36-a809-4094-9163-6cff67eb9db4
# ââ66773ae8-6e8c-4949-9082-a19463215051
# â â2b62de3a-8d99-4e44-b8fe-aff11b39a3b1
# â âf6084608-91db-4a3f-b124-e03a6adb4df0
# â â2c4d8b69-35c0-46f7-be15-46deff26238c
# ââ4ff585eb-f729-4897-a184-ae17839ca133
# â âbbdcd891-3cab-43dc-a29a-a5000f96f0a0
# â â89e69050-98e6-43d6-9d77-c8391c7f4e27
# ââ22865dbe-2d84-4aea-a481-453645e5468b
# ââ3ce1746d-9a62-4db4-ba9e-25c03ed89be0
# ââ0b25141b-63bc-4b9a-9b4f-d347ceb3f48a
# ââ68a3a478-35b6-4f14-a342-a49e110a2a23
# ââ00000000-0000-0000-0000-000000000001
# ââ00000000-0000-0000-0000-000000000002
