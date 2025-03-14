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

local function base64_encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2^(6-i) or 0) end
        return b:sub(c+1, c+1)
    end) .. ({ '', '==', '=' })[#data%3+1])
end

local function xor_encrypt(data, key)
    local key_bytes = str_to_bytes(key)
    local data_bytes = str_to_bytes(data)
    local result = {}

    for i = 1, #data_bytes do
        local xor_result = xor_bitwise(data_bytes[i], key_bytes[(i - 1) % #key_bytes + 1])
        table.insert(result, xor_result)
    end

    return bytes_to_str(result)
end

local function generate_key(length)
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local key = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        key = key .. string.sub(charset, rand, rand)
    end
    return key
end

local function get_input()
    local _, value = VarLib2:getGlobalVarByName(4, "Aposi")
    return value
end

local function update_output(encrypted, key)
    VarLib2:setGlobalVarByName(4, "Group2", encrypted)
    VarLib2:setGlobalVarByName(4, "Group3", key)
end

local function process_encryption()
    local data = get_input()
    local key = generate_key(10)
    local encrypted = xor_encrypt(data, key)
    local encoded_encrypted = base64_encode(encrypted)
    update_output(encoded_encrypted, key)
end

process_encryption()