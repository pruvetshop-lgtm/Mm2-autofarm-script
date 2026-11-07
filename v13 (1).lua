-- 🎃 MM2 Halloween AutoFarm | Delta (v2)
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local Debris          = game:GetService("Debris")
local VirtualUser     = game:GetService("VirtualUser")
local GuiService      = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local env = (getgenv and getgenv()) or _G
if env.HalloweenFarm then pcall(env.HalloweenFarm) end

local player = Players.LocalPlayer
local DEPTH = 4
local AUTO_REJOIN = true
local AUTO_START  = false

---------------------------------------------------------------------
-- ВЕРСИЯ И ЧЕНДЖЛОГ
---------------------------------------------------------------------
local VERSION      = "0.13"
local VERSION_NAME = "Конструктор"
local STAGE        = "BETA"

-- новые версии добавляй СВЕРХУ
local CHANGELOG = {
    { ver = "0.13", name = "Конструктор", items = {
        "Убрана вкладка «Дополнительно» с фото (скрипт стал легче и запускается стабильнее)",
        "Новая вкладка «Настройки»: размер окна, положение, значки вкладок",
        "Летающие эмодзи на фоне меню: наборы, свои эмодзи, количество, скорость, можно выключить",
        "Визуал: растяг экрана по горизонтали (с настройкой силы) и аура на своём персонаже",
    }},
    { ver = "0.12", name = "Секрет", items = {
        "Убрана вкладка «Музыка»",
        "Новая вкладка «Дополнительно» (в доработке)",
    }},
    { ver = "0.11", name = "Призрак", items = {
        "Новая вкладка «Игрок»: полёт, ноклип, своя скорость ходьбы, прыжок в воздухе, невидимость (бета)",
        "Кнопки «Перезайти» и «Сменить сервер»",
        "Исправлены ауры и линии: больше не зависят от включённого ESP; аура стала силовым полем",
    }},
    { ver = "0.10", name = "Неон", items = {
        "Новая вкладка «Визуал»: ESP, линии к игрокам, ауры, трейсеры пуль и ножей",
        "ESP в лобби снова серый: роли показываются только игрокам на карте",
        "Современный интерфейс: переключатели-пилюли, раскрывающиеся вкладки, мягкие рамки",
        "Меню оформления: обычный шрифт, читаемые цвета, метка акцента у каждого пресета",
    }},
    { ver = "0.9", name = "Художник", items = {
        "Кастомизация интерфейса: кнопка 🎨 в шапке окна",
        "7 пресетов: Хеллоуин, Любовь, Зима, Рождество, Солнце, Небо, Море",
        "Настройка прозрачности окна",
        "Выбор темы запоминается (если Delta умеет сохранять файлы)",
    }},
    { ver = "0.8", name = "Снайпер", items = {
        "Шериф: мардер определяется по данным игры (рюкзак чужого игрока не виден клиенту)",
        "Выстрел сквозь стены идёт, пока мардер не умрёт, и только потом ресет",
        "ESP, Silent Aim и аимбот тоже берут роли из данных игры",
    }},
    { ver = "0.7", name = "Охотник", items = {
        "Silent Aim переписан: ловит выстрел и по вызову пистолета, и по mouse.Hit",
        "Новый аимбот: центр экрана наводится на мардера",
        "Вкладка «Лог» с версиями и списком изменений",
    }},
    { ver = "0.6", name = "Ведьма", items = {
        "Вкладка «Бой»: ESP с ролями (в лобби прозрачный)",
        "Килаура с настройкой радиуса",
        "Аим броска ножа с предикцией",
        "Silent Aim для шерифа (первая версия)",
    }},
    { ver = "0.5", name = "Паутина", items = {
        "Персонаж больше не улетает за карту: удержание на месте",
        "Фарм не летит к уже собранным конфетам",
        "Исправлены зависания и остановки фарма",
        "Телепорт-фарм стал надёжнее",
    }},
    { ver = "0.4", name = "Летучая мышь", items = {
        "Анти-АФК и авто-перезаход на тот же сервер",
        "Честный счётчик: считаются только собранные конфеты",
        "Шериф стреляет в мардера и ждёт его смерти перед ресетом",
        "Вкладка «Авторы»",
    }},
    { ver = "0.3", name = "Привидение", items = {
        "Скорость фарма от 1 до 15, телепорт стал медленнее",
        "Персонаж стоит в лобби и не летит к монетам",
        "Звуки нажатия в меню",
    }},
    { ver = "0.2", name = "Мешок конфет", items = {
        "Действие при полном мешке (50): респаун или роль → респаун",
    }},
    { ver = "0.1", name = "Тыква", items = {
        "Первый релиз: автофарм конфет",
        "Три режима: под землёй, телепорт, полёт",
        "Регулировка скорости, управление для ПК и телефона",
        "Хэллоуинское меню",
    }},
}

local function changelogText(accentHex, okHex)
    local out = {}
    for idx, e in ipairs(CHANGELOG) do
        local tag = (idx == 1) and ("  <font color=\"" .. okHex .. "\">текущая · " .. STAGE .. "</font>") or ""
        table.insert(out, "<font color=\"" .. accentHex .. "\"><b>v" .. e.ver .. " «" .. e.name .. "»</b></font>" .. tag)
        for _, it in ipairs(e.items) do
            table.insert(out, "• " .. it)
        end
        table.insert(out, "")
    end
    return table.concat(out, "\n")
end

local S = { Enabled = false, Mode = "Fly", Speed = 8, Collected = 0,
            Bag = 0, BagLimit = 50, OnFull = "Respawn", Busy = false }
local alive, conns, blacklist = true, {}, {}
local done  = setmetatable({}, { __mode = "k" }) -- конфеты, собранные нами (навсегда)
local fails = setmetatable({}, { __mode = "k" }) -- счётчик неудачных попыток
local container, hold
local lastSafe, lastSafeTime = nil, 0
local lastProgress, busySince = os.clock(), 0
local recoverTimes = {}

local function connect(sig, fn)
    local c = sig:Connect(fn)
    table.insert(conns, c)
    return c
end

---------------------------------------------------------------------
-- АНТИ-АФК
---------------------------------------------------------------------
connect(player.Idled, function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

---------------------------------------------------------------------
-- АВТО-ПЕРЕЗАХОД НА ТОТ ЖЕ СЕРВЕР
---------------------------------------------------------------------
local rejoining, attempts = false, 0
local function rejoin()
    if rejoining or not AUTO_REJOIN then return end
    rejoining = true
    task.spawn(function()
        while alive and attempts < 6 do
            attempts += 1
            task.wait(attempts == 1 and 2 or 4)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end)
            task.wait(10)
        end
        if alive then
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end
    end)
end

task.spawn(function()
    local ok, overlay = pcall(function()
        return CoreGui:WaitForChild("RobloxPromptGui", 15):WaitForChild("promptOverlay", 15)
    end)
    if ok and overlay then
        connect(overlay.ChildAdded, function(c)
            if c.Name == "ErrorPrompt" then rejoin() end
        end)
    end
end)
connect(GuiService.ErrorMessageChanged, function()
    local ok, msg = pcall(function() return GuiService:GetErrorMessage() end)
    if ok and msg and msg ~= "" then rejoin() end
end)

---------------------------------------------------------------------
-- БАЗОВЫЕ ФУНКЦИИ
---------------------------------------------------------------------
local function getHRP()
    local ch = player.Character
    return ch and ch:FindFirstChild("HumanoidRootPart"), ch
end

local function coinPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function findContainer()
    if container and container.Parent then return container end
    container = workspace:FindFirstChild("CoinContainer", true)
    return container
end

local function isActive(p)
    return p ~= nil and p.Parent ~= nil and p:IsDescendantOf(workspace)
        and not p:GetAttribute("Collected")
end

-- видна ли конфета (у собранной визуал обычно скрывается)
local function isVisible(p)
    if p.Transparency < 0.95 then return true end
    for _, d in ipairs(p:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 0.95 then return true end
    end
    return false
end

local function nearestCoin(hrp)
    local cc = findContainer()
    if not cc then return nil, false end
    local best, bestD, bestVis
    local now = os.clock()
    for _, obj in ipairs(cc:GetChildren()) do
        local p = coinPart(obj)
        if p and isActive(p) and not done[p] and (not blacklist[p] or blacklist[p] < now) then
            local vis = isVisible(p)
            local d = (p.Position - hrp.Position).Magnitude
            local better
            if bestD == nil then
                better = true
            elseif vis ~= bestVis then
                better = vis -- видимые конфеты в приоритете
            else
                better = d < bestD
            end
            if better then best, bestD, bestVis = p, d, vis end
        end
    end
    return best, bestVis
end

local function anyCoinNear(hrp, r)
    local cc = findContainer()
    if not cc then return false end
    for _, obj in ipairs(cc:GetChildren()) do
        local p = coinPart(obj)
        if p and (p.Position - hrp.Position).Magnitude < r then return true end
    end
    return false
end

local function mapBox()
    local cc = findContainer()
    local map = cc and cc.Parent
    if map and map:IsA("Model") then
        local ok, cf, size = pcall(function() return map:GetBoundingBox() end)
        if ok then return cf, size end
    end
    return nil, nil
end

local function inMap(hrp, margin)
    margin = margin or 40
    local cf, size = mapBox()
    if cf then
        local rel = cf:PointToObjectSpace(hrp.Position)
        if math.abs(rel.X) <= size.X / 2 + margin
            and math.abs(rel.Y) <= size.Y / 2 + margin
            and math.abs(rel.Z) <= size.Z / 2 + margin then
            return true
        end
    end
    return anyCoinNear(hrp, 250)
end

local function touch(ch, hrp, part)
    if not firetouchinterest then return end
    for _, bp in ipairs({ hrp, ch:FindFirstChild("Head") }) do
        pcall(function()
            firetouchinterest(bp, part, 0)
            firetouchinterest(bp, part, 1)
        end)
    end
end

---------------------------------------------------------------------
-- УДЕРЖАНИЕ ПЕРСОНАЖА (чтобы не падал и не улетал)
---------------------------------------------------------------------
local function applyHold()
    local hrp, ch = getHRP()
    if not hrp then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    if not (hold and hold.Parent == hrp) then
        if hold then pcall(function() hold:Destroy() end) end
        hold = Instance.new("BodyVelocity")
        hold.Name = "FarmHold"
        hold.Velocity = Vector3.zero
        hold.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        hold.P = 1e4
        hold.Parent = hrp
    end
end

local function releaseHold()
    if hold then
        pcall(function() hold:Destroy() end)
        hold = nil
    end
    local _, ch = getHRP()
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- плавное движение к цели; цель пересчитывается каждый кадр
local function moveTo(hrp, getTarget, speed)
    local first = getTarget()
    if not first then return false end
    local t0 = os.clock()
    local maxT = 2 + (first - hrp.Position).Magnitude / speed
    while S.Enabled and not S.Busy and hrp.Parent do
        local target = getTarget()
        if not target then return false end
        local dt = RunService.Heartbeat:Wait()
        local pos = hrp.Position
        local diff = target - pos
        local dist = diff.Magnitude
        local step = speed * dt
        if dist <= step then
            hrp.CFrame = CFrame.new(target) * hrp.CFrame.Rotation
            return true
        end
        hrp.CFrame = CFrame.new(pos + diff.Unit * step) * hrp.CFrame.Rotation
        if os.clock() - t0 > maxT then return false end
    end
    return false
end

---------------------------------------------------------------------
-- ПОДСЧЁТ РЕАЛЬНО СОБРАННЫХ КОНФЕТ
---------------------------------------------------------------------
local updateStatus
local refreshStart
local collectedRemote, lastHookTry = nil, 0

local function onCollected(current)
    S.Collected += 1
    lastProgress = os.clock()
    if type(current) == "number" and current >= 0 and current <= 200 then
        S.Bag = current
    else
        S.Bag += 1
    end
    updateStatus()
end

local function tryHookRemote()
    if collectedRemote or os.clock() - lastHookTry < 5 then return end
    lastHookTry = os.clock()
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") and d.Name == "CoinCollected" then
            collectedRemote = d
            connect(d.OnClientEvent, function(_, current)
                onCollected(current)
            end)
            if updateStatus then updateStatus() end
            return
        end
    end
end

-- true, если конфета реально собрана
local function waitCollected(coin, before, wasVisible)
    local t0 = os.clock()
    while os.clock() - t0 < 0.7 do
        if S.Collected > before then return true end
        local gone = (not coin:IsDescendantOf(workspace)) or (wasVisible and not isVisible(coin))
        if gone then
            if collectedRemote then
                local t1 = os.clock()
                while os.clock() - t1 < 0.25 do
                    if S.Collected > before then return true end
                    task.wait(0.03)
                end
            end
            if S.Collected > before then return true end
            onCollected(nil)
            return true
        end
        task.wait(0.04)
    end
    return S.Collected > before
end

---------------------------------------------------------------------
-- ДЕЙСТВИЕ РОЛИ ПРИ ПОЛНОМ МЕШКЕ
---------------------------------------------------------------------
local function getTool(name)
    local ch = player.Character
    local bp = player:FindFirstChildOfClass("Backpack")
    return (ch and ch:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end

local function aliveHRP(plr)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return r end
    return nil
end

-- РОЛИ ИЗ ДАННЫХ ИГРЫ.
-- Рюкзак чужого игрока клиенту не виден, поэтому по ножу в рюкзаке мардера
-- не найти, роли берём у игры (GetPlayerData / PlayerDataChanged).
local FX = {}   -- визуальные эффекты (заполняется ниже)
local roleCache = {}   -- [ник игрока] = "Murderer" / "Sheriff" / "Hero" / "Innocent"
local roleRemote, roleEventHooked = nil, false

local function applyRoleData(data)
    if type(data) ~= "table" then return false end
    local fresh, any = {}, false
    for name, info in pairs(data) do
        if type(info) == "table" and type(info.Role) == "string" then
            fresh[tostring(name)] = info.Role
            any = true
        end
    end
    if any then roleCache = fresh end
    return any
end

local function refreshRoles()
    if not roleEventHooked then
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("RemoteEvent") and d.Name == "PlayerDataChanged" then
                roleEventHooked = true
                connect(d.OnClientEvent, function(data) applyRoleData(data) end)
                break
            end
        end
    end
    if not roleRemote or not roleRemote.Parent then
        roleRemote = nil
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("RemoteFunction") and d.Name == "GetPlayerData" then
                roleRemote = d
                break
            end
        end
    end
    if not roleRemote then return false end
    local ok, data = pcall(function() return roleRemote:InvokeServer() end)
    return ok and applyRoleData(data)
end

local function findMurderer()
    -- 1) по данным игры
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and roleCache[plr.Name] == "Murderer" then
            return plr
        end
    end
    -- 2) запасной вариант: нож в руках (виден, только когда он экипирован)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local c = plr.Character
            if c and c:FindFirstChild("Knife") then return plr end
        end
    end
    return nil
