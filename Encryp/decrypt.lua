local function xor_bitwise(a, b)
    local result = 0
    local shift = 0

    while a > 0 or b > 0 do
        local bit_a = a % 2
        local bit_b = b % 2
        local bit_result = (bit_a ~= bit_b) and 1 or 0
        result = result + bit_result * 2^shift
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        shift = shift + 1
    end

    return result
end

local function str_to_bytes(str)
    local bytes = {}
    for i = 1, #str do
        table.insert(bytes, string.byte(str, i))
    end
    return bytes
end

local function bytes_to_str(bytes)
    local str = ""
    for _, b in ipairs(bytes) do
        str = str .. string.char(b)
    end
    return str
end

local function base64_decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = data:gsub("[^" .. b .. "=]", "")
    return (data:gsub(".", function(x)
        if x == "=" then return "" end
        local r, f = "", (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and "1" or "0") end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d", function(x)
        if #x ~= 8 then return "" end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function xor_decrypt(data, key)
    local key_bytes = str_to_bytes(key)
    local data_bytes = str_to_bytes(data)
    local result = {}

    for i = 1, #data_bytes do
        local xor_result = xor_bitwise(data_bytes[i], key_bytes[(i - 1) % #key_bytes + 1])
        table.insert(result, xor_result)
    end

    return bytes_to_str(result)
end
local function get_input()
    local _, value = VarLib2:getGlobalVarByName(4, "Aposi")
    return value
end

local function update_output(decrypted)
    VarLib2:setGlobalVarByName(4, "Group4", decrypted)
end

local function process_decryption()
    local data = get_input()
    local encoded_encrypted, key = data:match("([^,]+),([^,]+)")
    if encoded_encrypted and key then
        local encrypted = base64_decode(encoded_encrypted)
        local decrypted = xor_decrypt(encrypted, key)
        update_output(decrypted)
    end
end

process_decryption()
