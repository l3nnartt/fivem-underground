local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

local garages = {
    {vector3(375.47, -1619.43, 29.29), vector3(378.95, -1614.79, 29.29), 228.9 },--abschlepphof
    {vector3(22.3, -1103.04, 38.15), vector3(18.85, -1098.05, 38.15), 68.15 },--waffenladen
    {vector3(213.73, -809.13, 31.01), vector3(222.79, -804.43, 30.7), 247.06 },--mp
    {vector3(-361.2, -153.59, 38.9), vector3(-363.95, -147.54, 38.24), 121.18 }, --lsc
    {vector3(-1184.31, -1509.44, 4.65), vector3(-1184.33, -1501.51, 4.38), 216.64 }, --vespucci
    {vector3(1737.6, 3710.2, 34.14), vector3(1737.11, 3716.93, 34.08), 17.73 }, --sandy
    {vector3(105.29, 6613.77, 32.4), vector3(109.18, 6610.43, 31.81), 316.66 }, --paleto
    {vector3(-978.75, -2688.29, 13.83), vector3(-975.66, -2691.39, 13.83), 149.56 }, --airport
    {vector3(-3.48,-1736.93,28.31), vector3(-5.79,-1741.81,29.30), 50.19 }, --mosleys/grove
    {vector3(-80.48,-817.21,35.04), vector3(-84.02,-821.20,35.23), 346.66 }, --mazebank
    {vector3(-64.66,881.74,234.85), vector3(-66.38,891.77,235.56), 115.98 }, --vinewood hills
    {vector3(-1365.93,54.24,54.10), vector3(-1370.51,54.81,53.70), 1.16 }, --golfplatz
    {vector3(-1159.69,-739.52,18.89), vector3(-1146.57,-746.16,19.06), 104.92 }, --vespucci pd
    {vector3(-1539.03,-617.24,22.39), vector3(-1534.41,-619.85,24.41), 264.72 }, --crips hood
    {vector3(-795.96,336.04,85.7), vector3(-800.21,331.94,84.7), 175.15 }, --equlips tower
}

local enableField = false

function AddCar(plate)
    SendNUIMessage({
        action = 'add',
        plate = plate
    }) 
end

function toggleField(enable)
    SetNuiFocus(enable, enable)
    enableField = enable

    if enable then
        SendNUIMessage({
            action = 'open'
        }) 
    else
        SendNUIMessage({
            action = 'close'
        }) 
    end
end

AddEventHandler('onResourceStart', function(name)
    if GetCurrentResourceName() ~= name then
        return
    end

    toggleField(false)
end)

RegisterNUICallback('escape', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)

    cb('ok')
end)

RegisterNUICallback('enable-parkout', function(data, cb)
    
    ESX.TriggerServerCallback('ps_garage:loadVehicles', function(vehicles)
        for key, value in pairs(vehicles) do
            AddCar(value.plate)
        end
    end)
    
    cb('ok')
end) 

RegisterNUICallback('enable-parking', function(data, cb)
    
    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(-1)), 25.0)

    for key, value in pairs(vehicles) do
        ESX.TriggerServerCallback('ps_garage:isOwned', function(owned)

            if owned then
                AddCar(GetVehicleNumberPlateText(value))
            end
    
        end, GetVehicleNumberPlateText(value))
    end
    
    cb('ok')
end) 

local usedGarage

RegisterNUICallback('park-out', function(data, cb)
    
    ESX.TriggerServerCallback('ps_garage:loadVehicle', function(vehicle)
        local x,y,z = table.unpack(garages[usedGarage][2])
        local props = json.decode(vehicle[1].vehicle)

        ESX.Game.SpawnVehicle(props.model, {
            x = x,
            y = y,
            z = z + 1
        }, garages[usedGarage][3], function(callback_vehicle)
            ESX.Game.SetVehicleProperties(callback_vehicle, props)
            SetVehRadioStation(callback_vehicle, "OFF")
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
        end)

    end, data.plate)

    TriggerServerEvent('ps_garage:changeState', data.plate, 0)
    
    cb('ok')
end)

RegisterNUICallback('park-in', function(data, cb)
    
    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(-1)), 25.0)

    for key, value in pairs(vehicles) do
        if GetVehicleNumberPlateText(value) == data.plate then
            TriggerServerEvent('ps_garage:saveProps', data.plate, ESX.Game.GetVehicleProperties(value))
            TriggerServerEvent('ps_garage:changeState', data.plate, 1)
            ESX.Game.DeleteVehicle(value)
        end
    end

    cb('ok')
end)

--[[Citizen.CreateThread(function()
    while true do
        Wait(0)
        for key, value in pairs(garages) do
            DrawMarker(20, value[1], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, true, false, false, false)
        end
    end
end)]]

Citizen.CreateThread(function()
    while true do
        Wait(0)

        for key, value in pairs(garages) do
            local dist = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), value[1])

            if dist <= 2.0 then
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um auf die Garage zuzugreifen")

                if IsControlJustReleased(0, 38) then
                    toggleField(true)
                    usedGarage = key
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    for _, coords in pairs(garages) do
        local blip = AddBlipForCoord(coords[1])

        SetBlipSprite(blip, 473)
        SetBlipScale(blip, 0.9)
        SetBlipColour(blip, 4)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garage")
        EndTextCommandSetBlipName(blip)
    end
end)