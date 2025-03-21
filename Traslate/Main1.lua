-- ตั้งค่าภาษา
playerSession = {}
ScriptSupportEvent:registerEvent("Game.AnyPlayer.EnterGame", function(e)
    local playerid = e.eventobjid
    local r, lc, ar = Player:GetLanguageAndRegion(playerid)
    local codeLang = {"en", "cn", "tw", "tha", "jpn"} --เพิ่มภาษาที่ต้องการตรงนี้ 
    
    if r == 0 then
        local inlangcode = tonumber(lc)
        if inlangcode and inlangcode >= 0 then
            if codeLang[lc + 1] then
                playerSession[playerid] = {lc = codeLang[lc + 1], ar = ""}
            else
                playerSession[playerid] = {lc = "cn", ar = ""}
            end
        else
            playerSession[playerid] = {lc = lc, ar = ar}
        end
    else
        playerSession[playerid] = {lc = "en", ar = "EN"}
    end
    greetPlayer(playerid)
end)

T_Text = {}
function toIndex(nonIndex)
    return string.gsub(nonIndex, " ", "_")
end

function getSession(playerid)
    return playerSession[playerid] and playerSession[playerid].lc or "en"
end

T_Text_meta = {
    __index = function(table, key)
        T_Text[key] = {}
        return T_Text[key]
    end,
    __add = function(a, b)
        a[toIndex(b[3])][b[1]] = b[2]
        return a[toIndex(b[3])][b[1]]
    end,
    __sub = function(a, b)
        a[toIndex(b[2])][b[1]] = nil
    end,
    __call = function(T_Text, playerid, key)
        local sessionLang = getSession(playerid)
        if T_Text[toIndex(key)][sessionLang] == nil then
            Chat:sendSystemMsg("#RERROR: ตรวจไม่พบ'" .. toIndex(key) .. "' ในภาษา '" .. sessionLang .. "'", playerid)
            return key
        end
        return T_Text[toIndex(key)][sessionLang]
    end
}
T_Text = setmetatable(T_Text, T_Text_meta)

function createText(langcode, value, keystring)
    return T_Text + {langcode, value, keystring}
end

-- Example translations
createText("en", "Hello, World!", "GREETING")
createText("cn", "你好，世界！", "GREETING")
createText("tha", "สวัสดีโลก!", "GREETING")
createText("jpn", "こんにちは、世界！", "GREETING")
createText("en", "Welcome to the game!", "WELCOME")
createText("cn", "欢迎来到游戏！", "WELCOME")
createText("tha", "ยินดีต้อนรับสู่เกม!", "WELCOME")
createText("jpn", "ゲームへようこそ！", "WELCOME")

-- เมื่อเริ่มให้สคริปต์ตั้งค่าในตัวเเปรชนิตสตริง ที่ชื่อ LOVE โดยตั้งค่าว่า 'รักนะสาวน้อย' 
local loveTranslations = {
    en = "Love you, little girl",
    cn = "爱你，小女孩",
    tha = "รักนะสาวน้อย",
    jpn = "愛してるよ、少女"
}

for lang, text in pairs(loveTranslations) do
    createText(lang, text, "LOVE_LITTLE_GIRL")
end

--ตัวอย่าง
function greetPlayer(playerid)
    Chat:sendSystemMsg(T_Text(playerid, "GREETING"), playerid)
    Chat:sendSystemMsg(T_Text(playerid, "WELCOME"), playerid)
    Chat:sendSystemMsg(T_Text(playerid, "LOVE_LITTLE_GIRL"), playerid)
    VarLib2:setGlobalVarByName(4, "Group3", T_Text(playerid, "LOVE_LITTLE_GIRL"))
end
