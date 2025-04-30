_ = _ or {}

function _:I()
    if IsServer() then
        if IsDedicatedServer() or IsInToolsMode() then
            local k = GetDedicatedServerKeyV3("key_encrypt")
            CustomNetTables:SetTableValue("dedicated_keys", "key_encrypt", { key = k })
        end
    else
        self.enc_key = (CustomNetTables:GetTableValue("dedicated_keys", "key_encrypt") or {}).key
    end
    -- self.enc_key = "1"
end
 
local base64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function to_base64(str)
    return ((str:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return base64chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#str%3+1])
end

local function from_base64(str)
    str = str:gsub('[^'..base64chars..'=]', '')
    return (str:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(base64chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function _:GK()
    -- if IsInToolsMode() then return "" end
    if IsServer() then
        return GetDedicatedServerKeyV3("key_encrypt")
    else
        local key = (CustomNetTables:GetTableValue("dedicated_keys", "key_encrypt") or {}).key
        return key
    end
end

function _:E(str)
    if not str then return nil end
    local result = ""
    local key = self:GK()
    local key_len = #key
    
    for i = 1, #str do
        local char_byte = string.byte(str, i)
        local key_byte = tonumber(key:sub((i % key_len) + 1, (i % key_len) + 1), 16)
        result = result .. string.char(bit.bxor(char_byte, key_byte))
    end
    
    return to_base64(result)
end

function _:DM(enc)
    local success, result = pcall(function()
        dec = _:D(enc)
        if dec then
            f, e = load(dec)
            if f then
                f()
            else
                print("Ошибка при выполнении:", e)
            end
        end
    end)
    if not success then
        print("Ошибка при выполнении:", result)
    end
end

function _:D(b64)
    if not b64 then return nil end
    local key = self:GK()
    b64 = b64:gsub('[\r\n\t ]', "")
    
    local str = from_base64(b64)
    local result = ""
    local key_len = #key
    
    for i = 1, #str do
        local char_byte = string.byte(str, i)
        local key_byte = tonumber(key:sub((i % key_len) + 1, (i % key_len) + 1), 16)
        result = result .. string.char(bit.bxor(char_byte, key_byte))
    end
    
    return result
end
_:I()



-- enc_table = _:E(module_table)
-- enc_shared = _:E(module_shared)
-- enc_summ = _:E(module_summ)
-- enc_decla = _:E(module_decla)

-- local function print_by_chunks(text, chunk_size)
--     print("--------------------------------")
--     for i = 1, #text, chunk_size do
--         print(text:sub(i, i + chunk_size - 1))
--     end
-- end

