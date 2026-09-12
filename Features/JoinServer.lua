-- ==================================================
-- JOIN SERVER (SEA2) - DECODE + JOIN + NORMAL JOBID
-- ==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

-- ==================================================
-- SETTINGS
-- ==================================================
local SECRET_KEY = "YOKUDO2024SuperSecretKey!"
local PREFIX = "YOKUDO-"

-- ==================================================
-- ⭐ XXTEA DECRYPT
-- ==================================================
local function xxtea_decrypt(data, key)
    local function mx(s, y, z, p, e, k)
        return bit32.bxor(
            bit32.bxor(
                bit32.bxor(bit32.rshift(z, 5), bit32.lshift(y, 2))
                + bit32.bxor(bit32.rshift(y, 3), bit32.lshift(z, 4)),
                bit32.bxor(s, y)
            ),
            k[bit32.band(p, 3) + 1] + z
        )
    end
    
    local function str_to_long(d)
        local r, l = {}, #d
        for i = 1, l, 4 do
            local n = 0
            for j = 0, 3 do n = n + (string.byte(d, i + j) or 0) * (256 ^ j) end
            table.insert(r, n)
        end
        return r
    end
    
    local function long_to_str(d)
        local r = {}
        for _, n in ipairs(d) do
            local v = n
            for j = 0, 3 do
                table.insert(r, string.char(bit32.band(v, 255)))
                v = bit32.rshift(v, 8)
            end
        end
        return table.concat(r)
    end
    
    local k = str_to_long(key)
    while #k < 4 do table.insert(k, 0) end
    
    local v = str_to_long(data)
    local n = #v
    if n == 0 then return data end
    
    local z, y = v[n], v[1]
    local delta, rounds = 0x9E3779B9, 6 + 52 / n
    local s = bit32.band(math.floor(rounds) * delta, 0xFFFFFFFF)
    
    for _ = 1, math.floor(rounds) do
        local e = bit32.band(bit32.rshift(s, 2), 3)
        for p = n, 1, -1 do
            z = v[(p - 2) % n + 1]
            y = bit32.band(v[p] - mx(s, y, z, p - 1, e, k), 0xFFFFFFFF)
            v[p] = y
        end
        s = bit32.band(s - delta, 0xFFFFFFFF)
    end
    
    return long_to_str(v)
end

-- ==================================================
-- ⭐ BASE64 DECODE
-- ==================================================
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function Base64Decode(data)
    local b = {}
    for i = 1, #data do
        local c = data:sub(i, i)
        if c == "=" then break end
        local p = B64:find(c) - 1
        if p < 0 then return nil end
        b[i] = p
    end
    
    local r = {}
    for i = 1, #b, 4 do
        local n = (b[i] or 0) * 0x40000 + (b[i+1] or 0) * 0x1000 + (b[i+2] or 0) * 0x40 + (b[i+3] or 0)
        table.insert(r, string.char(math.floor(n / 0x10000)))
        if b[i+2] then table.insert(r, string.char(math.floor((n % 0x10000) / 0x100))) end
        if b[i+3] then table.insert(r, string.char(n % 0x100)) end
    end
    return table.concat(r)
end

-- ==================================================
-- ⭐ DECODE JOBID
-- ==================================================
local function DecodeJobId(encoded)
    if encoded:sub(1, #PREFIX) ~= PREFIX then return nil end
    local dec = Base64Decode(encoded:sub(#PREFIX + 1))
    if not dec then return nil end
    return xxtea_decrypt(dec, SECRET_KEY)
end

-- ==================================================
-- ⭐ CHECK IF JOBID IS NORMAL (UUID Format)
-- ==================================================
local function isNormalJobId(jobId)
    -- UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    local pattern = "^%x+%-%x+%-%x+%-%x+%-%x+$"
    return string.match(jobId, pattern) ~= nil
end

-- ==================================================
-- ⭐ JOIN SERVER BY ENCODED OR NORMAL JOBID (Auto Detect)
-- ==================================================
function _G.YOKUDO_JoinServerByEncoded(encoded)
    if not encoded or encoded == "" then
        print("⚠️ Please paste Encoded JobID or Normal JobID!")
        return false, "No JobID provided"
    end
    
    local real = nil
    
    -- ⭐ ពិនិត្យថាជា Encoded ឬ Normal
    if encoded:sub(1, #PREFIX) == PREFIX then
        -- Encoded JobID → Decode
        real = DecodeJobId(encoded)
        if not real then
            print("❌ Failed to decode Encoded JobID!")
            return false, "Invalid Encoded JobID"
        end
        print("🔵 Decoded JobID: " .. real)
    elseif isNormalJobId(encoded) then
        -- Normal JobID (UUID) → ប្រើភ្លាមៗ
        real = encoded
        print("🔵 Normal JobID detected: " .. real)
    else
        -- មិនមែន Encoded ឬ Normal
        print("❌ Invalid JobID format!")
        print("   Supported formats:")
        print("   1. Encoded: YOKUDO-...")
        print("   2. Normal: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
        return false, "Invalid JobID format"
    end
    
    print("🔵 Attempting to join server via __ServerBrowser...")
    
    -- ⭐ ប្រើ __ServerBrowser:InvokeServer("teleport", jobId)
    local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if not sb then
        print("❌ __ServerBrowser not found!")
        return false, "__ServerBrowser not found"
    end
    
    local success, err = pcall(function()
        sb:InvokeServer("teleport", real)
    end)
    
    if success then
        print("✅ Teleporting to server: " .. real)
        return true, "Joining server..."
    else
        print("❌ Failed to join: " .. tostring(err))
        return false, tostring(err)
    end
end

-- ==================================================
-- ⭐ JOIN SERVER BY JOBID (Direct - មិន Decode)
-- ==================================================
function _G.YOKUDO_JoinServerByJobId(jobId)
    if not jobId or jobId == "" then
        print("⚠️ Invalid JobId!")
        return
    end
    
    print("🔵 Attempting to join server with JobId: " .. jobId)
    
    local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if not sb then
        print("❌ __ServerBrowser not found!")
        return
    end
    
    pcall(function()
        sb:InvokeServer("teleport", jobId)
        print("✅ Teleporting to server: " .. jobId)
    end)
end

-- ==================================================
-- ⭐ DECODE JOBID (Public - សម្រាប់ប្រើខាងក្រៅ)
-- ==================================================
function _G.YOKUDO_DecodeJobId(encoded)
    return DecodeJobId(encoded)
end

print("✅ JoinServer Loaded (Decode + Join via __ServerBrowser)")
print("📌 Supports: Encoded JobID (YOKUDO-...) and Normal JobID (UUID)")