end

local function shootAt(gun, pos)
    local sent = false
    for _, d in ipairs(gun:GetDescendants()) do
        if d:IsA("RemoteFunction") and d.Parent and d.Parent.Name == "CreateBeam" then
            local ok = pcall(function() d:InvokeServer(1, pos, "AH2") end)
            if ok then
                if FX.myShot then task.defer(FX.myShot, pos) end
                return true
            end
            sent = true
        end
    end
    if not sent then warn("[Farm] у пистолета не найден CreateBeam, стреляю обычным способом") end
    local cam = workspace.CurrentCamera
    cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
    gun:Activate()
    return false
end

local function doRoleAction()
    local hrp, ch = getHRP()
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    local knife, gun = getTool("Knife"), getTool("Gun")
    local t0 = os.clock()

    if knife then
        hum:EquipTool(knife)
        for _, plr in ipairs(Players:GetPlayers()) do
            if os.clock() - t0 > 8 then break end
            local th = plr ~= player and aliveHRP(plr)
            if th then
                hrp.CFrame = th.CFrame * CFrame.new(0, 0, 2)
                task.wait(0.1)
                knife:Activate()
                local handle = knife:FindFirstChild("Handle")
                if handle and firetouchinterest then
                    pcall(function()
                        firetouchinterest(handle, th, 0)
                        firetouchinterest(handle, th, 1)
                    end)
                end
                task.wait(0.25)
            end
        end

    elseif gun then
        -- Шериф: стреляем в мардера сквозь стены, пока он не умрёт
        local lastShot, lastRoles, noMurdSince = 0, 0, nil
        pcall(refreshRoles)
        lastRoles = os.clock()
        while os.clock() - t0 < 30 do
            if hum.Health <= 0 then return end

            if os.clock() - lastRoles > 1 then
                lastRoles = os.clock()
                pcall(refreshRoles)
            end

            local murd = findMurderer()
            if not murd then
                -- мардера не видно: ждём пару секунд, вдруг роли ещё не пришли
                noMurdSince = noMurdSince or os.clock()
                if os.clock() - noMurdSince > 4 then break end
                task.wait(0.2)
            else
                noMurdSince = nil
                local th = aliveHRP(murd)
                if not th then break end -- мардер мёртв: можно ресетиться

                gun = getTool("Gun")
                if not gun then break end
                if gun.Parent ~= ch then
                    hum:EquipTool(gun)
                    local e0 = os.clock()
                    while gun.Parent ~= ch and os.clock() - e0 < 1 do task.wait(0.05) end
                end

                if os.clock() - lastShot > 1.2 then
                    lastShot = os.clock()
                    local pos = th.Position + th.AssemblyLinearVelocity * 0.12
                    shootAt(gun, pos)
                end
                task.wait(0.1)
            end
        end
    end
end

local function handleFull()
    S.Busy = true
    busySince = os.clock()
    releaseHold() -- иначе PlatformStand мешает взять оружие
    if S.OnFull == "Role" then
        local ok, err = pcall(doRoleAction)
        if not ok then warn("[Farm] role:", err) end
    end
    releaseHold()
    local _, ch = getHRP()
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
    S.Bag = 0
    blacklist = {}
    updateStatus()
    S.Busy = false
end

---------------------------------------------------------------------
-- ОСНОВНОЙ ШАГ ФАРМА
---------------------------------------------------------------------
local function tryRecover(hrp)
    -- вылетели за карту сразу после нормальной позиции: возвращаем назад
    if not lastSafe or os.clock() - lastSafeTime > 2 then return false end
    if not (container and container.Parent) then return false end
    local now = os.clock()
    local fresh = {}
    for _, t in ipairs(recoverTimes) do
        if now - t < 8 then table.insert(fresh, t) end
    end
    recoverTimes = fresh
    if #recoverTimes >= 3 then return false end
    table.insert(recoverTimes, now)
    hrp.CFrame = lastSafe
    hrp.AssemblyLinearVelocity = Vector3.zero
    lastSafeTime = now
    return true
end

local function farmStep()
    tryHookRemote()

    local hrp, ch = getHRP()
    if not hrp then task.wait(0.5) return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then task.wait(0.5) return end

    if not inMap(hrp) then
        if tryRecover(hrp) then task.wait(0.2) return end
        task.wait(0.5)
        return
    end

    applyHold()
    lastSafe, lastSafeTime = hrp.CFrame, os.clock()

    local coin, wasVisible = nearestCoin(hrp)
    if not coin then task.wait(0.3) return end

    -- конфета всё ещё на месте и не собрана (нами или другим игроком)?
    local function stillThere()
        return isActive(coin) and not done[coin] and (not wasVisible or isVisible(coin))
    end

    local before = S.Collected
    local arrived = true

    if S.Mode == "Teleport" then
        if not stillThere() then
            blacklist[coin] = os.clock() + 2
            return
        end
        hrp.CFrame = CFrame.new(coin.Position)
        task.wait()
        arrived = stillThere()
        if arrived then hrp.CFrame = CFrame.new(coin.Position) end
    elseif S.Mode == "Fly" then
        arrived = moveTo(hrp, function()
            return stillThere() and coin.Position
        end, S.Speed * 4)
    else
        arrived = moveTo(hrp, function()
            return stillThere() and (coin.Position - Vector3.new(0, DEPTH, 0))
        end, S.Speed * 4)
    end

    if not arrived or not stillThere() then
        blacklist[coin] = os.clock() + 2
        return
    end

    touch(ch, hrp, coin)
    local ok = waitCollected(coin, before, wasVisible)
    if ok then
        done[coin] = true -- больше никогда не летим к этой конфете
    else
        fails[coin] = (fails[coin] or 0) + 1
        blacklist[coin] = os.clock() + (fails[coin] >= 2 and 25 or 2.5)
    end

    if S.Mode == "Teleport" then
        task.wait(7 / S.Speed)
    end

    if S.Bag >= S.BagLimit and S.OnFull ~= "Off" then handleFull() end
end

task.spawn(function()
    while alive do
        if S.Busy and os.clock() - busySince > 45 then S.Busy = false end

        if S.Enabled and not S.Busy then
            -- если долго нет прогресса: сбрасываем чёрный список и удержание
            if os.clock() - lastProgress > 15 then
                blacklist = {}
                releaseHold()
                lastProgress = os.clock()
            end
            local ok, err = pcall(farmStep)
            if not ok then
                warn("[Farm]", err)
                task.wait(0.3)
            end
        else
            task.wait(0.2)
        end
        task.wait()
    end
end)

connect(RunService.Stepped, function()
    if not S.Enabled then return end
    local hrp, ch = getHRP()
    if not ch then return end
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end)

