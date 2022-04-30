script_name('Autoupdate script') -- название скрипта
script_author('FORMYS') -- автор скрипта
script_description('Autoupdate') -- описание скрипта

require "lib.moonloader" -- подключение библиотеки
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
local ffi        = require('ffi')

local themes = import "resource/imgui_themes.lua"

local getbonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

local stun_anims = {'DAM_armL_frmBK', 'DAM_armL_frmFT', 'DAM_armL_frmLT', 'DAM_armR_frmBK', 'DAM_armR_frmFT', 'DAM_armR_frmRT', 'DAM_LegL_frmBK', 'DAM_LegL_frmFT', 'DAM_LegL_frmLT', 'DAM_LegR_frmBK', 'DAM_LegR_frmFT', 'DAM_LegR_frmRT', 'DAM_stomach_frmBK', 'DAM_stomach_frmFT', 'DAM_stomach_frmLT', 'DAM_stomach_frmRT'}

local mainWindowState = imgui.ImBool(false)
local smooth = imgui.ImFloat(0.17)
local radius = imgui.ImFloat(0.10)
local enable = imgui.ImBool(false)
local clistFilter = imgui.ImBool(false)
local visibleCheck = imgui.ImBool(false)
local checkStuned = imgui.ImBool(false)
local Stuned = imgui.ImBool(false)
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local script_vers = 2
local script_vers_text = "1.05е"

local update_url = "https://raw.githubusercontent.com/user463545/terroblade-CHeats/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://github.com/thechampguess/scripts/blob/master/autoupdate_lesson_16.luac?raw=true" -- тут свою ссылку
local script_path = thisScript().path


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    sampRegisterChatCommand("update", cmd_update)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)

    lua_thread.create(smooth_aimbot)
   
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
    
	while true do
        wait(0)

        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end
		if wasKeyPressed(vkeys.VK_O) then
            mainWindowState.v = not mainWindowState.v
			
			 
        end
        imgui.Process = mainWindowState.v

	end
end
function imgui.OnDrawFrame()
    local posX, posY = getScreenResolution()
    if mainWindowState.v then	
        imgui.SetNextWindowPos(imgui.ImVec2(posX / 2, posY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 429), imgui.Cond.FirstUseEver)
		imgui.SwitchContext()
        themes.SwitchColorTheme(2)
        imgui.Begin('Kosak', mainWindowState)
		img = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\images\\1.png")
        imgui.Image(img, imgui.ImVec2(500, 150))
 imgui.Text ('Slava Ukraine')
        imgui.Checkbox('Enable', enable)
		
        imgui.Checkbox('Visible ', visibleCheck)
		imgui.SameLine()
        imgui.Checkbox('Check Stun', checkStuned)
		imgui.SameLine()
        imgui.Checkbox('Band Protect', clistFilter)
		imgui.Text ('Aim Radius settings')
        imgui.SliderFloat('Fov', radius, 0.0, 100.0, '%.1f')
		imgui.Text ('Aim Radius settings')
        imgui.SliderFloat('Smooth', smooth, 0.0, 50.0, '%.1f')
		
		imgui.Checkbox ('Antistan', Stuned)
	
		imgui.Text ('/li - Activation Silent Aim')
		

       

        imgui.End()
    end
end
   
    

function stan()
    if Stuned.v then 
        if data.animationId == 1084 then
			data.animationFlags = 32772
			data.animationId = 1189
		end
    end
end

function fix(angle)
    if angle > math.pi then
        angle = angle - (math.pi * 2)
    elseif angle < -math.pi then
        angle = angle + (math.pi * 2)
    end
    return angle
end
 
 
function GetNearestPed(fov)
    local maxDistance = 35
    local nearestPED = -1
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                if isCharOnScreen(handle) then
                    if not isCharDead(handle) then
                        local _, currentID = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                        local myPos = {getActiveCameraCoordinates()}
                        local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                        if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                        local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                        local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                        local distance = math.sqrt((math.pow(angle[1] - view[1], 2) + math.pow(angle[2] - view[2], 2))) * 57.2957795131
                        if distance > fov then check = true else check = false end
                        if not check then
                            local myPos = {getCharCoordinates(PLAYER_PED)}
                            local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                            if (distance < maxDistance) then
                                nearestPED = handle
                                maxDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return nearestPED
end

function GetNearestBone(handle)
    local maxDist = 20000    
    local nearestBone = -1
    bone = {42, 52, 23, 33, 3, 22, 32, 8}
    for n = 1, 8 do
        local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
        local bonePos = {GetBodyPartCoordinates(bone[n], handle)}
        local enPos = {convert3DCoordsToScreen(bonePos[1], bonePos[2], bonePos[3])}
        local distance = math.sqrt((math.pow((enPos[1] - crosshairPos[1]), 2) + math.pow((enPos[2] - crosshairPos[2]), 2)))
        if (distance < maxDist) then
            nearestBone = bone[n]
            maxDist = distance
        end 
    end
    return nearestBone
end

function GetBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getbonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end

function CheckStuned()
	for k, v in pairs(stun_anims) do
		if isCharPlayingAnim(PLAYER_PED, v) then
			return false
		end
	end
	return true
end

function smooth_aimbot()
    if enable.v and isKeyDown(vkeys.VK_RBUTTON) then
        local handle = GetNearestPed(radius.v)
        if handle ~= -1 then
            local _, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)
            local result, playerID = sampGetPlayerIdByCharHandle(handle)
            if result then
                if (checkStuned.v and not CheckStuned()) then return false end
                if (clistFilter.v and sampGetPlayerColor(myID) == sampGetPlayerColor(playerID)) then return false end
               
                local myPos = {getActiveCameraCoordinates()}
                local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                if not visibleCheck.v or (visibleCheck.v and isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, true, false, true, true)) then
                    local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                    if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                    local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                    local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                    local difference = {angle[1] - view[1], angle[2] - view[2]}
                    local smooth = {difference[1] / smooth.v, difference[2] / smooth.v}
                    setCameraPositionUnfixed((view[2] + smooth[2]), (view[1] + smooth[1]))
                end
            end
        end
    end
    return false
	
end
function cmd_update(arg)
    sampShowDialog(1000, "Автообновление v2.0", "{FFFFFF}подписка на чит\n{FFF000}Новая версия", "Закрыть", "", 0)
end
