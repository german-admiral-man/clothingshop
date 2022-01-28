local PlayerData              = {}
local near                    = false
local inMenu                  = false
local isCameraActive		  = false
currentHeading                = nil
currentDataStore              = nil
currentPrice                  = nil
currentName                   = nil
ESX                           = nil
sConfig                       = nil
local cam					  = nil
local camHeading			  = 0
local zoomOffset = 1
local camOffset = 0.3

Citizen.CreateThread(function()

    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
    end


    while sConfig == nil do
        ESX.TriggerServerCallback('clothingshop:getConfigData', function(config)
            sConfig = config
        end)
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
    createBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

Citizen.CreateThread(function()
    while true do
        Wait(700)

        for k,v in pairs(sConfig) do
            local authorisation = true

            if v.GLOBAL_SETTINGS.NEEDED_JOB.NEEDED_JOB then
                if PlayerData.job.name ~= v.GLOBAL_SETTINGS.NEEDED_JOB.JOB_NAME then
                    authorisation = false
                end
            end

            if authorisation then
                if nearMarker() then
                    near = true
                else
                    near = false
                end
            else
                Wait(500)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(10)

        if near then
            for k,v in pairs(sConfig) do
                for i=1, #v.SHOPS_COORDS.LOCATIONS, 1 do
                    local playerPed      = PlayerPedId()
                    local coords         = GetEntityCoords(playerPed)
                    local authorisation = true

                    if v.GLOBAL_SETTINGS.NEEDED_JOB.NEEDED_JOB then
                        if PlayerData.job.name ~= v.GLOBAL_SETTINGS.NEEDED_JOB.JOB_NAME then
                            authorisation = false
                        end
                    end

                    if authorisation then
                        if #(coords - v.SHOPS_COORDS.LOCATIONS[i].coords) < v.GLOBAL_SETTINGS.MARKER_SETTINGS.FLOATING_TEXT_DISTANCE then
                            if not inMenu then
								ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um auf denn Kleidungsladen zuzugreifen.')
                            end

                            if IsControlJustReleased(0, v.GLOBAL_SETTINGS.KEYBIND) then
								localSkin = nil
								TriggerEvent('skinchanger:getSkin', function(skin)
									localSkin = skin
								end)
								localDefVal = nil
                                openNUI("cloth", true)
                                for e=1, #v.SHOPS_COORDS.OUTFIT_SETTINGS, 1 do
									localDefVal = localSkin[v.SHOPS_COORDS.OUTFIT_SETTINGS[e].name]
									if localDefVal == nil then
										localDefVal = v.SHOPS_COORDS.OUTFIT_SETTINGS[e].defaultValue
									end
                                    SendNUIMessage({
                                        name = v.SHOPS_COORDS.OUTFIT_SETTINGS[e].name,
                                        label = v.SHOPS_COORDS.OUTFIT_SETTINGS[e].label,
                                        type = v.SHOPS_COORDS.OUTFIT_SETTINGS[e].type,
                                        min = v.SHOPS_COORDS.OUTFIT_SETTINGS[e].min,
                                        max = v.SHOPS_COORDS.OUTFIT_SETTINGS[e].max,
                                        cam = v.SHOPS_COORDS.OUTFIT_SETTINGS[e].camOffset,
                                        defVal = localDefVal,
                                        store = v.GLOBAL_SETTINGS.NAME,
                                    })
                                    currentHeading = v.SHOPS_COORDS.LOCATIONS[i].pedHeading
                                    currentDataStore = v.GLOBAL_SETTINGS.DATASTORE
                                    currentPrice = v.GLOBAL_SETTINGS.PRICE
                                    currentName = v.GLOBAL_SETTINGS.NAME
                                end
                            end
                        end
                    else
                        Wait(500)
                    end
                end
            end
        else
            Wait(500)
        end

    end
end)

function createBlips()
    for k,v in pairs(sConfig) do
        for i=1, #v.SHOPS_COORDS.LOCATIONS, 1 do
            if v.GLOBAL_SETTINGS.BLIP_ON then
                local authorisation = true

                if v.GLOBAL_SETTINGS.NEEDED_JOB.NEEDED_JOB then
                    if PlayerData.job.name ~= v.GLOBAL_SETTINGS.NEEDED_JOB.JOB_NAME then
                        authorisation = false
                    end
                end

                if authorisation then
                    local blip = AddBlipForCoord(v.SHOPS_COORDS.LOCATIONS[i].coords)

                    SetBlipSprite (blip, v.GLOBAL_SETTINGS.BLIP_SPRITE)
                    SetBlipDisplay(blip, v.GLOBAL_SETTINGS.BLIP_DISPLAY)
                    SetBlipScale  (blip, v.GLOBAL_SETTINGS.BLIP_SCALE)
                    SetBlipColour (blip, v.GLOBAL_SETTINGS.BLIP_COLOR)
                    SetBlipAsShortRange(blip, true)

                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString('<FONT FACE="Fire Sans">' ..v.GLOBAL_SETTINGS.NAME)
                    EndTextCommandSetBlipName(blip)
                end

            end

        end

    end
end

function nearMarker()
    local playerPed      = PlayerPedId()
    local coords         = GetEntityCoords(playerPed)

    for k,v in pairs(sConfig) do

        for i=1, #v.SHOPS_COORDS.LOCATIONS, 1 do
            local shopMarkerDistance = #(coords - v.SHOPS_COORDS.LOCATIONS[i].coords)
            if shopMarkerDistance <= 3 then
                return true
            end
        end

    end
end

function CreateSkinCam(camOffsett)
	camOffset = camOffsett
end

function CreateSkinCam2()
	if not DoesCamExist(cam) then
		cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
	end

	SetCamActive(cam, true)
	RenderScriptCams(true, true, 500, true, true)

	local playerPed = PlayerPedId()
	local playerHeading = GetEntityHeading(playerPed)
	if playerHeading + 94 < 360.0 then
		camHeading = playerHeading + 94.0
	elseif playerHeading + 94 >= 360.0 then
		camHeading = playerHeading - 266.0 --194
	end

	isCameraActive = true
	SetCamCoord(cam, GetEntityCoords(GetPlayerPed(-1)))
end

function DeleteSkinCam()
	isCameraActive = false
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 500, true, true)
	cam = nil
	zoomOffset = 1
	camOffset = 0.3
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if isCameraActive == true then
			local playerPed = PlayerPedId()
			local coords    = GetEntityCoords(playerPed)
			
			local angle = camHeading * math.pi / 180.0
			local theta = {
				x = math.cos(angle),
				y = math.sin(angle)
			}

			local pos = {
				x = coords.x + (zoomOffset * theta.x),
				y = coords.y + (zoomOffset * theta.y)
			}

			local angleToLook = camHeading - 200.0 --140.0
			if angleToLook > 360 then
				angleToLook = angleToLook - 360
			elseif angleToLook < 0 then
				angleToLook = angleToLook + 360
			end

			angleToLook = angleToLook * math.pi / 180.0
			local thetaToLook = {
				x = math.cos(angleToLook),
				y = math.sin(angleToLook)
			}

			local posToLook = {
				x = coords.x + (zoomOffset * thetaToLook.x),
				y = coords.y + (zoomOffset * thetaToLook.y)
			}

			SetCamCoord(cam, pos.x, pos.y, coords.z + camOffset)
			PointCamAtCoord(cam, posToLook.x, posToLook.y, coords.z + camOffset)
		else
			Citizen.Wait(500)
		end
	end

