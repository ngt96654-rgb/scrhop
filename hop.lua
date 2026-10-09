local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local LP = game:GetService("Players").LocalPlayer
local MaxPing, MinPlr, MaxPlr, Region, Retry = 120, 1, 40, "", 8
local function fetch(c)
    local u = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    if c then u = u.."&cursor="..c end
    local ok, r = pcall(function() return game:HttpGet(u) end)
    if not ok or not r then return {}, nil end
    local ok2, d = pcall(function() return HS:JSONDecode(r) end)
    if not ok2 then return {}, nil end
    return d.data or {}, d.nextPageCursor
end
local function ok(s)
    if s.id == game.JobId then return false end
    if s.playing >= s.maxPlayers then return false end
    if s.playing < MinPlr or s.playing > MaxPlr then return false end
    if Region ~= "" and s.region and s.region:lower() ~= Region:lower() then return false end
    if s.ping and s.ping > MaxPing then return false end
    return true
end
local function all()
    local t, c, n = {}, nil, 0
    repeat
        local d, nx = fetch(c)
        for _, s in pairs(d) do if ok(s) then table.insert(t, s) end end
        c = nx; n = n + 1; task.wait(0.15)
    until not c or n >= 5
    return t
end
local function best()
    local l = all()
    if #l == 0 then return nil end
    table.sort(l, function(a, b) return (a.ping or 999) < (b.ping or 999) end)
    return l[math.random(1, math.min(5, #l))]
end
for i = 1, Retry do
    local b = best()
    if b then
        local okk = pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, b.id, LP) end)
        if okk then return end
    end
    task.wait(1)
end