---------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------
-- ТЕМЫ ОФОРМЛЕНИЯ
-- ORANGE = главный акцент, PURPLE = рамки, GREEN = статус, LILAC = подписи,
-- TXT_ACC = текст на акценте, TXT_LIGHT = светлый текст, MUTED = приглушённый,
-- LOGTXT = текст лога, START_BG = кнопка «Старт», TOGGLE_ON = включённый переключатель,
-- G1/G2 = градиент окна. Внутри одной темы все цвета должны отличаться.
local function C3(r, g, b) return Color3.fromRGB(r, g, b) end
local THEME_ORDER = { "Хеллоуин", "Любовь", "Зима", "Рождество", "Солнце", "Небо", "Море" }
local THEMES = {
    ["Хеллоуин"] = { icon1 = "🎃", icon2 = "🦇",
        BG = C3(20, 12, 30),  DARK2 = C3(38, 22, 56),  ORANGE = C3(255, 128, 0), PURPLE = C3(130, 60, 200),
        GREEN = C3(140, 255, 90), RED = C3(220, 50, 50), LILAC = C3(200, 170, 255),
        TXT_ACC = C3(20, 10, 5), TXT_LIGHT = C3(255, 200, 140), MUTED = C3(150, 120, 190),
        LOGTXT = C3(220, 200, 255), START_BG = C3(230, 100, 0), TOGGLE_ON = C3(90, 45, 10),
        G1 = C3(40, 18, 60), G2 = C3(14, 8, 22) },
    ["Любовь"] = { icon1 = "💖", icon2 = "💘",
        BG = C3(38, 10, 28),  DARK2 = C3(66, 18, 48),  ORANGE = C3(255, 95, 150), PURPLE = C3(200, 60, 110),
        GREEN = C3(255, 190, 215), RED = C3(210, 40, 70), LILAC = C3(255, 170, 205),
        TXT_ACC = C3(45, 5, 25), TXT_LIGHT = C3(255, 205, 225), MUTED = C3(200, 130, 165),
        LOGTXT = C3(255, 225, 238), START_BG = C3(235, 60, 120), TOGGLE_ON = C3(110, 25, 65),
        G1 = C3(70, 14, 50), G2 = C3(28, 6, 22) },
    ["Зима"] = { icon1 = "❄", icon2 = "⛄",
        BG = C3(12, 24, 42),  DARK2 = C3(24, 48, 78),  ORANGE = C3(140, 210, 255), PURPLE = C3(90, 150, 210),
        GREEN = C3(200, 245, 255), RED = C3(230, 90, 110), LILAC = C3(190, 220, 245),
        TXT_ACC = C3(6, 18, 34), TXT_LIGHT = C3(215, 235, 255), MUTED = C3(130, 165, 200),
        LOGTXT = C3(235, 245, 255), START_BG = C3(70, 150, 220), TOGGLE_ON = C3(30, 70, 115),
        G1 = C3(30, 58, 92), G2 = C3(8, 16, 30) },
    ["Рождество"] = { icon1 = "🎄", icon2 = "🎅",
        BG = C3(14, 32, 20),  DARK2 = C3(30, 58, 36),  ORANGE = C3(255, 200, 60), PURPLE = C3(190, 40, 50),
        GREEN = C3(120, 240, 130), RED = C3(225, 50, 50), LILAC = C3(255, 225, 160),
        TXT_ACC = C3(30, 20, 2), TXT_LIGHT = C3(255, 235, 190), MUTED = C3(160, 190, 150),
        LOGTXT = C3(255, 245, 220), START_BG = C3(190, 35, 45), TOGGLE_ON = C3(70, 30, 30),
        G1 = C3(34, 66, 40), G2 = C3(10, 22, 14) },
    ["Солнце"] = { icon1 = "☀", icon2 = "🌻",
        BG = C3(60, 32, 6),   DARK2 = C3(100, 58, 12), ORANGE = C3(255, 200, 40), PURPLE = C3(255, 140, 30),
        GREEN = C3(255, 240, 150), RED = C3(230, 70, 40), LILAC = C3(255, 220, 150),
        TXT_ACC = C3(50, 25, 0), TXT_LIGHT = C3(255, 236, 190), MUTED = C3(215, 170, 100),
        LOGTXT = C3(255, 246, 220), START_BG = C3(240, 150, 20), TOGGLE_ON = C3(125, 70, 10),
        G1 = C3(105, 60, 10), G2 = C3(40, 20, 4) },
    ["Небо"] = { icon1 = "☁", icon2 = "🕊",
        BG = C3(36, 86, 150), DARK2 = C3(62, 120, 190), ORANGE = C3(255, 252, 235), PURPLE = C3(160, 205, 245),
        GREEN = C3(255, 244, 170), RED = C3(235, 90, 100), LILAC = C3(215, 235, 255),
        TXT_ACC = C3(20, 50, 90), TXT_LIGHT = C3(235, 245, 255), MUTED = C3(180, 210, 240),
        LOGTXT = C3(255, 255, 255), START_BG = C3(255, 175, 60), TOGGLE_ON = C3(40, 150, 200),
        G1 = C3(90, 160, 225), G2 = C3(30, 70, 130) },
    ["Море"] = { icon1 = "🌊", icon2 = "🐚",
        BG = C3(6, 30, 40),   DARK2 = C3(12, 62, 78),  ORANGE = C3(40, 220, 200), PURPLE = C3(30, 150, 180),
        GREEN = C3(130, 255, 225), RED = C3(240, 100, 100), LILAC = C3(160, 230, 235),
        TXT_ACC = C3(2, 25, 30), TXT_LIGHT = C3(190, 245, 245), MUTED = C3(100, 170, 180),
        LOGTXT = C3(220, 255, 255), START_BG = C3(10, 150, 170), TOGGLE_ON = C3(14, 90, 100),
        G1 = C3(12, 70, 92), G2 = C3(4, 16, 26) },
}
local ROLES = { "BG", "DARK2", "ORANGE", "PURPLE", "GREEN", "RED", "LILAC", "TXT_ACC",
                "TXT_LIGHT", "MUTED", "LOGTXT", "START_BG", "TOGGLE_ON", "G1", "G2" }

-- сохранение настроек (если Delta умеет писать файлы)
local HttpService = game:GetService("HttpService")
local SAVE_FILE = "MM2CandyFarm_settings.json"
local function loadSettings()
    if readfile and isfile then
        local ok, res = pcall(function()
            if isfile(SAVE_FILE) then return HttpService:JSONDecode(readfile(SAVE_FILE)) end
            return nil
        end)
        if ok and type(res) == "table" then return res end
    end
    return {}
end
local saved = loadSettings()
local themeName = (saved.theme and THEMES[saved.theme]) and saved.theme or "Хеллоуин"
local windowAlpha = (type(saved.alpha) == "number") and math.clamp(saved.alpha, 0, 0.6) or 0
local C   -- таблица настроек, заполняется ниже
local X = {   -- настройки интерфейса (эмодзи, положение окна)
    set = type(saved.eset) == "string" and saved.eset or "Хеллоуин",
    custom = type(saved.ecustom) == "string" and saved.ecustom or "",
    pos = type(saved.winpos) == "string" and saved.winpos or "center",
}
local function saveSettings()
    if writefile then
        pcall(function()
            writefile(SAVE_FILE, HttpService:JSONEncode({
                theme = themeName, alpha = windowAlpha,
                scale = C and C.UIScale, emoji = C and C.Emoji,
                ecount = C and C.EmojiCount, espeed = C and C.EmojiSpeed,
                compact = C and C.CompactTabs,
                eset = X.set, ecustom = X.custom, winpos = X.pos,
            }))
        end)
    end
end

local P0 = THEMES[themeName]
local BG, DARK2, ORANGE, PURPLE = P0.BG, P0.DARK2, P0.ORANGE, P0.PURPLE
local GREEN, RED, LILAC = P0.GREEN, P0.RED, P0.LILAC
local TXT_ACC, TXT_LIGHT, MUTED, LOGTXT = P0.TXT_ACC, P0.TXT_LIGHT, P0.MUTED, P0.LOGTXT
local START_BG, TOGGLE_ON, G1, G2 = P0.START_BG, P0.TOGGLE_ON, P0.G1, P0.G2

local function titleText()
    local p = THEMES[themeName]
    return p.icon1 .. " Candy Farm v" .. VERSION .. " " .. STAGE .. " " .. p.icon2
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function round(o, r) new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o) end
local function stroke(o, c, t) return new("UIStroke", { Color = c, Thickness = t or 2, Transparency = 0.35 }, o) end

local gui = new("ScreenGui", {
    Name = "HalloweenFarm", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 999,
})
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
if not okParent or not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local CLICK_ID = "rbxasset://sounds/button.wav"
local function makeSound(speed, vol)
    local s = Instance.new("Sound")
    s.SoundId = CLICK_ID
    s.PlaybackSpeed = speed
    s.Volume = vol
    s.Parent = gui
    return s
end
local sndClick = makeSound(1, 0.6)
local sndOn    = makeSound(1.4, 0.7)
local sndOff   = makeSound(0.7, 0.7)
local function play(s)
    pcall(function()
        s.TimePosition = 0
        s:Play()
    end)
end

---------------------------------------------------------------------
-- БОЙ: ESP, килаура, аим ножа, silent aim
---------------------------------------------------------------------
C = { ESP = false, Aura = false, KnifeAim = false, Silent = false, Aimbot = false, Radius = 25,
               Lines = false, Glow = false, Tracers = false,
               Fly = false, FlySpeed = 50, Noclip = false, WalkOn = false, WalkSpeed = 32,
               AirJump = false, Invis = false,
               Stretch = false, StretchAmt = 35, GlowSelf = false,
               UIScale = math.clamp(tonumber(saved.scale) or 100, 60, 140),
               Emoji = saved.emoji == true,
               EmojiCount = math.clamp(tonumber(saved.ecount) or 14, 3, 40),
               EmojiSpeed = math.clamp(tonumber(saved.espeed) or 60, 10, 200),
               CompactTabs = saved.compact == true }
local AIM_SMOOTH = 0.35   -- плавность аимбота (1 = мгновенно, меньше = плавнее)
local STAB_RANGE   = 12   -- ближе этого расстояния бьём ножом
local KNIFE_SPEED  = 90   -- скорость брошенного ножа (для предикции)
local BULLET_SPEED = 300  -- скорость пули шерифа (для предикции)

local function hasTool(plr, name)
    local c = plr.Character
    local bp = plr:FindFirstChildOfClass("Backpack")
    return (c ~= nil and c:FindFirstChild(name) ~= nil)
        or (bp ~= nil and bp:FindFirstChild(name) ~= nil)
end

local function roleOf(plr)
    local r = roleCache[plr.Name]
    if r == "Murderer" then return "Murderer" end
    if r == "Sheriff" or r == "Hero" then return "Sheriff" end
    if hasTool(plr, "Knife") then return "Murderer" end
    if hasTool(plr, "Gun") then return "Sheriff" end
    return nil
end

local function predictPos(th, speed)
    local myHrp = getHRP()
    local dist = myHrp and (th.Position - myHrp.Position).Magnitude or 0
    return th.Position + th.AssemblyLinearVelocity * (dist / speed)
end

-- цель ближе всего к центру экрана (если никого на экране, то самая близкая)
local function pickTarget()
    local myHrp = getHRP()
    if not myHrp then return nil end
    local cam = workspace.CurrentCamera
    local center = cam.ViewportSize / 2
    local best, bestScore
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local th = aliveHRP(plr)
            if th then
                local sp, on = cam:WorldToViewportPoint(th.Position)
                local score
                if on and sp.Z > 0 then
                    score = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                else
                    score = 1e5 + (th.Position - myHrp.Position).Magnitude
                end
                if not bestScore or score < bestScore then best, bestScore = th, score end
            end
        end
    end
    return best
end

-- ===== ESP, ауры, линии =====
local espFolder = new("Folder", { Name = "ESP" }, gui)
local espObjs   = {}   -- подсветка и подпись [игрок]
local glowObjs  = {}   -- ауры [игрок]
local lineObjs  = {}   -- линии [игрок]
local selfInfo = nil  -- данные о своём персонаже для ауры
local infoCache = {}   -- [игрок] = { key, col, ch, th }; обновляется всегда, не зависит от ESP
local ROLE_COLOR = {
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(80, 255, 120),
    None     = Color3.fromRGB(165, 165, 172), -- лобби: серый
}
local ROLE_NAME = { Murderer = "Мардер", Sheriff = "Шериф", Innocent = "Невиновный", None = "" }

local function clearESP(plr)
    local o = espObjs[plr]
    if o then
        pcall(function() o.hl:Destroy() end)
        pcall(function() o.bb:Destroy() end)
        espObjs[plr] = nil
    end
end
local function clearGlow(plr)
    local g = glowObjs[plr]
    if g then
        pcall(function() g.part:Destroy() end)
        glowObjs[plr] = nil
    end
end
local function clearLine(plr)
    local l = lineObjs[plr]
    if l then
        pcall(function() l:Destroy() end)
        lineObjs[plr] = nil
    end
end
local function clearAll(plr)
    clearESP(plr)
    clearGlow(plr)
    clearLine(plr)
    infoCache[plr] = nil
end
local function clearEverything()
    for plr in pairs(espObjs) do clearESP(plr) end
    for plr in pairs(glowObjs) do clearGlow(plr) end
    for plr in pairs(lineObjs) do clearLine(plr) end
    table.clear(infoCache)
end

local function makeESP(plr)
    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espFolder
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(140, 30)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espFolder
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextStrokeTransparency = 0.4
    lbl.Parent = bb
    espObjs[plr] = { hl = hl, bb = bb, lbl = lbl }
    return espObjs[plr]
end

-- роли берём только у игроков на карте; в лобби все серые
local function updateInfo()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local ch = plr.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local th = ch and ch:FindFirstChild("HumanoidRootPart")
            if ch and hum and th and hum.Health > 0 then
                local key = "None"
                if inMap(th, 20) then key = roleOf(plr) or "Innocent" end
                infoCache[plr] = { key = key, col = ROLE_COLOR[key], ch = ch, th = th }
            else
                infoCache[plr] = nil
            end
        end
    end
    local sch = player.Character
    local shum = sch and sch:FindFirstChildOfClass("Humanoid")
    local sth = sch and sch:FindFirstChild("HumanoidRootPart")
    if sch and shum and sth and shum.Health > 0 then
        local key = "None"
        if inMap(sth, 20) then key = roleOf(player) or "Innocent" end
        selfInfo = { key = key, col = (key == "None") and ORANGE or ROLE_COLOR[key], th = sth }
    else
        selfInfo = nil
    end
