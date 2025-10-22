-- Шемелис отладочный логгер
-- Пишет логи в файл для отладки

local LOG_FILE = "shemelis_debug.log"

-- Открываем или создаём файл для логирования
local log_handle = io.open(LOG_FILE, "a")

function log_debug(message)
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local full_message = "[" .. timestamp .. "] " .. message .. "\n"
	
	if log_handle then
		log_handle:write(full_message)
		log_handle:flush()
	end
	
	print(full_message)
	Warning(full_message)
end

-- Логируем начало инициализации
log_debug("=== SHEMELIS DEBUG LOG STARTED ===")

-- Переопределяем глобальные функции для отладки
local original_print = print
function print(...)
	local message = table.concat({...}, " ")
	log_debug("[PRINT] " .. message)
	original_print(...)
end

log_debug("Debug logger initialized successfully")
