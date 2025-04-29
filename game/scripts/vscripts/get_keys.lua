if IsServer() then
    local key_encrypt = GetDedicatedServerKeyV3("key_encrypt") or "key_encrypt"
    CustomNetTables:SetTableValue("dedicated_keys", "key_encrypt", {key = key_encrypt})

    local encrypt_key = GetDedicatedServerKeyV3("encrypt_key") or "encrypt_key"
    CustomNetTables:SetTableValue("dedicated_keys", "encrypt_key", {key = encrypt_key})

    local key_server1 = GetDedicatedServerKeyV3("encrypt_key_server1") or "encrypt_key_server1"
    CustomNetTables:SetTableValue("dedicated_keys", "key_server1", {key = key_server1})

    local key_server2 = GetDedicatedServerKeyV3("encrypt_key_server2") or "encrypt_key_server2"
    CustomNetTables:SetTableValue("dedicated_keys", "key_server2", {key = key_server2})

    local key_server3 = GetDedicatedServerKeyV3("encrypt_key_server3") or "encrypt_key_server3"
    CustomNetTables:SetTableValue("dedicated_keys", "key_server3", {key = key_server3})

    local key_server4 = GetDedicatedServerKeyV3("encrypt_key_server4") or "encrypt_key_server4"   
    CustomNetTables:SetTableValue("dedicated_keys", "key_server4", {key = key_server4})

    local key_server5 = GetDedicatedServerKeyV3("encrypt_key_server5") or "encrypt_key_server5"   
    CustomNetTables:SetTableValue("dedicated_keys", "key_server5", {key = key_server5})
end 