end

-- аура: сфера-«силовое поле» вокруг игрока + искры
local function ensureGlow(plr, info)
    local g = glowObjs[plr]
    if not g or not g.part.Parent or g.target ~= info.th then
        if g then pcall(function() g.part:Destroy() end) end
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.ForceField
        p.Size = Vector3.new(6.5, 6.5, 6.5)
        p.Transparency = (plr == player) and 0.55 or 0.3
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.CastShadow = false
        p.CFrame = info.th.CFrame
        local pe = Instance.new("ParticleEmitter")
        pe.Rate = 16
        pe.Lifetime = NumberRange.new(0.8, 1.4)
        pe.Speed = NumberRange.new(1, 2.5)
        pe.SpreadAngle = Vector2.new(180, 180)
        pe.LightEmission = 1
        pe.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0),
        })
        pe.Transparency = NumberSequence.new(0.1, 1)
        pcall(function() pe.Texture = "rbxasset://textures/particles/sparkles_main.dds" end)
        pe.Parent = p
        p.Parent = workspace.CurrentCamera or workspace
        g = { part = p, pe = pe, target = info.th }
        glowObjs[plr] = g
    end
    g.part.Color = info.col
    g.pe.Color = ColorSequence.new(info.col)
end

local function refreshESP()
    updateInfo()
    for plr, info in pairs(infoCache) do
        local lobby = (info.key == "None")
        if C.ESP then
            local o = espObjs[plr]
            if not o or not o.hl.Parent then
                clearESP(plr)
                o = makeESP(plr)
            end
            local col = info.col
            o.hl.Adornee = info.ch
            o.hl.FillColor = col
            o.hl.OutlineColor = col
            o.hl.FillTransparency = lobby and 0.85 or 0.5
            o.hl.OutlineTransparency = lobby and 0.55 or 0
            o.bb.Adornee = info.ch:FindFirstChild("Head") or info.th
            o.lbl.TextColor3 = col
            o.lbl.TextTransparency = lobby and 0.35 or 0
            o.lbl.TextStrokeTransparency = lobby and 0.8 or 0.4
            o.lbl.Text = plr.DisplayName .. (ROLE_NAME[info.key] ~= "" and ("\n" .. ROLE_NAME[info.key]) or "")
        else
            clearESP(plr)
        end
        if C.Glow and not lobby then
            ensureGlow(plr, info)
        else
            clearGlow(plr)
        end
    end
    if C.GlowSelf and selfInfo then
        ensureGlow(player, selfInfo)
    else
        clearGlow(player)
    end
    for plr in pairs(espObjs) do if not infoCache[plr] then clearESP(plr) end end
    for plr in pairs(glowObjs) do if not infoCache[plr] and plr ~= player then clearGlow(plr) end end
    for plr in pairs(lineObjs) do if not infoCache[plr] then clearLine(plr) end end
end
connect(Players.PlayerRemoving, clearAll)
task.spawn(function()
    while alive do
        pcall(refreshESP)
        task.wait(0.25)
    end
end)

-- ===== ТРЕЙСЕРЫ пуль и ножей =====
local MY_TRACER_COLOR = Color3.fromRGB(255, 225, 120)

local function drawTracer(a, b, col, life)
    local cam = workspace.CurrentCamera
    local dist = (b - a).Magnitude
    if not cam or dist < 1 or dist > 1500 then return end
    life = life or 0.6
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Material = Enum.Material.Neon
    p.Color = col
    p.Transparency = 0.05
    p.Size = Vector3.new(0.14, 0.14, dist)
    p.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -dist / 2)
    p.Parent = cam
    TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad),
        { Transparency = 1, Size = Vector3.new(0.02, 0.02, dist) }):Play()
    Debris:AddItem(p, life + 0.2)
end

FX.myShot = function(pos)
    if not (C.Tracers and alive) then return end
    local hrp = getHRP()
    if not hrp then return end
    local head = hrp.Parent and hrp.Parent:FindFirstChild("Head")
    drawTracer((head and head.Position) or hrp.Position, pos, MY_TRACER_COLOR, 0.7)
end

local function shooterColor(pos)
    local best, bestD = nil, 10
    for _, info in pairs(infoCache) do
        local d = (info.th.Position - pos).Magnitude
        if d < bestD then best, bestD = info, d end
    end
    return (best and best.key ~= "None") and best.col or ROLE_COLOR.Murderer
end

local function attachTrail(part, col)
    if part:FindFirstChild("FarmTrail") then return end
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 0.3, 0)
    a0.Parent = part
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -0.3, 0)
    a1.Parent = part
    local tr = Instance.new("Trail")
    tr.Name = "FarmTrail"
    tr.Attachment0, tr.Attachment1 = a0, a1
    tr.Lifetime = 0.5
    tr.LightEmission = 1
    tr.Color = ColorSequence.new(col)
    tr.Transparency = NumberSequence.new(0, 1)
    tr.WidthScale = NumberSequence.new(1, 0)
    tr.Parent = part
end

connect(workspace.DescendantAdded, function(d)
    if not (C.Tracers and alive) then return end
    pcall(function()
        if d:IsA("Beam") then
            task.defer(function()
                local a0, a1 = d.Attachment0, d.Attachment1
                if a0 and a1 then
                    drawTracer(a0.WorldPosition, a1.WorldPosition, shooterColor(a0.WorldPosition), 0.7)
                end
            end)
        elseif d:IsA("BasePart") then
            local nm = d.Name:lower()
            if nm:find("knife") or nm:find("bullet") or nm:find("projectile") then
                local model = d:FindFirstAncestorOfClass("Model")
                local owner = model and Players:GetPlayerFromCharacter(model)
                if not owner then attachTrail(d, shooterColor(d.Position)) end
            end
        end
    end)
end)

-- покадровое обновление: пульс ауры и линии от низа экрана к игрокам
local pulseT = 0
connect(RunService.RenderStepped, function(dt)
    if not alive then return end
    pulseT += dt
    for plr, g in pairs(glowObjs) do
        local info = infoCache[plr] or (plr == player and selfInfo or nil)
        if g.part.Parent and info and info.th.Parent then
            g.part.CFrame = info.th.CFrame
            local s = 6.5 + 0.7 * math.sin(pulseT * 3)
            g.part.Size = Vector3.new(s, s, s)
        end
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    for plr, info in pairs(infoCache) do
        local ln = lineObjs[plr]
        if C.Lines and info.key ~= "None" and info.th.Parent then
            local sp, on = cam:WorldToViewportPoint(info.th.Position)
            if on and sp.Z > 0 then
                if not (ln and ln.Parent) then
                    ln = Instance.new("Frame")
                    ln.AnchorPoint = Vector2.new(0.5, 0.5)
                    ln.BorderSizePixel = 0
                    ln.BackgroundTransparency = 0.4
                    ln.ZIndex = 0
                    ln.Parent = espFolder
                    lineObjs[plr] = ln
                end
                local from = Vector2.new(vp.X / 2, vp.Y)
                local to = Vector2.new(sp.X, sp.Y)
                local d = to - from
                ln.Visible = true
                ln.BackgroundColor3 = info.col
                ln.Size = UDim2.fromOffset(d.Magnitude, 2)
                ln.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
                ln.Rotation = math.deg(math.atan2(d.Y, d.X))
            elseif ln then
                ln.Visible = false
            end
        elseif ln then
            ln.Visible = false
        end
    end
end)

-- ===== килаура и бросок ножа (за мардера) =====
local function throwRemote(knife)
    for _, d in ipairs(knife:GetDescendants()) do
        if d:IsA("RemoteEvent") and (d.Name == "KnifeThrown" or d.Name == "Throw") then
            return d
        end
    end
    return nil
end

task.spawn(function()
    local lastThrow = 0
    while alive do
        task.wait(0.12)
        if C.Aura and not S.Busy then
            pcall(function()
                local hrp, ch = getHRP()
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end
                local knife = getTool("Knife")
                if not knife then return end
                if knife.Parent ~= ch then hum:EquipTool(knife) end
                for _, plr in ipairs(Players:GetPlayers()) do
                    local th = plr ~= player and aliveHRP(plr)
                    if th then
                        local dist = (th.Position - hrp.Position).Magnitude
                        if dist <= C.Radius then
                            if dist <= STAB_RANGE then
                                knife:Activate()
                                local handle = knife:FindFirstChild("Handle")
                                if handle and firetouchinterest then
                                    firetouchinterest(handle, th, 0)
                                    firetouchinterest(handle, th, 1)
                                end
                            elseif os.clock() - lastThrow > 1.4 then
                                local remote = throwRemote(knife)
                                if remote then
                                    lastThrow = os.clock()
                                    local pos = predictPos(th, KNIFE_SPEED)
                                    remote:FireServer(CFrame.new(hrp.Position), CFrame.new(pos))
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ===== перехват: аим ножа и silent aim пистолета =====
-- кэш мардера (хуки не должны сами делать тяжёлые запросы)
local cache = { murd = nil, head = nil, armed = false }
task.spawn(function()
    while alive do
        pcall(function()
            if (C.ESP or C.Silent or C.Aimbot) and os.clock() - (cache.rolesAt or 0) > 1.5 then
                cache.rolesAt = os.clock()
                refreshRoles()
            end
            local murd = findMurderer()
            local th = murd and aliveHRP(murd)
            cache.murd = th
            cache.head = th and th.Parent and th.Parent:FindFirstChild("Head") or nil
            cache.armed = hasTool(player, "Gun")
        end)
        task.wait(0.1)
    end
end)

-- АИМБОТ: центр экрана наводится на мардера
connect(RunService.RenderStepped, function()
    if not (C.Aimbot and alive) then return end
    local th = cache.murd
    if not (th and th.Parent) then return end
    local cam = workspace.CurrentCamera
    local aimAt = cache.head and cache.head.Parent and cache.head or th
    local pos = predictPos(aimAt, BULLET_SPEED)
    local want = CFrame.new(cam.CFrame.Position, pos)
    cam.CFrame = cam.CFrame:Lerp(want, AIM_SMOOTH)
end)

local oldNamecall
local function nsHandler(self, ...)
    local m = getnamecallmethod()
    if alive and typeof(self) == "Instance" and not (checkcaller and checkcaller()) then
        local name = self.Name
        local n = select("#", ...)
        -- silent aim: пистолет шерифа стреляет в мардера
        -- (RemoteFunction лежит внутри папки CreateBeam, поэтому проверяем и родителя)
        local pname = self.Parent and self.Parent.Name
        if C.Silent and (m == "InvokeServer" or m == "FireServer")
            and (name == "CreateBeam" or pname == "CreateBeam" or name == "Shoot" or pname == "Shoot") then
            local th = cache.murd
            if th and th.Parent and cache.armed then
                local args = { ... }
                local pos = predictPos(th, BULLET_SPEED)
                local changed = false
                for i = 1, n do
                    local t = typeof(args[i])
                    if t == "Vector3" then args[i] = pos changed = true break end
                    if t == "CFrame" then args[i] = CFrame.new(pos) changed = true break end
                end
                if changed then
                    if C.Tracers then task.defer(FX.myShot, pos) end
                    if setnamecallmethod then setnamecallmethod(m) end
                    return oldNamecall(self, table.unpack(args, 1, n))
                end
            end
        -- аим броска ножа
        elseif C.KnifeAim and m == "FireServer" and (name == "KnifeThrown" or name == "Throw") then
            local args = { ... }
            local th = pickTarget()
            if th then
                local pos = predictPos(th, KNIFE_SPEED)
                for i = n, 1, -1 do
                    local t = typeof(args[i])
                    if t == "CFrame" then args[i] = CFrame.new(pos) break end
                    if t == "Vector3" then args[i] = pos break end
                end
                if C.Tracers then task.defer(FX.myShot, pos) end
                if setnamecallmethod then setnamecallmethod(m) end
                return oldNamecall(self, table.unpack(args, 1, n))
            end
        end
    end

    -- трейсер для обычных (не изменённых) выстрелов и бросков
    if C.Tracers and alive and typeof(self) == "Instance" and not (checkcaller and checkcaller()) then
        local nm, pn = self.Name, self.Parent and self.Parent.Name
        local isGun = (m == "InvokeServer") and (nm == "CreateBeam" or pn == "CreateBeam")
        local isKnife = (m == "FireServer") and (nm == "KnifeThrown" or nm == "Throw")
        if isGun or isKnife then
            local a = { ... }
            for i = select("#", ...), 1, -1 do
                local t = typeof(a[i])
                if t == "Vector3" then task.defer(FX.myShot, a[i]) break end
                if t == "CFrame" then task.defer(FX.myShot, a[i].Position) break end
            end
        end
    end

    if setnamecallmethod then setnamecallmethod(m) end
    return oldNamecall(self, ...)
end

local hookOk = false
if hookmetamethod and getnamecallmethod then
    hookOk = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure and newcclosure(nsHandler) or nsHandler)
    end)