end)

function ESXnotif(text)
    ESX.ShowNotification(text)
end

function openNUI(type, enable, resetChar)
    if type == "cloth" then
        if enable == true then
            SendNUIMessage({
                clothing_system = true
            })
            SetNuiFocus(true, true)
            inMenu = true
			CreateSkinCam2()
        else
            SendNUIMessage({
                clothing_system = false
            })
            SetNuiFocus(false, false)
            DeleteSkinCam()
            inMenu = false
            if resetChar then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
            end
        end
    end
end

RegisterNUICallback('close', function(data, cb)
    openNUI("cloth", false, true)
end)

RegisterNUICallback('movePed', function(data, cb)
    local playerPed = PlayerPedId()
    SetEntityHeading(playerPed, currentHeading)
end)

RegisterNUICallback('getSavedOutfits', function(data, cb)
    ESX.TriggerServerCallback('clothingshop:getOutfits', function(dressing)
        local elements = {}

        for i=1, #dressing, 1 do
            SendNUIMessage({
                outfitLabel = dressing[i],
                outfitValue = i,
                name = currentName
            })
        end
    end, currentDataStore)
end)

RegisterNUICallback('setCam', function(data, cb)
    CreateSkinCam(data.cam)
end)

RegisterNUICallback('Notification', function(data, cb)
    ESXnotif(data.text)
end)

RegisterNUICallback('setCloth', function(data, cb)
    TriggerEvent("skinchanger:getSkin", function(skin)
        skin[data.name] = data.result
        TriggerEvent("skinchanger:loadSkin", skin)
        changeCloth = true
    end)
end)

RegisterNUICallback('deleteOutfit', function(data, cb)
    TriggerServerEvent('clothingshop:deleteOutfit', data.outfit, data.label, currentDataStore)
end)

RegisterNUICallback('dressOutfit', function(data, cb)
    TriggerEvent('skinchanger:getSkin', function(skin)
        ESX.TriggerServerCallback('clothingshop:getPlayerOutfit', function(clothes)

            TriggerEvent('skinchanger:loadClothes', skin, clothes)
            TriggerEvent('esx_skin:setLastSkin', skin)

            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('esx_skin:save', skin)
            end)

            HasLoadCloth = true
        end, tonumber(data.outfit), data.label, currentDataStore)
    end)
end)

RegisterNUICallback('saveOutfit', function(data, cb)

    ESX.TriggerServerCallback('clothingshop:pay', function(haveMoney)
        if haveMoney then
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('clothingshop:saveOutfit', currentDataStore, data.name, skin)
            end)
            openNUI("cloth", false, false)
        else
            openNUI("cloth", false, true)
        end
    end, currentPrice, data.name)
end)


RegisterNetEvent("clothingshop:sendNotify", function(text)
    ESXnotif(text)
end)

RegisterNUICallback('character_rotation', function(data, cb)
	charRotation(data.rotationType)
end)

function charRotation(type)
	local heading = currentHeading
	
	if type == "left" then 
		SetEntityHeading(PlayerPedId(), currentHeading - 20)
		currentHeading = currentHeading - 20 
	elseif type == "right" then 
		SetEntityHeading(PlayerPedId(), currentHeading + 20)
		currentHeading = currentHeading + 20
	end 
end
