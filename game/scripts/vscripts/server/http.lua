local BASE_URL = "https://109.172.7.191/api"
-- local SERVER_KEY = GetDedicatedServerKeyV3("heroes_def")
local MAX_REPEAT = 5

function HTTP(method, url, body, callbacks) 
	local DataToSend = body or {}
    -- DataToSend['api_key'] = SERVER_KEY
	local repeatCount = 0
	SendRequest(method, url, DataToSend, repeatCount, callbacks)
end

function SendRequest(method, url, body, repeatCount, callbacks) 
	if repeatCount >= MAX_REPEAT then
		if callbacks.error then callbacks.error({error = "Сервер не отвечает"}) end	
		if callbacks.finnaly then callbacks.finnaly() end	

		return 
	end
	local request = CreateHTTPRequest(method, BASE_URL.. url)
	request:SetHTTPRequestRawPostBody("application/json", json.encode(body))
	print("Запустился")
 	request:Send(function (result)
 		local data = json.decode(result["Body"])
		local isSuccess = result.StatusCode == 200

		if isSuccess then 
			if callbacks.success then callbacks.success(data) end
		else 
			if result.StatusCode >= 400 and result.StatusCode <= 404 then 
				if callbacks.error then callbacks.error(data) end	
			else
				return SendRequest(method, url, body, repeatCount + 1, callbacks)
			end
		end

		if callbacks.finnaly then callbacks.finnaly() end	
  	end)
end