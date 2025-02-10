const TABLE = "dedicated_keys"



// Проверяем Steam ID игрока и добавляем отладочный вывод
const playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID())
const steamID = playerInfo ? playerInfo.player_steamid : 'нет ID'

// Добавляем отладочную информацию на панель

// Получаем и показываем ключи
const key_encrypt = CustomNetTables.GetTableValue(TABLE, "key_encrypt")
const encrypt_key = CustomNetTables.GetTableValue(TABLE, "encrypt_key")




function ToggleKeysPanel() {
    const panel = $('#KeysPanel')
    panel.SetHasClass('visible', !panel.BHasClass('visible'))
}

;(function() {
    // Проверяем Steam ID игрока
    const playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID())
    const steamID = playerInfo ? playerInfo.player_steamid : 'нет ID'
    
    // Обновляем Steam ID
    $('#SteamIDLabel').text = "Ваш Steam ID: " + steamID

    // Проверяем, соответствует ли Steam ID
    const allowedSteamID = '76561199130394530'; // Замените на нужный Steam ID
    const adminPanel = $('#AdminPanel');

    if (steamID === allowedSteamID) {
        adminPanel.visible = true; // Показываем панель
        // Получаем и показываем ключи
        const updateKey = (keyName, labelId) => {
            const keyData = CustomNetTables.GetTableValue(TABLE, keyName)
            const label = $(labelId)
            if (label && keyData && keyData.key) {
                label.text = keyName + ": " + keyData.key
            } else { 
                label.text = keyName + ": не найден"
            }
            $.Msg(label.text)
        }
        
        updateKey("key_encrypt", "#KeyEncrypt")
        updateKey("encrypt_key", "#EncryptKey")
        
        for (let i = 1; i <= 5; i++) {
            updateKey("key_server" + i, "#KeyServer" + i)
        }
    } else {
        adminPanel.visible = false; // Скрываем панель, если ID не совпадает
    }
})()