end

-- второй способ silent aim: игра берёт точку выстрела из mouse.Hit / mouse.Target
local mouse = player:GetMouse()
local oldIndex
local function idxHandler(self, key)
    if alive and C.Silent and self == mouse and (key == "Hit" or key == "Target")
        and not (checkcaller and checkcaller()) then
        local th = cache.murd
        if th and th.Parent and cache.armed then
            if key == "Hit" then
                return CFrame.new(predictPos(th, BULLET_SPEED))
            end
            return th
        end
    end
    return oldIndex(self, key)
end
if hookmetamethod then
    pcall(function()
        oldIndex = hookmetamethod(game, "__index", newcclosure and newcclosure(idxHandler) or idxHandler)
    end)
end

---------------------------------------------------------------------
-- ИГРОК: полёт, ноклип, скорость ходьбы, прыжок в воздухе, невидимость,
-- перезаход и смена сервера
---------------------------------------------------------------------
local PL = {}
do
local flyBV, flyBG
local origCollide = setmetatable({}, { __mode = "k" })
local noclipWas, walkWas, defaultWalk = false, false, 16
local invisSeat

local function setFlyPhysics(on)
    local hrp, ch = getHRP()
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if on and hrp then
        if not (flyBV and flyBV.Parent == hrp) then
            if flyBV then pcall(function() flyBV:Destroy() end) end
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "FlyBV"
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = hrp
        end
        if not (flyBG and flyBG.Parent == hrp) then
            if flyBG then pcall(function() flyBG:Destroy() end) end
            flyBG = Instance.new("BodyGyro")
            flyBG.Name = "FlyBG"
            flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBG.P = 1e4
            flyBG.CFrame = hrp.CFrame
            flyBG.Parent = hrp
        end
        if hum then hum.PlatformStand = true end
    else
        if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
        if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
        if hum and not hold then hum.PlatformStand = false end
    end
end

-- полёт: куда смотрит камера и куда двигаешь стик/WASD; Space вверх, Shift вниз
connect(RunService.RenderStepped, function()
    if not alive then return end
    if C.Fly and not S.Enabled then
        local hrp, ch = getHRP()
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if not (hrp and hum and cam) or hum.Health <= 0 then return end
        setFlyPhysics(true)
        local cf = cam.CFrame
        local mv = cf:VectorToObjectSpace(hum.MoveDirection)
        local dir = cf.LookVector * (-mv.Z) + cf.RightVector * mv.X
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
        flyBV.Velocity = (dir.Magnitude > 0.01) and (dir.Unit * C.FlySpeed) or Vector3.zero
        local lv = cf.LookVector
        flyBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(lv.X, 0, lv.Z))
    elseif flyBV or flyBG then
        setFlyPhysics(false)
    end
end)

-- ноклип и скорость ходьбы
connect(RunService.Stepped, function()
    if not alive then return end
    local ch = player.Character
    if C.Noclip and ch then
        noclipWas = true
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                origCollide[p] = true
                p.CanCollide = false
            end
        end
    elseif noclipWas then
        noclipWas = false
        for p in pairs(origCollide) do
            if p.Parent then p.CanCollide = true end
            origCollide[p] = nil
        end
    end

    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then
        if C.WalkOn then
            if not walkWas then walkWas, defaultWalk = true, hum.WalkSpeed end
            hum.WalkSpeed = C.WalkSpeed
        elseif walkWas then
            walkWas = false
            hum.WalkSpeed = defaultWalk
        end
    end
end)

-- прыжок в воздухе
connect(UIS.JumpRequest, function()
    if not (alive and C.AirJump) then return end
    local _, ch = getHRP()
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- невидимость (экспериментально): торс «садится» на невидимое сиденье
local function setInvisible(on)
    if on then
        local hrp, ch = getHRP()
        if not (hrp and ch) or invisSeat then return end
        local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
        if not torso then return end
        local saved = hrp.CFrame
        local void = Vector3.new(-25.95, 84, 3537.55)
        ch:MoveTo(void)
        task.wait(0.15)
        local seat = Instance.new("Seat")
        seat.Name = "invischair"
        seat.Anchored = false
        seat.CanCollide = false
        seat.Transparency = 1
        seat.Position = void
        seat.Parent = workspace
        local weld = Instance.new("Weld")
        weld.Part0, weld.Part1 = seat, torso
        weld.Parent = seat
        task.wait()
        seat.CFrame = saved
        invisSeat = seat
    else
        if invisSeat then
            pcall(function() invisSeat:Destroy() end)
            invisSeat = nil
        end
    end
end

-- перезаход и смена сервера
local hopping = false
local function doRejoin(setStatus)
    if hopping then return end
    hopping = true
    setStatus("Перезаход на этот сервер…")
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
    task.delay(8, function()
        if alive then
            setStatus("Не вышло, захожу на любой сервер…")
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
            hopping = false
        end
    end)
end

local function serverHop(setStatus)
    if hopping then return end
    hopping = true
    setStatus("Ищу другой сервер…")
    task.spawn(function()
        local target
        local ok, body = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true")
        end)
        if ok and body then
            local ok2, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(body)
            end)
            if ok2 and type(data) == "table" and type(data.data) == "table" then
                local pool = {}
                for _, sv in ipairs(data.data) do
                    if sv.id ~= game.JobId and sv.playing and sv.maxPlayers
                        and sv.playing < sv.maxPlayers - 1 then
                        table.insert(pool, sv)
                    end
                end
                if #pool > 0 then target = pool[math.random(#pool)] end
            end
        end
        if target then
            setStatus("Перехожу на сервер (" .. target.playing .. "/" .. target.maxPlayers .. ")…")
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, player)
            end)
        else
            setStatus("Список серверов не получен, захожу на любой…")
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end
        task.wait(8)
        hopping = false
    end)
end

local function stopPlayerMods()
    C.Fly, C.Noclip, C.WalkOn, C.AirJump = false, false, false, false
    setFlyPhysics(false)
    if noclipWas then
        for p in pairs(origCollide) do
            if p.Parent then p.CanCollide = true end
            origCollide[p] = nil
        end
    end
    local _, ch = getHRP()
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum and walkWas then hum.WalkSpeed = defaultWalk end
    if invisSeat then pcall(function() invisSeat:Destroy() end) invisSeat = nil end
end
PL.setInvisible = setInvisible
PL.doRejoin = doRejoin
PL.serverHop = serverHop
PL.stop = stopPlayerMods
PL.dropSeat = function()
    if invisSeat then pcall(function() invisSeat:Destroy() end) invisSeat = nil end
end
end


local main = new("Frame", {
    Size = UDim2.fromOffset(300, 440),
    Position = UDim2.new(0.5, -150, 0.5, -220),
    BackgroundColor3 = BG, BackgroundTransparency = windowAlpha, Active = true,
}, gui)
round(main, 18)
stroke(main, ORANGE, 1.5)
new("UIGradient", {
    Color = ColorSequence.new(G1, G2),
    Rotation = 90,
}, main)

local title = new("TextLabel", {
    Size = UDim2.new(1, -80, 0, 34), Position = UDim2.fromOffset(0, 0),
    BackgroundTransparency = 1, Text = titleText(),
    TextColor3 = ORANGE, Font = Enum.Font.GothamBold, TextSize = 14, Active = true,
}, main)

local minBtn = new("TextButton", {
    Size = UDim2.fromOffset(30, 26), Position = UDim2.new(1, -36, 0, 4),
    BackgroundColor3 = DARK2, Text = "–", TextColor3 = ORANGE,
    Font = Enum.Font.GothamMedium, TextSize = 20, AutoButtonColor = true,
}, main)
round(minBtn, 6)

-- ВКЛАДКИ: современная полоса, активная вкладка раскрывается с названием
local function newPage(visible)
    return new("Frame", {
        Size = UDim2.new(1, 0, 1, -26), Position = UDim2.fromOffset(0, 26),
        BackgroundTransparency = 1, Visible = visible,
    }, main)
end
local page        = newPage(true)
local combatPage  = newPage(false)
local visualPage  = newPage(false)
local playerPage  = newPage(false)
local settingsPage = new("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -78), Position = UDim2.fromOffset(0, 70),
    BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
    ScrollBarThickness = 3, CanvasSize = UDim2.fromOffset(0, 572),
    ScrollBarImageColor3 = ORANGE,
}, main)
local logPage     = newPage(false)
local authorsPage = newPage(false)

local TAB_DEFS = {
    { id = "farm",    icon = "🎃", name = "Фарм",   page = page },
    { id = "combat",  icon = "⚔",  name = "Бой",    page = combatPage },
    { id = "visual",  icon = "👁",  name = "Визуал", page = visualPage },
    { id = "player",  icon = "🏃", name = "Игрок",  page = playerPage },
    { id = "settings", icon = "⚙", name = "Настройки", page = settingsPage },
    { id = "log",     icon = "📜", name = "Лог",    page = logPage },
    { id = "authors", icon = "👻", name = "Авторы", page = authorsPage },
}
local TAB_W_ON, TAB_W_OFF = 104, 25

local tabBar = new("Frame", {
    Size = UDim2.fromOffset(284, 26), Position = UDim2.fromOffset(8, 34),
    BackgroundTransparency = 1,
}, main)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local tabButtons = {}
for i, def in ipairs(TAB_DEFS) do
    local b = new("TextButton", {
        Size = UDim2.fromOffset(TAB_W_OFF, 26), LayoutOrder = i,
        BackgroundColor3 = DARK2, Text = def.icon, TextColor3 = TXT_LIGHT,
        Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
    }, tabBar)
    round(b, 13)
    tabButtons[def.id] = b
end

local curTab = "farm"
local function showTab(name, instant)
    curTab = name
    for _, def in ipairs(TAB_DEFS) do
        local on = (def.id == name)
        local b = tabButtons[def.id]
        def.page.Visible = on
        local wide = on and not C.CompactTabs
        b.Text = wide and (def.icon .. " " .. def.name) or def.icon
        b.BackgroundColor3 = on and ORANGE or DARK2
        b.TextColor3 = on and TXT_ACC or TXT_LIGHT
        local size = UDim2.fromOffset(wide and TAB_W_ON or TAB_W_OFF, 26)
        if instant then
            b.Size = size
        else
            TweenService:Create(b, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Size = size }):Play()
        end
    end
end
for _, def in ipairs(TAB_DEFS) do
    tabButtons[def.id].Activated:Connect(function() showTab(def.id) end)
end

-- ВКЛАДКА «ФАРМ»
new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 44),
    BackgroundTransparency = 1, Text = "🕸 Режим фарма", TextColor3 = LILAC,
    Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
}, page)

local modes = {
    { id = "Underground", text = "🕷\nПод землёй", x = 8 },
    { id = "Teleport",    text = "🧙\nТелепорт",   x = 104 },
    { id = "Fly",         text = "👻\nПолёт",      x = 200 },
}
local modeButtons = {}
local function refreshModes()
    for id, b in pairs(modeButtons) do
        local sel = (S.Mode == id)
        b.BackgroundColor3 = sel and ORANGE or DARK2
        b.TextColor3 = sel and TXT_ACC or TXT_LIGHT
    end
