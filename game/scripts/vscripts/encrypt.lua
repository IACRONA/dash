local encryptionKey
if IsServer() then
    -- На сервере получаем ключ и сохраняем в таблицу
    encryptionKey = GetDedicatedServerKeyV3("encrypted_modules"):sub(1,32)
    CustomNetTables:SetTableValue("common", "encrypt_key", {_ = encryptionKey})
else
    -- На клиенте получаем ключ из таблицы
    encryptionKey = (CustomNetTables:GetTableValue("common", "encrypt_key") or {})._ or ""
end

-- Создание изолированного окружения для модулей
local function createEnvironment(fn)
    local env = setmetatable({}, {__index = _ENV or getfenv()})
    if setfenv then 
        setfenv(fn, env)
    end
    return fn(env) or env
end

-- Основные модули:
local bit = createEnvironment(function(env) --[[ Битовые операции ]] end)
local galoisField = createEnvironment(function(env) --[[ Операции в поле Галуа ]] end) 
local utils = createEnvironment(function(env) --[[ Вспомогательные функции ]] end)
local aes = createEnvironment(function(env) --[[ Реализация AES ]] end)
local stringBuffer = createEnvironment(function(env) --[[ Буфер для строк ]] end)
local cipherMode = createEnvironment(function(env) --[[ Режимы шифрования ]] end)

-- Вспомогательная функция для преобразования hex в строку
local function hexToString(hex)
    return hex:gsub('..', function(cc)
        return string.char(tonumber(cc, 16))
    end)
end

-- Инициализация ключа AES
local aesKey = {string.byte(hexToString(encryptionKey), 1, 16)}

-- Глобальная функция расшифровки
_G.decrypt = function(encrypted)
    local data = hexToString(encrypted)
    local iv = {string.byte(data, 1, 16)}
    local decrypted = cipherMode.decryptString(aesKey, data:sub(17), cipherMode.decryptCBC, iv)
    return string.sub(decrypted, 1, string.find(decrypted, "\0")-1)
end

-- Глобальная функция расшифровки и выполнения модуля
_G.decryptModule = function(encrypted, ...)
    return assert(load(
        decrypt(encrypted),
        debug.getinfo(2).source,
        nil,
        getfenv(2)
    ))(...)
end

-- Глобальная функция шифрования
_G.encrypt = function(plaintext)
    -- Генерируем случайный IV (вектор инициализации)
    local iv = {}
    for i = 1, 16 do
        iv[i] = math.random(0, 255)
    end
    
    -- Добавляем нулевой байт в конец строки для определения длины при расшифровке
    local padded = plaintext .. "\0"
    
    -- Шифруем данные
    local encrypted = cipherMode.encryptString(aesKey, padded, cipherMode.encryptCBC, iv)
    
    -- Конвертируем IV и зашифрованные данные в hex
    local result = ""
    for i = 1, #iv do
        result = result .. string.format("%02x", iv[i])
    end
    for i = 1, #encrypted do
        result = result .. string.format("%02x", string.byte(encrypted, i))
    end
    
    return result
end