end
for _, m in ipairs(modes) do
    local b = new("TextButton", {
        Size = UDim2.fromOffset(92, 48), Position = UDim2.fromOffset(m.x, 66),
        Text = m.text, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextWrapped = true, AutoButtonColor = true, BackgroundColor3 = DARK2,
    }, page)
    round(b, 10)
    stroke(b, PURPLE, 1.5)
    modeButtons[m.id] = b
    b.Activated:Connect(function() S.Mode = m.id; refreshModes() end)
end

local speedLabel = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 124),
    BackgroundTransparency = 1, TextColor3 = LILAC,
    Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
}, page)

local MIN_SPEED, MAX_SPEED = 1, 15
local track = new("Frame", {
    Size = UDim2.fromOffset(204, 10), Position = UDim2.fromOffset(48, 154),
    BackgroundColor3 = DARK2, Active = true,
}, page)
round(track, 5)
local fill = new("Frame", { BackgroundColor3 = ORANGE, Size = UDim2.new(0, 0, 1, 0) }, track)
round(fill, 5)
local knob = new("Frame", {
    Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = GREEN, Active = true,
}, track)
round(knob, 11)
stroke(knob, TXT_ACC, 2)

local function setSpeed(v)
    v = math.clamp(math.floor(v + 0.5), MIN_SPEED, MAX_SPEED)
    S.Speed = v
    local rel = (v - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    knob.Position = UDim2.new(rel, 0, 0.5, 0)
    speedLabel.Text = "⚡ Скорость фарма: " .. v .. " / " .. MAX_SPEED
end

local function mkStep(text, x, delta)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(34, 30), Position = UDim2.fromOffset(x, 144),
        BackgroundColor3 = DARK2, Text = text, TextColor3 = ORANGE,
        Font = Enum.Font.GothamMedium, TextSize = 18,
    }, page)
    round(b, 8)
    b.Activated:Connect(function() setSpeed(S.Speed + delta) end)
end
mkStep("➖", 8, -1)
mkStep("➕", 258, 1)

local sliding = false
local function sliderInput(i)
    local rel = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
    setSpeed(MIN_SPEED + (MAX_SPEED - MIN_SPEED) * rel)
end
for _, o in ipairs({ track, knob }) do
    connect(o.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            play(sndClick)
            sliderInput(i)
        end
    end)
end
connect(UIS.InputChanged, function(i)
    if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        sliderInput(i)
    end
end)
connect(UIS.InputEnded, function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

local startBtn = new("TextButton", {
    Size = UDim2.fromOffset(284, 52), Position = UDim2.fromOffset(8, 188),
    Font = Enum.Font.GothamMedium, TextSize = 20, AutoButtonColor = true,
}, page)
round(startBtn, 12)
stroke(startBtn, PURPLE, 2)

local fullBtn = new("TextButton", {
    Size = UDim2.fromOffset(284, 34), Position = UDim2.fromOffset(8, 246),
    BackgroundColor3 = DARK2, TextColor3 = TXT_LIGHT,
    Font = Enum.Font.GothamMedium, TextSize = 14,
}, page)
round(fullBtn, 10)
stroke(fullBtn, PURPLE, 1.5)

local fullModes = { "Respawn", "Role", "Off" }
local fullNames = {
    Respawn = "💀 Мешок полон: респаун",
    Role    = "🔪 Мешок полон: роль → респаун",
    Off     = "⏸ Мешок полон: ничего",
}
local function refreshFull() fullBtn.Text = fullNames[S.OnFull] end
fullBtn.Activated:Connect(function()
    local i = table.find(fullModes, S.OnFull) or 1
    S.OnFull = fullModes[i % #fullModes + 1]
    refreshFull()
end)

local status = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 22), Position = UDim2.fromOffset(8, 292),
    BackgroundTransparency = 1, TextColor3 = GREEN,
    Font = Enum.Font.GothamMedium, TextSize = 13,
}, page)

new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 36), Position = UDim2.fromOffset(8, 316),
    BackgroundTransparency = 1, TextWrapped = true,
    Text = UIS.TouchEnabled and "🎃 Тапни на тыкву слева, чтобы скрыть/показать меню"
        or "F — старт/стоп  •  RightCtrl — скрыть меню",
    TextColor3 = MUTED,
    Font = Enum.Font.Gotham, TextSize = 12,
}, page)

-- ВКЛАДКА «БОЙ» и «ВИЗУАЛ»: строки с переключателями-«пилюлями»
local toggleRefreshers = {}
local function toggleRow(y, label, key, parent, onChange)
    local row = new("TextButton", {
        Size = UDim2.fromOffset(284, 36), Position = UDim2.fromOffset(8, y),
        BackgroundColor3 = DARK2, Text = "", AutoButtonColor = true,
    }, parent or combatPage)
    round(row, 12)
    stroke(row, PURPLE, 1)
    new("TextLabel", {
        Size = UDim2.new(1, -72, 1, 0), Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = TXT_LIGHT,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local track = new("Frame", {
        Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = MUTED,
    }, row)
    round(track, 10)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = LOGTXT,
    }, track)
    round(knob, 8)
    local function r(animate)
        local on = C[key]
        row.BackgroundColor3 = DARK2
        track.BackgroundColor3 = on and ORANGE or MUTED
        knob.BackgroundColor3 = LOGTXT
        local pos = on and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
        if animate == true then
            TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Position = pos }):Play()
        else
            knob.Position = pos
        end
    end
    row.Activated:Connect(function()
        C[key] = not C[key]
        r(true)
        if onChange then onChange() end
    end)
    table.insert(toggleRefreshers, r)
    r(false)
end
local function refreshVisualsNow() pcall(refreshESP) end

-- бой
toggleRow(44,  "🗡  Килаура (мардер)",     "Aura")
toggleRow(86,  "🎯  Аим броска ножа",      "KnifeAim")
toggleRow(128, "🔫  Silent Aim (шериф)",   "Silent")
toggleRow(170, "🧿  Аимбот (на мардера)",  "Aimbot")
-- визуал
toggleRow(44,  "👁  ESP (подсветка + роли)",   "ESP",     visualPage, refreshVisualsNow)
toggleRow(86,  "📐  Линии к игрокам",          "Lines",   visualPage)
toggleRow(128, "✨  Ауры на игроках",          "Glow",    visualPage, refreshVisualsNow)
toggleRow(170, "💥  Трейсеры пуль и ножей",    "Tracers", visualPage)
toggleRow(212, "🪐  Растяг экрана",            "Stretch", visualPage)
toggleRow(254, "🫧  Аура на мне",              "GlowSelf", visualPage, refreshVisualsNow)
new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 64), Position = UDim2.fromOffset(8, 346),
    BackgroundTransparency = 1, TextWrapped = true, TextColor3 = MUTED,
    Font = Enum.Font.Gotham, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    Text = "🔴 мардер  🔵 шериф  🟢 невиновные  ⚪ лобби (серый)\n"
        .. "Линии и ауры показываются только у игроков на карте. "
        .. "Трейсеры рисуют след своих выстрелов и бросков, а чужие, если игра создаёт для них видимый луч или снаряд.",
}, visualPage)

local rLabel = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 218),
    BackgroundTransparency = 1, TextColor3 = LILAC,
    Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
}, combatPage)
local RMIN, RMAX = 5, 60
local rTrack = new("Frame", {
    Size = UDim2.fromOffset(204, 10), Position = UDim2.fromOffset(48, 252),
    BackgroundColor3 = DARK2, Active = true,
}, combatPage)
round(rTrack, 5)
local rFill = new("Frame", { BackgroundColor3 = ORANGE, Size = UDim2.new(0, 0, 1, 0) }, rTrack)
round(rFill, 5)
local rKnob = new("Frame", {
    Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = GREEN, Active = true,
}, rTrack)
round(rKnob, 11)
stroke(rKnob, TXT_ACC, 2)

local function setRadius(v)
    v = math.clamp(math.floor(v + 0.5), RMIN, RMAX)
    C.Radius = v
    local rel = (v - RMIN) / (RMAX - RMIN)
    rFill.Size = UDim2.new(rel, 0, 1, 0)
    rKnob.Position = UDim2.new(rel, 0, 0.5, 0)
    rLabel.Text = "📏 Радиус килауры: " .. v .. " ст."
end
local function mkRStep(text, x, delta)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(34, 30), Position = UDim2.fromOffset(x, 242),
        BackgroundColor3 = DARK2, Text = text, TextColor3 = ORANGE,
        Font = Enum.Font.GothamMedium, TextSize = 18,
    }, combatPage)
    round(b, 8)
    b.Activated:Connect(function() setRadius(C.Radius + delta) end)
end
mkRStep("➖", 8, -5)
mkRStep("➕", 258, 5)

local rSliding = false
local function rSliderInput(i)
    local rel = math.clamp((i.Position.X - rTrack.AbsolutePosition.X) / rTrack.AbsoluteSize.X, 0, 1)
    setRadius(RMIN + (RMAX - RMIN) * rel)
end
for _, o in ipairs({ rTrack, rKnob }) do
    connect(o.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            rSliding = true
            play(sndClick)
            rSliderInput(i)
        end
    end)
end
connect(UIS.InputChanged, function(i)
    if rSliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        rSliderInput(i)
    end
end)
connect(UIS.InputEnded, function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        rSliding = false
    end
end)
setRadius(C.Radius)

new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 60), Position = UDim2.fromOffset(8, 288),
    BackgroundTransparency = 1, TextWrapped = true,
    Text = "🔪 Килаура и аим ножа работают за мардера\n🔫 Silent Aim и аимбот: за шерифа, стреляй как обычно"
        .. (hookOk and "" or "\n⚠ Твой Delta не поддерживает перехват: аим ножа и Silent Aim не сработают"),
    TextColor3 = MUTED,
    Font = Enum.Font.Gotham, TextSize = 12,
}, combatPage)

-- ВКЛАДКА «ИГРОК»
toggleRow(44,  "🕊  Полёт (Fly)",            "Fly",     playerPage)
toggleRow(84,  "👻  Ноклип (сквозь стены)",  "Noclip",  playerPage)
toggleRow(124, "👟  Своя скорость ходьбы",   "WalkOn",  playerPage)
toggleRow(164, "🦘  Прыжок в воздухе",       "AirJump", playerPage)
toggleRow(204, "🫥  Невидимость (бета)",     "Invis",   playerPage, function()
    task.spawn(function() PL.setInvisible(C.Invis) end)
end)

local function makeSlider(parent, y, text, minV, maxV, key, onChange)
    local sf = parent:IsA("ScrollingFrame") and parent or nil
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, y),
        BackgroundTransparency = 1, TextColor3 = LILAC,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    local track = new("Frame", {
        Size = UDim2.fromOffset(264, 8), Position = UDim2.fromOffset(18, y + 28),
        BackgroundColor3 = DARK2, Active = true,
    }, parent)
    round(track, 4)
    local fill = new("Frame", { BackgroundColor3 = ORANGE, Size = UDim2.new(0, 0, 1, 0) }, track)
    round(fill, 4)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(20, 20), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = GREEN, Active = true,
    }, track)
    round(knob, 10)
    stroke(knob, TXT_ACC, 2)
    local function set(v)
        v = math.clamp(math.floor(v + 0.5), minV, maxV)
        C[key] = v
        local rel = (v - minV) / (maxV - minV)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        lbl.Text = text .. ": " .. v
    end
    local sliding = false
    local function input(i)
        set(minV + (maxV - minV) * math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
        if onChange then onChange() end
    end
    for _, o in ipairs({ track, knob }) do
        connect(o.InputBegan, function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                if sf then sf.ScrollingEnabled = false end
                input(i)
            end
        end)
    end
    connect(UIS.InputChanged, function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            input(i)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
            if sf then sf.ScrollingEnabled = true end
        end
    end)
    set(C[key])
end
makeSlider(playerPage, 248, "🕊 Скорость полёта", 10, 150, "FlySpeed")
makeSlider(playerPage, 290, "👟 Скорость ходьбы", 16, 100, "WalkSpeed")

local playerStatus = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 16), Position = UDim2.fromOffset(8, 372),
    BackgroundTransparency = 1, TextColor3 = MUTED, Text = "",
    Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
}, playerPage)
local function setPlayerStatus(t) playerStatus.Text = t end

local function actionButton(x, text, fn)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(138, 34), Position = UDim2.fromOffset(x, 334),
        BackgroundColor3 = DARK2, Text = text, TextColor3 = TXT_LIGHT,
        Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = true,
    }, playerPage)
    round(b, 12)
    stroke(b, PURPLE, 1)
    b.Activated:Connect(fn)
end
actionButton(8,   "🔄 Перезайти",      function() PL.doRejoin(setPlayerStatus) end)
actionButton(154, "🌐 Сменить сервер", function() PL.serverHop(setPlayerStatus) end)

-- ВКЛАДКА «НАСТРОЙКИ» + растяг + летающие эмодзи
do
    local sp = settingsPage

    -- размер окна
    local uiScale = new("UIScale", { Scale = C.UIScale / 100 }, main)
    local function applyPos(name)
        X.pos = name
        if name == "left" then
            main.AnchorPoint = Vector2.new(0, 0.5)
            main.Position = UDim2.new(0, 66, 0.5, 0)
        elseif name == "right" then
            main.AnchorPoint = Vector2.new(1, 0.5)
            main.Position = UDim2.new(1, -10, 0.5, 0)
        else
            X.pos = "center"
            main.AnchorPoint = Vector2.new(0.5, 0.5)
            main.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end
    applyPos(X.pos)

    local function label(y, text)
        return new("TextLabel", {
            Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, y),
            BackgroundTransparency = 1, Text = text, TextColor3 = LILAC,
            Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        }, sp)
    end
    local function button(x, y, w, text)
        local b = new("TextButton", {
            Size = UDim2.fromOffset(w, 32), Position = UDim2.fromOffset(x, y),
            BackgroundColor3 = DARK2, Text = text, TextColor3 = TXT_LIGHT,
            Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = true,
        }, sp)
        round(b, 10)
        stroke(b, PURPLE, 1)
        return b
    end

    -- ===== окно =====
    label(4, "📐 Окно")
    makeSlider(sp, 26, "📏 Размер окна, %", 60, 140, "UIScale", function()
        uiScale.Scale = C.UIScale / 100
    end)
    label(76, "🧭 Положение окна")
    local posBtns = {}
    for k, def in ipairs({ { "left", "◀ Слева" }, { "center", "● Центр" }, { "right", "Справа ▶" } }) do
        local b = button(8 + (k - 1) * 96, 98, 92, def[2])
        posBtns[def[1]] = b
        b.Activated:Connect(function()
            applyPos(def[1])
            for id, bb in pairs(posBtns) do
                bb.BackgroundColor3 = (id == X.pos) and ORANGE or DARK2
                bb.TextColor3 = (id == X.pos) and TXT_ACC or TXT_LIGHT
            end
            saveSettings()
        end)
    end
    local function refreshPosBtns()
        for id, bb in pairs(posBtns) do
            bb.BackgroundColor3 = (id == X.pos) and ORANGE or DARK2
            bb.TextColor3 = (id == X.pos) and TXT_ACC or TXT_LIGHT
        end
    end
    table.insert(toggleRefreshers, refreshPosBtns)
    refreshPosBtns()

    local resetBtn = button(8, 138, 284, "↺ Сбросить размер и положение")
    resetBtn.Size = UDim2.fromOffset(284, 32)

    toggleRow(178, "🗂  Только значки на вкладках", "CompactTabs", sp, function()
        showTab(curTab, true)
        saveSettings()
    end)

    -- ===== эмодзи =====
    label(224, "🎈 Эмодзи на фоне меню")

    local EMOJI_SETS = {
        { "Хеллоуин",  "🎃", { "🎃", "👻", "🦇", "🕷️", "🕸️", "💀" } },
        { "Любовь",    "❤️", { "❤️", "💖", "💕", "💘", "🌹" } },
        { "Зима",      "❄️", { "❄️", "⛄", "🧊", "🌨️" } },
        { "Рождество", "🎄", { "🎄", "🎅", "🎁", "⭐", "🔔" } },
        { "Солнце",    "☀️", { "☀️", "🌻", "🌞", "🔥" } },
        { "Море",      "🌊", { "🌊", "🐚", "🐠", "🐙", "🐬" } },
    }
    local function setList(name)
        for _, e in ipairs(EMOJI_SETS) do
            if e[1] == name then return e[3] end
        end
        return nil
    end
    -- разбор строки на эмодзи (склеиваем селекторы, ZWJ и тона кожи)
    local function parseEmoji(str)
        local out, cur = {}, nil
        local ok = pcall(function()
            local join = false
            for _, cp in utf8.codes(str) do
                local ch = utf8.char(cp)
                if cp == 0xFE0F or cp == 0x20E3 or (cp >= 0x1F3FB and cp <= 0x1F3FF) then
                    if cur then out[cur] = out[cur] .. ch end
                elseif cp == 0x200D then
                    if cur then out[cur] = out[cur] .. ch; join = true end
                elseif cp > 0x7F then
                    if join and cur then
                        out[cur] = out[cur] .. ch
                        join = false
                    else
                        out[#out + 1] = ch
                        cur = #out
                    end
                end
            end
        end)
        if not ok then return {} end
        return out
    end
    local function currentList()
        if X.set == "Свой" then
            local l = parseEmoji(X.custom)
            if #l > 0 then return l end
        end
        return setList(X.set) or EMOJI_SETS[1][3]
    end

    local layer = new("Frame", {
        Name = "EmojiLayer", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 0, ClipsDescendants = true, Visible = false,
    }, gui)
    layer:SetAttribute("NoTheme", true)
    local parts = {}
    local function rebuild()
        for _, p in ipairs(parts) do pcall(function() p.l:Destroy() end) end
        table.clear(parts)
        if not C.Emoji then return end
        local list = currentList()
        local vp = gui.AbsoluteSize
        if vp.X < 10 then vp = Vector2.new(800, 450) end
        for i = 1, C.EmojiCount do
            local size = math.random(18, 34)
            local l = new("TextLabel", {
                Size = UDim2.fromOffset(size + 10, size + 10), AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1, Text = list[(i - 1) % #list + 1],
                TextSize = size, TextTransparency = 0.2, ZIndex = 0,
            }, layer)
            l:SetAttribute("NoTheme", true)
            local ang = math.random() * math.pi * 2
            local spd = 0.5 + math.random() * 0.9
            parts[i] = {
                l = l, x = math.random() * vp.X, y = math.random() * vp.Y,
                vx = math.cos(ang) * spd, vy = math.sin(ang) * spd,
                rot = math.random() * 360, vr = (math.random() - 0.5) * 80,
            }
        end
    end

    connect(RunService.RenderStepped, function(dt)
        if not alive then return end
        local show = C.Emoji and main.Visible
        layer.Visible = show
        if not show then return end
        if #parts ~= C.EmojiCount then rebuild() end
        local vp = layer.AbsoluteSize
        local sp = C.EmojiSpeed
        for _, p in ipairs(parts) do
            p.x += p.vx * sp * dt
            p.y += p.vy * sp * dt
            p.rot += p.vr * dt
            if p.x < 16 then p.x = 16; p.vx = math.abs(p.vx)
            elseif p.x > vp.X - 16 then p.x = vp.X - 16; p.vx = -math.abs(p.vx) end
            if p.y < 16 then p.y = 16; p.vy = math.abs(p.vy)
            elseif p.y > vp.Y - 16 then p.y = vp.Y - 16; p.vy = -math.abs(p.vy) end
            p.l.Position = UDim2.fromOffset(p.x, p.y)
            p.l.Rotation = p.rot
        end
    end)

    toggleRow(246, "🎈  Летающие эмодзи", "Emoji", sp, function()
        rebuild()
        saveSettings()
    end)
    makeSlider(sp, 290, "🔢 Количество", 3, 40, "EmojiCount", function()
        rebuild()
        saveSettings()
    end)
    makeSlider(sp, 340, "💨 Скорость", 10, 200, "EmojiSpeed", saveSettings)

    label(390, "🎭 Набор эмодзи")
    local setBtns = {}
    for k, e in ipairs(EMOJI_SETS) do
        local col, row = (k - 1) % 2, math.floor((k - 1) / 2)
        local b = button(8 + col * 148, 412 + row * 36, 136, e[2] .. " " .. e[1])
        setBtns[e[1]] = b
        b.Activated:Connect(function()
            X.set = e[1]
            for id, bb in pairs(setBtns) do
                bb.BackgroundColor3 = (id == X.set) and ORANGE or DARK2
                bb.TextColor3 = (id == X.set) and TXT_ACC or TXT_LIGHT
            end
            rebuild()
            saveSettings()
        end)
    end
    local box = new("TextBox", {
        Size = UDim2.fromOffset(284, 34), Position = UDim2.fromOffset(8, 520),
        BackgroundColor3 = DARK2, TextColor3 = TXT_LIGHT, PlaceholderColor3 = MUTED,
        PlaceholderText = "✏ Свои эмодзи: вставь, например 🍬🍭🎃", Text = X.custom,
        ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 13,
    }, sp)
    round(box, 10)
    stroke(box, PURPLE, 1)
    local function refreshSetBtns()
        for id, bb in pairs(setBtns) do
            bb.BackgroundColor3 = (id == X.set) and ORANGE or DARK2
            bb.TextColor3 = (id == X.set) and TXT_ACC or TXT_LIGHT
        end
        box.BackgroundColor3 = (X.set == "Свой") and ORANGE or DARK2
        box.TextColor3 = (X.set == "Свой") and TXT_ACC or TXT_LIGHT
    end
    table.insert(toggleRefreshers, refreshSetBtns)
    refreshSetBtns()
    box.FocusLost:Connect(function()
        X.custom = box.Text
        if #parseEmoji(X.custom) > 0 then X.set = "Свой" end
        refreshSetBtns()
        rebuild()
        saveSettings()
    end)

    -- сброс окна
    resetBtn.Activated:Connect(function()
        C.UIScale = 100
        uiScale.Scale = 1
        applyPos("center")
        refreshPosBtns()
        saveSettings()
        showTab(curTab, true)
    end)

    -- ===== растяг экрана =====
    local STRETCH_NAME = "MM2CandyStretch"
    pcall(function() RunService:UnbindFromRenderStep(STRETCH_NAME) end)
    RunService:BindToRenderStep(STRETCH_NAME, Enum.RenderPriority.Camera.Value + 1, function()
        if not (alive and C.Stretch) then return end
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1 - C.StretchAmt / 100, 0, 0, 0, 1)
        end
    end)
    makeSlider(visualPage, 296, "↔ Сила растяга, %", 5, 60, "StretchAmt")

    X.kill = function()
        pcall(function() RunService:UnbindFromRenderStep(STRETCH_NAME) end)
        pcall(function() layer:Destroy() end)
    end
    rebuild()
end

-- ВКЛАДКА «ЛОГ»
new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 22), Position = UDim2.fromOffset(8, 44),
    BackgroundTransparency = 1,
    Text = "📜 Версия " .. VERSION .. " «" .. VERSION_NAME .. "» · " .. STAGE,
    TextColor3 = ORANGE, Font = Enum.Font.GothamMedium, TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, logPage)
local logScroll = new("ScrollingFrame", {
    Size = UDim2.new(1, -16, 0, 300), Position = UDim2.fromOffset(8, 72),
    BackgroundColor3 = DARK2, BackgroundTransparency = 0.3, BorderSizePixel = 0,
    ScrollBarThickness = 4, ScrollBarImageColor3 = ORANGE,
    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, logPage)
round(logScroll, 10)
stroke(logScroll, PURPLE, 1.5)
new("UIPadding", {
    PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
}, logScroll)
local logLabel = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1, TextWrapped = true, RichText = true,
    Text = changelogText("#" .. ORANGE:ToHex(), "#" .. GREEN:ToHex()), TextColor3 = LOGTXT,
    Font = Enum.Font.Gotham, TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, logScroll)

-- ВКЛАДКА «АВТОРЫ»
new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 44),
    BackgroundTransparency = 1, Text = "🕸 Над скриптом работали",
    TextColor3 = LILAC, Font = Enum.Font.GothamMedium, TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
}, authorsPage)

local function authorCard(y, icon, name, role)
    local card = new("Frame", {
        Size = UDim2.fromOffset(284, 70), Position = UDim2.fromOffset(8, y),
        BackgroundColor3 = DARK2,
    }, authorsPage)
    round(card, 12)
    stroke(card, PURPLE, 1.5)
    new("TextLabel", {
        Size = UDim2.fromOffset(52, 70), Position = UDim2.fromOffset(4, 0),
        BackgroundTransparency = 1, Text = icon, TextSize = 30,
    }, card)
    new("TextLabel", {
        Size = UDim2.fromOffset(220, 30), Position = UDim2.fromOffset(58, 8),
        BackgroundTransparency = 1, Text = name, TextColor3 = ORANGE,
        Font = Enum.Font.GothamMedium, TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    new("TextLabel", {
        Size = UDim2.fromOffset(220, 22), Position = UDim2.fromOffset(58, 38),
        BackgroundTransparency = 1, Text = role, TextColor3 = LILAC,
        Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
end
authorCard(72,  "🎃", "@frimdo", "Идея и тестирование")
authorCard(152, "🤖", "Claude",  "Написание кода (Anthropic)")

new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 60), Position = UDim2.fromOffset(8, 236),
    BackgroundTransparency = 1, TextWrapped = true,
    Text = "🦇 MM2 Candy Farm • Halloween edition\nВерсия " .. VERSION .. " «" .. VERSION_NAME .. "» · " .. STAGE
        .. "\nСпасибо, что пользуешься! 🕯",
    TextColor3 = MUTED,
    Font = Enum.Font.Gotham, TextSize = 13,
}, authorsPage)

---------------------------------------------------------------------
function updateStatus()
    status.Text = (S.Enabled and "🟢 Фарм идёт" or "🔴 Остановлен")
        .. "  |  🍬 " .. S.Bag .. "/" .. S.BagLimit
        .. (collectedRemote and "  · игра" or "  · проверка")
end

function refreshStart()
    startBtn.Text = S.Enabled and "■ СТОП" or "▶ СТАРТ"
    startBtn.BackgroundColor3 = S.Enabled and RED or START_BG
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    updateStatus()
end

local function setEnabled(v)
    S.Enabled = v
    play(v and sndOn or sndOff)
    if v then
        lastProgress = os.clock()
        blacklist = {}
    else
        releaseHold()
        local hrp = getHRP()
        if hrp and S.Mode == "Underground" then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, DEPTH + 3, 0)
        end
    end
    refreshStart()
end
startBtn.Activated:Connect(function() setEnabled(not S.Enabled) end)

local pumpkin = new("TextButton", {
    Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 10, 0.5, -23),
    BackgroundColor3 = BG, Text = THEMES[themeName].icon1, TextSize = 26, AutoButtonColor = true,
}, gui)
round(pumpkin, 23)
stroke(pumpkin, ORANGE, 2)
pumpkin.Activated:Connect(function() main.Visible = not main.Visible end)
minBtn.Activated:Connect(function() main.Visible = false end)

---------------------------------------------------------------------
-- ОФОРМЛЕНИЕ: панель тем (кнопка 🎨 в шапке)
---------------------------------------------------------------------
local paletteBtn = new("TextButton", {
    Size = UDim2.fromOffset(30, 26), Position = UDim2.new(1, -70, 0, 4),
    BackgroundColor3 = DARK2, Text = "🎨", TextColor3 = ORANGE,
    Font = Enum.Font.GothamMedium, TextSize = 16, AutoButtonColor = true,
}, main)
round(paletteBtn, 6)

local themePanel = new("Frame", {
    Size = UDim2.new(1, 0, 1, -34), Position = UDim2.fromOffset(0, 34),
    BackgroundColor3 = BG, BackgroundTransparency = 0, ZIndex = 20, Visible = false,
}, main)
round(themePanel, 12)

new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 26), Position = UDim2.fromOffset(8, 6),
    BackgroundTransparency = 1, Text = "🎨 Оформление", TextColor3 = ORANGE,
    Font = Enum.Font.GothamMedium, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 21,
}, themePanel)

local themeButtons = {}
local function refreshThemeButtons()
    for name, b in pairs(themeButtons) do
        local st = b:FindFirstChildOfClass("UIStroke")
        if st then
            st.Thickness = (name == themeName) and 3 or 1.5
        end
    end
end

-- все цвета темы пересчитываются по реальным объектам окна
local THEME_PROPS = { "BackgroundColor3", "TextColor3", "TextStrokeColor3", "ScrollBarImageColor3" }
local function recolor(inst, oldp, newp)
    for _, prop in ipairs(THEME_PROPS) do
        local ok, v = pcall(function() return inst[prop] end)
        if ok and typeof(v) == "Color3" then
            for _, role in ipairs(ROLES) do
                if oldp[role] == v then
                    pcall(function() inst[prop] = newp[role] end)
                    break
                end
            end
        end
    end
    if inst:IsA("UIStroke") then
        for _, role in ipairs(ROLES) do
            if oldp[role] == inst.Color then inst.Color = newp[role] break end
        end
    elseif inst:IsA("UIGradient") then
        inst.Color = ColorSequence.new(newp.G1, newp.G2)
    end
end

local function applyTheme(name)
    local newp = THEMES[name]
    if not newp then return end
    local oldp = {
        BG = BG, DARK2 = DARK2, ORANGE = ORANGE, PURPLE = PURPLE, GREEN = GREEN, RED = RED,
        LILAC = LILAC, TXT_ACC = TXT_ACC, TXT_LIGHT = TXT_LIGHT, MUTED = MUTED, LOGTXT = LOGTXT,
        START_BG = START_BG, TOGGLE_ON = TOGGLE_ON, G1 = G1, G2 = G2,
    }
    BG, DARK2, ORANGE, PURPLE = newp.BG, newp.DARK2, newp.ORANGE, newp.PURPLE
    GREEN, RED, LILAC = newp.GREEN, newp.RED, newp.LILAC
    TXT_ACC, TXT_LIGHT, MUTED, LOGTXT = newp.TXT_ACC, newp.TXT_LIGHT, newp.MUTED, newp.LOGTXT
    START_BG, TOGGLE_ON, G1, G2 = newp.START_BG, newp.TOGGLE_ON, newp.G1, newp.G2
    themeName = name

    for _, d in ipairs(gui:GetDescendants()) do
        local skip = d:IsDescendantOf(espFolder)
            or d:GetAttribute("NoTheme")
            or (d.Parent and d.Parent:GetAttribute("NoTheme"))
        if not skip then recolor(d, oldp, newp) end
    end

    -- состояния, зависящие от цветов
    title.Text = titleText()
    pumpkin.Text = newp.icon1
    logLabel.Text = changelogText("#" .. ORANGE:ToHex(), "#" .. GREEN:ToHex())
    refreshModes()
    refreshStart()
    refreshFull()
    for _, r in ipairs(toggleRefreshers) do r() end
    showTab(curTab, true)
    refreshThemeButtons()
    saveSettings()
end

for i, name in ipairs(THEME_ORDER) do
    local p = THEMES[name]
    local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(136, 44),
        Position = UDim2.fromOffset(8 + col * 148, 40 + row * 52),
        BackgroundColor3 = p.DARK2, Text = p.icon1 .. "  " .. name, TextColor3 = p.TXT_LIGHT,
        Font = Enum.Font.Gotham, TextSize = 13, AutoButtonColor = true, ZIndex = 21,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, themePanel)
    b:SetAttribute("NoTheme", true)
    round(b, 10)
    stroke(b, p.ORANGE, 1.5)
    new("UIPadding", { PaddingLeft = UDim.new(0, 22) }, b)
    local sw = new("Frame", {
        Size = UDim2.fromOffset(5, 24), Position = UDim2.new(0, 8, 0.5, -12),
        BackgroundColor3 = p.ORANGE, ZIndex = 22,
    }, b)
    round(sw, 3)
    themeButtons[name] = b
    b.Activated:Connect(function() applyTheme(name) end)
end
refreshThemeButtons()

-- прозрачность окна: 0 / 15 / 30 / 45 %
local ALPHAS = { 0, 0.15, 0.3, 0.45 }
local alphaBtn = new("TextButton", {
    Size = UDim2.fromOffset(284, 34), Position = UDim2.fromOffset(8, 262),
    BackgroundColor3 = DARK2, TextColor3 = TXT_LIGHT,
    Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 21,
}, themePanel)
round(alphaBtn, 10)
stroke(alphaBtn, PURPLE, 1.5)
local function refreshAlphaBtn()
    alphaBtn.Text = "🪟 Прозрачность окна: " .. math.floor(windowAlpha * 100 + 0.5) .. "%"
end
alphaBtn.Activated:Connect(function()
    local idx = 1
    for i, a in ipairs(ALPHAS) do
        if math.abs(a - windowAlpha) < 0.01 then idx = i end
    end
    windowAlpha = ALPHAS[idx % #ALPHAS + 1]
    main.BackgroundTransparency = windowAlpha
    refreshAlphaBtn()
    saveSettings()
end)
refreshAlphaBtn()

new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 34), Position = UDim2.fromOffset(8, 302),
    BackgroundTransparency = 1, TextWrapped = true, TextColor3 = MUTED,
    Text = writefile and "Тема и прозрачность сохраняются автоматически"
        or "Твой Delta не умеет сохранять файлы: тема сбросится после перезапуска",
    Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 21,
}, themePanel)

local closePanelBtn = new("TextButton", {
    Size = UDim2.fromOffset(284, 36), Position = UDim2.fromOffset(8, 342),
    BackgroundColor3 = START_BG, TextColor3 = Color3.fromRGB(255, 255, 255),
    Text = "Закрыть", Font = Enum.Font.GothamMedium, TextSize = 14, ZIndex = 21,
}, themePanel)
round(closePanelBtn, 10)
-- кнопка «Закрыть» красится как кнопка «Старт» (START_BG): themed-роль есть

local function setPanel(v) themePanel.Visible = v end
paletteBtn.Activated:Connect(function() setPanel(not themePanel.Visible) end)
closePanelBtn.Activated:Connect(function() setPanel(false) end)

do
    local dragging, startPos, frameStart = false, nil, nil
    connect(title.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startPos, frameStart = true, i.Position, main.Position
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startPos
            main.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + d.X,
                                      frameStart.Y.Scale, frameStart.Y.Offset + d.Y)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

connect(UIS.InputBegan, function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F then
        setEnabled(not S.Enabled)
    elseif i.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

connect(player.CharacterAdded, function()
    PL.dropSeat()
    if C.Invis then
        C.Invis = false
        for _, r in ipairs(toggleRefreshers) do r(false) end
    end
    blacklist = {}
    hold = nil
    lastSafe = nil
    recoverTimes = {}
    S.Bag = 0
    lastProgress = os.clock()
    updateStatus()
end)

for _, b in ipairs(gui:GetDescendants()) do
    if b:IsA("TextButton") and b ~= startBtn then
        b.Activated:Connect(function() play(sndClick) end)
    end
end

setSpeed(S.Speed)
refreshModes()
refreshFull()
refreshStart()
showTab("farm", true)
tryHookRemote()
updateStatus()

if AUTO_START then
    task.delay(3, function()
        if alive then setEnabled(true) end
    end)
end

env.HalloweenFarm = function()
    alive = false
    S.Enabled = false
    releaseHold()
    PL.stop()
    if X.kill then pcall(X.kill) end
    clearEverything()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
end
