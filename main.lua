local bolt = require("bolt")
bolt.checkversion(1, 0)

local fonts = require("fonts")

local checkframe = false
local checktime = bolt.time()
local checkinterval = 500000 -- check twice per second

local redpixel = bolt.createsurfacefromrgba(1, 1, "\xD0\x10\x10\xFF")
local blackpixel = bolt.createsurfacefromrgba(1, 1, "\x00\x00\x00\xFF")

-- both buffs and debuffs go in this table
local buffs = {
  pulsecore = {},
  cindercore = {},
  firelighter = {},
  rockofresilience = {},
  godbook = {},
  valentinesflip = {},
  valentinesslam = {},
  aura = {},
  scrimshaw = {},
  summon = {},
  clancitadel = {},
  bonfire = {},
  cannonballs = {},
  cannontimer = {},
  grimoire = {},

  incenseavantoe = {},
  incensecadantine = {},
  incensedwarfweed = {},
  incensefellstalk = {},
  incenseguam = {},
  incenseharralander = {},
  incenseirit = {},
  incensekwuarm = {},
  incenselantadyme = {},
  incensemarrentill = {},
  incenseranarr = {},
  incensesnapdragon = {},
  incensespiritweed = {},
  incensetarromin = {},
  incensetoadflax = {},
  incensetorstol = {},
  incensewergali = {},

  overload = {},
  elderoverload = {},
  perfectplus = {},
  poisonous = {},
  antipoison = {},
  prayerrenewal = {},
  antifire = {},
  aggressionpotion = {},
  noadrenalinepotion = {},
  nopowerburst = {},
}
local nextrender2dbuff = nil
local nextrender2ddebuff = nil
local nextrender2dpxleft = 0
local nextrender2dpxtop = 0
for name, buff in pairs(buffs) do
  buff.name = name
  buff.active = false
end

local stats = {
  health = {fraction = 1.0, barpixels = "\xf8\x76\x50\x00\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\x00"},
  prayer = {fraction = 1.0, barpixels = "\x82\x61\xb5\x00\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\x00"},
  summoning = {fraction = 1.0, barpixels = "\x1f\xac\xa0\x00\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\x00"}
}

-- 3d models that may be of interest
local models = {
  lostsoul = {center = bolt.point(0, 600, 0), boxsize = 370, boxthickness = 115}, -- lost/unstable/vengeful
  penguinagent = {center = bolt.point(0, 200, 0), boxsize = 450, boxthickness = 120}, -- 001 through 007, but not the disguised ones
  serenspirit = {center = bolt.point(0, 350, 0), boxsize = 400, boxthickness = 100},
  firespirit = {center = bolt.point(0, 300, 0), boxsize = 310, boxthickness = 105}, -- normal and divine
}

local rgbaleniency = 2.5 / 255.0

-- compares rgb 0-1 to target values using a leniency value
local function rougheqrgb (r, g, b, tr, tg, tb)
  return math.abs(r - (tr / 255.0)) <= rgbaleniency and math.abs(g - (tg / 255.0)) <= rgbaleniency and math.abs(b - (tb / 255.0)) <= rgbaleniency
end

-- compares rgba 0-1 to target values using a leniency value
local function rougheqrgba (r, g, b, a, tr, tg, tb, ta)
  return rougheqrgb(r, g, b, tr, tg, tb) and math.abs(a - (ta / 255.0)) <= rgbaleniency
end

-- leaves "\x00\x00\x00\x00\x00\x00\x00\x00\x26\x28\x26\x00\x39\x3c\x39\x03\x57\x57\x57\x09\x65\x66\x65\x0d\x73\x75\x73\x16\x73\x75\x73\x23\x73\x75\x73\x34\x7e\x7e\x7e\x3a\x89\x88\x89\x41\x94\x92\x94\x47\x97\x94\x97\x43\xa5\xa2\xa5\x43\xa5\xa2\xa5\x43\xa5\xa2\xa5\x43\xa5\xa6\xa5\x46\x9c\x9c\x9c\x46\x94\x93\x94\x3d\x94\x93\x94\x35\x8c\x8a\x8c\x2a\x7e\x7d\x7e\x25\x70\x71\x70\x21\x63\x65\x63\x18\x60\x61\x60\x11\x6b\x6d\x6b\x0c\x60\x61\x60\x09\x4a\x49\x4a\x07\x42\x41\x42\x05\x2e\x2c\x2e\x01\x1b\x18\x1b\x00\x08\x04\x08\x00\x00\x00\x00\x00\x08\x08\x08\x00\x08\x08\x08\x00\x18\x18\x18\x00\x39\x38\x39\x02\x49\x48\x49\x04\x5a\x58\x5a\x0a\x6b\x69\x6b\x0d\x73\x71\x73\x18\x73\x71\x73\x1e\x7b\x79\x7b\x2a\x8c\x8a\x8c\x31\x9f\x9f\x9f\x37\xa5\xa6\xa5\x37\x9f\x9f\x9f\x37\x99\x98\x99\x41\x8e\x8f\x8e\x3e\x8e\x8f\x8e\x3e\x8e\x8f\x8e\x3e\x73\x71\x73\x3e\x60\x61\x60\x3d\x55\x55\x55\x38\x55\x55\x55\x2f\x4a\x49\x4a\x26\x20\x20\x20\x17\x20\x20\x20\x12\x08\x08\x08\x08\x08\x08\x08\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

-- row 6 (zero-indexed) of the bottom-right corner of the popup message background,
-- which is the last thing to be rendered before the text itself
local popupmessageimages = {
  -- white
  ["\x0a\x0a\x0a\xc5\x0a\x0a\x0a\xc9\x00\x00\x01\xcc\x00\x00\x01\xd3\x00\x00\x01\xd9\x00\x00\x01\xda\x00\x00\x01\xd9\xfd\xfd\xfd\xff\xfd\xfd\xfd\xff\x00\x00\x01\x71"] = 1,
  -- red
  ["\x0a\x0a\x0a\xc5\x0a\x0a\x0a\xc9\x00\x00\x01\xcc\x00\x00\x01\xd3\x00\x00\x01\xd9\x00\x00\x01\xda\x00\x00\x01\xd9\xa9\x18\x18\xff\xa9\x18\x18\xff\x00\x00\x01\x71"] = 2,
}

local any3dobjectexists = false
local any3dobjectfound = false
local render3dlookup = {
  [672] = function (event)
    -- normal fire spirit
    local x, y, z = event:vertexpoint(1):get()
    if x == 0 and y == 401 and z == 0 then return models.firespirit end
    return nil
  end,

  [1248] = function (event)
    -- divine fire spirit
    local x, y, z = event:vertexpoint(1):get()
    if x == 0 and y == 394 and z == 0 then return models.firespirit end
    return nil
  end,

  [1737] = function (event)
    local x, y, z = event:vertexpoint(1):get()
    if x == -49 and y == 589 and z == -85 then return models.lostsoul end
    if x == -42 and y == 574 and z == -92 then return models.lostsoul end
    return nil
  end,

  [2652] = function (event)
    local x, y, z = event:vertexpoint(1):get()
    if x == 27 and y == 349 and z == -53 then return models.serenspirit end
    return nil
  end,

  [27171] = function (event)
    local x, y, z = event:vertexpoint(1):get()
    if x == -35 and y == 329 and z == -33 then return models.penguinagent end
    return nil
  end,
}

local rendericonlookup1godbookmatch = function (event)
  local x, y, z = event:modelvertexpoint(1, 1):get()
  if x == -7 and y == 67 and z == 81 then return buffs.godbook, nil end
  return nil, nil
end

local rendericonlookup1 = {
  [210] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 8 and y == 68 and z == -32 then return buffs.firelighter, nil end
    return nil, nil
  end,

  [240] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 68 and y == 184 and z == -60 then return buffs.cannonballs, buffs.cannontimer end
    return nil, nil
  end,

  [546] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 0 and y == 9 and z == -35 then return buffs.valentinesflip, nil end
    return nil, nil
  end,

  [588] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 16 and y == 5 and z == 27 then
      local r, g, b = event:modelvertexcolour(1, 37)
      
      if rougheqrgb(r, g, b, 43, 69, 14) then
        local r, g, b = event:modelvertexcolour(1, 1)
        if rougheqrgb(r, g, b, 92, 101, 64) then return buffs.incenseavantoe, nil end
        if rougheqrgb(r, g, b, 114, 113, 47) then return buffs.incensetarromin, nil end
      end
      if rougheqrgb(r, g, b, 35, 47, 24) then return buffs.incensecadantine, nil end
      if rougheqrgb(r, g, b, 26, 51, 27) then return buffs.incensedwarfweed, nil end
      if rougheqrgb(r, g, b, 39, 42, 3) then return buffs.incensefellstalk, nil end
      if rougheqrgb(r, g, b, 51, 63, 5) then return buffs.incenseguam, nil end
      if rougheqrgb(r, g, b, 55, 69, 43) then return buffs.incenseharralander, nil end
      if rougheqrgb(r, g, b, 50, 76, 39) then return buffs.incenseirit, nil end
      if rougheqrgb(r, g, b, 64, 74, 30) then return buffs.incensekwuarm, nil end
      if rougheqrgb(r, g, b, 47, 61, 58) then return buffs.incenselantadyme, nil end
      if rougheqrgb(r, g, b, 45, 82, 16) then return buffs.incensemarrentill, nil end
      if rougheqrgb(r, g, b, 38, 54, 22) then return buffs.incenseranarr, nil end
      if rougheqrgb(r, g, b, 64, 85, 34) then return buffs.incensesnapdragon, nil end
      if rougheqrgb(r, g, b, 79, 124, 102) then return buffs.incensespiritweed, nil end
      if rougheqrgb(r, g, b, 29, 45, 18) then return buffs.incensetoadflax, nil end
      if rougheqrgb(r, g, b, 16, 52, 25) then return buffs.incensetorstol, nil end
      if rougheqrgb(r, g, b, 83, 43, 49) then return buffs.incensewergali, nil end
    end
    return nil, nil
  end,

  [1281] = function (event)
    -- pantheon aura
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 198 and y == 56 and z == -61 then return buffs.aura, nil end
    return nil, nil
  end,

  [1488] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 9 and y == 43 and z == -58 then return buffs.rockofresilience, nil end
    return nil, nil
  end,

  [2664] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 300 and y == 56 and z == 313 then return buffs.valentinesslam, nil end
    return nil, nil
  end,

  [2811] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -76 and y == 35 and z == -27 then return buffs.grimoire, nil end
    return nil, nil
  end,

  [2460] = rendericonlookup1godbookmatch, -- wen
  [2502] = rendericonlookup1godbookmatch, -- jas
  [2856] = rendericonlookup1godbookmatch, -- elidinis
}

local rendericonlookup2 = {
  [24] = function (event)
    if event:modelvertexcount(2) == 1626 then
      local x, y, z = event:modelvertexpoint(2, 1):get()
      if not (x == -30 and y == 11 and z == -19) then return nil end
      local r, g, b, _ = event:modelvertexcolour(2, 1626)
      if rougheqrgb(r, g, b, 69, 147, 168) then return buffs.elderoverload, nil end
      if rougheqrgb(r, g, b, 126, 202, 223) then return buffs.perfectplus, nil end
    end
    return nil, nil
  end,

  [90] = function (event)
    if event:modelvertexcount(2) == 288 then
      local x, y, z = event:modelvertexpoint(2, 1):get()
      if not (x == -20 and y == 84 and z == 4) then return nil, nil end
      local r, g, b, _ = event:modelvertexcolour(2, 49)
      if rougheqrgb(r, g, b, 94, 8, 60) then return buffs.aggressionpotion, nil end
    end
    return nil, nil
  end,

  [120] = function (event)
    if event:modelvertexcount(2) == 600 then
      local x, y, z = event:modelvertexpoint(2, 1):get()
      local r, g, b, a = event:modelvertexcolour(2, 1)
      if x == 0 and y == 134 and z == 28 and rougheqrgba(r, g, b, a, 127, 127, 127, 128) then return nil, buffs.nopowerburst end
    end
    return nil, nil
  end,

  [1239] = function (event)
    local r, g, b, _ = event:modelvertexcolour(1, 1)
    if rougheqrgb(r, g, b, 16, 169, 174) then return buffs.pulsecore, nil end
    if rougheqrgb(r, g, b, 155, 45, 14) then return buffs.cindercore, nil end
    return nil, nil
  end,
}

local function drawbox (worldpoint, viewmatrix, projmatrix, boxradius, boxthickness)
  local px, py, pz = worldpoint:transform(viewmatrix):get()
  local left, top, depth = bolt.point(px - boxradius, py + boxradius, pz):transform(projmatrix):aspixels()
  local right, bottom, _ = bolt.point(px + boxradius, py - boxradius, pz):transform(projmatrix):aspixels()
  local leftinner, topinner, _ = bolt.point(px + boxthickness - boxradius, py + boxradius - boxthickness, pz):transform(projmatrix):aspixels()
  if depth < 0.0 or depth > 1.0 then return end
  left = math.floor(left)
  top = math.floor(top)
  right = math.floor(right)
  bottom = math.floor(bottom)
  local width = right - left
  local height = bottom - top
  local edgew = leftinner - left
  local edgeh = topinner - top
  redpixel:drawtoscreen(0, 0, 1, 1, left, top, width, edgeh) -- top
  redpixel:drawtoscreen(0, 0, 1, 1, left, top, edgew, height) -- left
  redpixel:drawtoscreen(0, 0, 1, 1, right - edgew, top, edgew, height) -- right
  redpixel:drawtoscreen(0, 0, 1, 1, left, bottom - edgeh, width, edgeh) -- bottom
  blackpixel:drawtoscreen(0, 0, 1, 1, left, top, width, 1) -- top
  blackpixel:drawtoscreen(0, 0, 1, 1, left, top, 1, height) -- left
  blackpixel:drawtoscreen(0, 0, 1, 1, right - 1, top, 1, height) -- right
  blackpixel:drawtoscreen(0, 0, 1, 1, left, bottom - 1, width, 1) -- bottom
  blackpixel:drawtoscreen(0, 0, 1, 1, left + edgew, top + edgeh, width - (edgew * 2), 1) -- top
  blackpixel:drawtoscreen(0, 0, 1, 1, left + edgew, top + edgeh, 1, height - (edgeh * 2)) -- left
  blackpixel:drawtoscreen(0, 0, 1, 1, right - (edgew + 1), top + edgeh, 1, height - (edgeh * 2)) -- right
  blackpixel:drawtoscreen(0, 0, 1, 1, left + edgew, bottom - (edgeh + 1), width - (edgew * 2), 1) -- bottom
end

local function readstatbar (event, startindex, stat)
  local verticesperimage = event:verticesperimage()
  if event:vertexcount() < startindex + (verticesperimage * 4 - 1) then return end
  local barindex = startindex + (verticesperimage * 3)
  local ax, ay, aw, ah, _, _ = event:vertexatlasdetails(barindex)
  if aw == 106 and ah == 4 and event:texturecompare(ax, ay, stat.barpixels) then
    local backgroundbarleft, _ = event:vertexxy(startindex + 2)
    local backgroundbarright, _ = event:vertexxy(startindex + (verticesperimage * 2))
    local barright, _ = event:vertexxy(barindex)
    local barleft, _ = event:vertexxy(barindex + 2)
    local offset = barleft - backgroundbarleft
    stat.percent = (barright - barleft) / (backgroundbarright - offset - barleft)
  else
    stat.percent = 0
  end  
end

local lastxpplusheight = nil
local lastxpgaintime = bolt.time()
local lastxpcheck = bolt.time()
local xpcheckinterval = 100000 -- ten times per second
local docheckxpgain = false
bolt.onrender2d(function (event)
  local t = bolt.time()
  if not (checkframe or docheckxpgain) then return end

  if nextrender2dbuff then
    fonts:tryreadbuffdetails(event, 1, nextrender2dbuff, nextrender2dpxleft, nextrender2dpxtop, true)
    nextrender2dbuff = nil
  end
  if nextrender2ddebuff then
    fonts:tryreadbuffdetails(event, 1, nextrender2ddebuff, nextrender2dpxleft, nextrender2dpxtop, false)
    nextrender2ddebuff = nil
  end

  local vertexcount = event:vertexcount()
  local verticesperimage = event:verticesperimage()
  for i = 1, vertexcount, verticesperimage do
    local ax, ay, aw, ah, _, _ = event:vertexatlasdetails(i)
    if checkframe then
      local pxleft, pxtop = event:vertexxy(i + 2)
      local readbuff = function (buff, isbuff)
        return fonts:tryreadbuffdetails(event, i + verticesperimage, buff, pxleft, pxtop, isbuff)
      end

      if aw == ah then
        if aw == 26 then
          if event:texturecompare(ax, ay + 10, "\x00\x00\x01\x00\x41\x4d\x53\xb8\x4d\x5c\x63\xff\x33\x30\x33\xff\x44\x23\x22\xff\x4d\x2b\x29\xff\x52\x31\x2d\xff\x52\x31\x2d\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x55\x34\x31\xff\x52\x31\x2d\xff\x52\x31\x2d\xff\x4d\x2b\x29\xff\x44\x23\x22\xff\x33\x30\x33\xff\x4d\x5c\x63\xff\x41\x4d\x53\xb8\x00\x00\x01\x00") then
            readstatbar(event, i + verticesperimage, stats.health)
          elseif event:texturecompare(ax, ay + 10, "\x00\x00\x01\x00\x00\x00\x01\x00\x3c\x49\x4f\x96\x4c\x5c\x63\xff\x36\x3d\x4a\xff\x40\x36\x60\xff\x4a\x3e\x71\xff\x52\x44\x7c\xff\x54\x45\x81\xff\x57\x48\x84\xff\x57\x48\x84\xff\x57\x48\x84\xff\x57\x48\x84\xff\x57\x48\x84\xff\x57\x48\x84\xff\x57\x48\x84\xff\x57\x48\x84\xff\x57\x48\x84\xff\x54\x45\x81\xff\x52\x44\x7c\xff\x4a\x3e\x71\xff\x40\x36\x60\xff\x36\x3d\x4a\xff\x4f\x60\x67\xff\x3c\x49\x4f\x96\x00\x00\x01\x00") then
            readstatbar(event, i + verticesperimage, stats.prayer)
          elseif event:texturecompare(ax, ay + 10, "\x00\x00\x01\x00\x42\x4e\x54\xb8\x4b\x5c\x64\xff\x2b\x38\x3d\xff\x2a\x3c\x43\xff\x32\x44\x4b\xff\x34\x4a\x53\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x3a\x52\x5b\xff\x34\x4a\x53\xff\x32\x44\x4b\xff\x2a\x3c\x43\xff\x2b\x38\x3d\xff\x4b\x5c\x64\xff\x42\x4e\x54\xb8\x00\x00\x01\x00") then
            readstatbar(event, i + verticesperimage, stats.summoning)
          end
        elseif aw == 27 then
          if event:texturecompare(ax, ay + 5, "\x63\x2d\x12\xff\x6f\x3d\x19\xff\x6f\x3d\x19\xff\x00\x00\x01\xff\xab\x8b\x35\xff\xab\x8b\x35\xff\x63\x2d\x12\xff\x68\x08\x06\xff\xc4\x9b\x3d\xff\x6b\x52\x1f\xff\x6b\x52\x1f\xff\x16\x1a\x1c\xff\x16\x1a\x1c\xff\x16\x1a\x1c\xff\x16\x1a\x1c\xff\x16\x1a\x1c\xff\x6b\x52\x1f\xff\x6b\x52\x1f\xff\x6b\x52\x1f\xff\xb4\x0e\x25\xff\x68\x08\x06\xff\xc4\x9b\x3d\xff\x00\x00\x01\xff\x8a\x54\x10\xff\x6f\x3d\x19\xff\x6f\x3d\x19\xff\x63\x2d\x12\xff") then
            readbuff(buffs.aura, true)
          elseif event:texturecompare(ax, ay + 10, "\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x07\x00\x00\x01\x32\x27\x3b\x48\xd4\x27\x3b\x48\xff\x7f\x9c\xad\xff\x7f\x9c\xad\xff\x43\x5e\x67\xff\x43\x5e\x67\xff\x43\x5e\x67\xff\x4e\x74\x81\xff\x6c\x91\xb2\xff\x6c\x91\xb2\xff\x63\x78\x87\xff\x4e\x74\x81\xff\x69\x8b\x9d\xff\x94\xb8\xc5\xff\x94\xb8\xc5\xff\x8c\xda\xf1\xff\xb8\xe4\xf9\xff\xb8\xe4\xf9\xff\xd2\xdf\xe5\xff\x39\x41\x46\xd5\x00\x00\x01\x2a\x00\x00\x01\x03") then
            readbuff(buffs.summon, true)
          elseif event:texturecompare(ax, ay + 10, "\x3f\x6f\x0e\xff\x4f\x75\x09\xff\x59\x84\x0c\xff\x59\x84\x0c\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x00\x00\x01\xff\x0e\x0d\x0d\xff\x0e\x0d\x0d\xff\x0e\x0d\x0d\xff\x0e\x0d\x0d\xff\x0e\x0d\x0d\xff\x00\x00\x01\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x69\x93\x12\xff\x59\x84\x0c\xff\x59\x84\x0c\xff\x4f\x75\x09\xff\x3f\x6f\x0e\xff") then
            readbuff(buffs.overload, true)
          elseif event:texturecompare(ax, ay + 20, "\x64\x43\x07\xff\x64\x43\x07\xff\x76\x4c\x09\xff\x76\x4c\x09\xff\x8a\x54\x10\xff\x00\x00\x01\xff\x69\x8b\x9d\xff\x69\x8b\x9d\xff\x69\x8b\x9d\xff\x43\x5e\x67\xff\x47\x31\x17\xff\xb4\x0e\x25\xff\xd5\x19\x22\xff\xd5\x19\x22\xff\xd5\x19\x22\xff\xb4\x0e\x25\xff\x47\x31\x17\xff\x39\x41\x46\xff\x43\x5e\x67\xff\x39\x47\x5d\xff\x00\x00\x01\xff\x8a\x54\x10\xff\x8a\x54\x10\xff\x8a\x54\x10\xff\x76\x4c\x09\xff\x64\x43\x07\xff\x64\x43\x07\xff") then
            readbuff(buffs.noadrenalinepotion, false)
          elseif event:texturecompare(ax, ay + 10, "\x14\x31\x49\xff\x20\x3f\x63\xff\x20\x3f\x63\xff\x24\x4d\x6d\xff\x00\x00\x01\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x8c\x8b\x87\xff\x00\x00\x01\xff\x24\x4d\x6d\xff\x20\x3f\x63\xff\x16\x3e\x54\xff") then
            readbuff(buffs.scrimshaw, true)
          elseif event:texturecompare(ax, ay + 14, "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xff\x00\x00\x01\xff\x2c\x3e\x55\xff\x6c\x94\xb4\xff\x93\xbc\xda\xff\x52\x76\x95\xff\x2d\x38\x4a\xff\x00\x00\x01\xff\x00\x00\x01\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xff\x00\x00\x01\xff\x33\x43\x53\xff\x5d\x83\xa2\xff\x9b\xc1\xdc\xff\x7d\xa9\xc8\xff\x45\x64\x7e\xff\x23\x2d\x42\xff\x00\x00\x01\xff\x00\x00\x01\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00") then
            readbuff(buffs.prayerrenewal, true)
          end
        elseif aw == 32 then
          if event:texturecompare(ax, ay + 20, "\xd9\xd0\x46\x00\xd9\xd0\x46\x00\xd9\xd0\x46\x00\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\x00\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\x40\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\xff\xd9\xd0\x46\x00\xd9\xd0\x46\x00\xd9\xd0\x46\x00\xd9\xd0\x46\x00\xd9\xd0\x46\x00") then
            readbuff(buffs.clancitadel, true)
          end
        elseif aw == 81 then
          if event:texturecompare(ax, ay + 40, "\x2f\x34\x38\xff\x2f\x34\x38\xff\x30\x35\x39\xff\x49\x2e\x2c\xff\x49\x2e\x2c\xff\x49\x2e\x2d\xff\xdc\x26\x66\xff\xde\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\x4a\x2e\x2c\xff\x49\x2e\x2c\xff\x49\x2d\x2c\xff\x30\x33\x37\xff\x33\x33\x35\xff\x43\x37\x32\xff\xe2\x62\x1d\xff\xee\x6a\x19\xff\xef\x6f\x18\xff\xed\x74\x18\xff\x7e\x4e\x24\xff\x3e\x34\x2b\xff\x33\x2f\x2b\xff\x33\x2f\x29\xff\x41\x35\x26\xff\x80\x5a\x1f\xff\xd8\x90\x17\xff\xf6\xa6\x16\xff\xf8\xac\x18\xff\xf0\xa9\x1a\xff\xbc\x7b\x1d\xff\xb0\x67\x1a\xff\xb0\x68\x1b\xff\xb1\x66\x1e\xff\xd1\x39\x51\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xd2\x3e\x53\xff\xb4\x76\x23\xff\xb3\x78\x20\xff\xb3\x76\x1e\xff\xbd\x78\x15\xff\xf2\xa6\x0e\xff\xfa\xab\x0d\xff\xdd\x97\x10\xff\x32\x2c\x25\xff\x29\x28\x27\xff\x29\x29\x29\xff\x2d\x2c\x2a\xff\x58\x40\x27\xff\xf1\x84\x16\xff\xf2\x7f\x15\xff\xf1\x77\x17\xff\xf0\x71\x18\xff\xee\x6b\x1a\xff\xbd\x58\x21\xff\x37\x34\x34\xff\x32\x33\x35\xff\x30\x33\x37\xff\x49\x2d\x2b\xff\x4a\x2d\x2c\xff\x4a\x2e\x2c\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xde\x26\x67\xff\xdc\x26\x66\xff\x4a\x2f\x2d\xff\x49\x2e\x2c\xff\x49\x2e\x2c\xff\x30\x35\x39\xff\x2f\x34\x38\xff\x2f\x34\x38\xff") then
            readbuff(buffs.antifire, true)
          elseif event:texturecompare(ax, ay + 40, "\x2f\x34\x38\xff\x2f\x34\x38\xff\x30\x35\x39\xff\x4e\x23\x33\xff\x4e\x23\x33\xff\x4e\x24\x33\xff\xda\x31\x60\xff\xde\x32\x60\xff\xdd\x32\x60\xff\xdd\x31\x60\xff\xdd\x32\x60\xff\xde\x32\x61\xff\x4f\x23\x33\xff\x4e\x23\x32\xff\x4e\x23\x32\xff\x2f\x33\x37\xff\x2f\x33\x36\xff\x2d\x33\x34\xff\x2d\x33\x32\xff\x2b\x35\x2e\xff\x29\x37\x2b\xff\x27\x3a\x26\xff\x24\x3f\x22\xff\x22\x44\x1d\xff\x20\x4b\x18\xff\x37\xbe\x05\xff\x3d\xc1\x05\xff\x3e\xb5\x07\xff\x3f\xb1\x08\xff\x3f\xb1\x08\xff\x3e\xb1\x08\xff\x42\xac\x09\xff\x52\x8a\x15\xff\x53\x80\x17\xff\x53\x80\x17\xff\x56\x7e\x18\xff\xb3\x49\x4a\xff\xdc\x32\x60\xff\xdc\x32\x61\xff\xdc\x32\x60\xff\xdc\x33\x61\xff\xdc\x32\x61\xff\xdc\x32\x61\xff\xdc\x33\x60\xff\xb3\x49\x4a\xff\x57\x7d\x19\xff\x53\x80\x17\xff\x53\x80\x17\xff\x52\x8a\x15\xff\x42\xac\x0a\xff\x3f\xb1\x08\xff\x3f\xb1\x08\xff\x3f\xb1\x08\xff\x3e\xb5\x07\xff\x3d\xc1\x05\xff\x37\xbe\x05\xff\x1f\x4b\x18\xff\x22\x45\x1c\xff\x24\x40\x21\xff\x27\x3a\x27\xff\x29\x37\x2b\xff\x2b\x35\x2e\xff\x2d\x33\x32\xff\x2d\x33\x34\xff\x2f\x33\x35\xff\x2f\x33\x37\xff\x4e\x23\x32\xff\x4e\x23\x32\xff\x4f\x23\x33\xff\xde\x32\x61\xff\xdd\x31\x61\xff\xdd\x32\x61\xff\xde\x31\x61\xff\xdd\x32\x61\xff\xdb\x31\x60\xff\x4f\x24\x33\xff\x4e\x23\x33\xff\x4e\x23\x33\xff\x30\x35\x39\xff\x2f\x34\x38\xff\x2f\x34\x38\xff") then
            readbuff(buffs.antipoison, true)
          elseif event:texturecompare(ax, ay + 40, "\x2f\x34\x37\xff\x2e\x33\x37\xff\x2e\x33\x37\xff\x2e\x33\x35\xff\x2d\x32\x34\xff\x2c\x31\x32\xff\x2b\x2f\x31\xff\x29\x2e\x2e\xff\x28\x2c\x2b\xff\x26\x2a\x29\xff\x23\x2d\x25\xff\x24\x2e\x25\xff\x26\x2c\x20\xff\x39\x1e\x14\xff\x40\x1f\x14\xff\x4e\x37\x32\xff\x5e\x58\x5e\xff\x63\x5e\x69\xff\x66\x64\x71\xff\x6b\x68\x76\xff\x6f\x6b\x7c\xff\x81\x80\x90\xff\x8d\x91\x9d\xff\x43\x4b\x42\xff\x20\x28\x1e\xff\x1f\x28\x1e\xff\x1f\x26\x1d\xff\x1e\x22\x1b\xff\x1d\x20\x1a\xff\x1d\x26\x1a\xff\x40\x41\x2e\xff\x94\x82\x64\xff\x91\x7e\x63\xff\x50\x43\x34\xff\x4a\x3f\x32\xff\x4c\x3f\x32\xff\x5a\x4b\x3b\xff\x88\x71\x5b\xff\xa2\x88\x6d\xff\xa6\x8c\x72\xff\xa9\x8e\x73\xff\xaa\x8e\x74\xff\xa7\x8c\x71\xff\x8e\x76\x5f\xff\x5f\x4e\x3c\xff\x4e\x40\x32\xff\x4c\x40\x31\xff\x54\x47\x35\xff\xa2\x8d\x6d\xff\xa4\x92\x71\xff\x44\x46\x31\xff\x1d\x26\x1b\xff\x1d\x22\x1a\xff\x1e\x22\x1b\xff\x1f\x26\x1d\xff\x1f\x28\x1d\xff\x20\x28\x1e\xff\x35\x3e\x33\xff\x7d\x81\x88\xff\x76\x75\x85\xff\x6d\x69\x79\xff\x68\x65\x73\xff\x65\x62\x6e\xff\x63\x5d\x6a\xff\x5e\x57\x5f\xff\x4d\x37\x32\xff\x3f\x1f\x15\xff\x34\x21\x17\xff\x24\x2e\x24\xff\x24\x2e\x25\xff\x24\x2d\x26\xff\x26\x2a\x29\xff\x28\x2c\x2c\xff\x29\x2e\x2e\xff\x2b\x30\x31\xff\x2c\x31\x33\xff\x2d\x32\x34\xff\x2e\x33\x35\xff\x2e\x33\x37\xff\x2e\x33\x37\xff\x2f\x34\x37\xff") then
            readbuff(buffs.poisonous, true)
          end
        elseif aw == 128 then
          if event:texturecompare(ax, ay + 64, "\x01\x01\x01\xff\x01\x01\x01\xff\x01\x01\x01\xff\x05\x06\x08\xff\x2c\x2f\x34\xff\x40\x43\x47\xff\x01\x01\x01\xff\x0a\x0b\x0b\xff\x01\x01\x01\xff\x01\x01\x01\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x05\x0e\x10\xff\x0b\x11\x13\xff\x1b\x14\x13\xff\x12\x14\x16\xff\x1b\x14\x13\xff\x09\x19\x1c\xff\x26\x1d\x1a\xff\x52\x34\x17\xff\x5e\x33\x1e\xff\x6f\x4e\x1c\xff\x87\x5d\x19\xff\x7f\x50\x1e\xff\x7f\x3e\x18\xff\x8f\x33\x19\xff\xbb\x2b\x12\xff\xce\x2c\x11\xff\xb3\x37\x18\xff\x6f\x3f\x1a\xff\x0c\x1e\x21\xff\x32\x20\x1c\xff\x7f\x3e\x18\xff\xbe\x48\x19\xff\xbb\x36\x16\xff\xab\x38\x1b\xff\xa0\x3d\x19\xff\xbe\x62\x21\xff\xbe\x62\x21\xff\xd0\x5f\x24\xff\xdc\x64\x22\xff\xdc\x65\x2b\xff\xdf\x86\x36\xff\xe4\x95\x47\xff\xe6\x98\x59\xff\xe4\x97\x71\xff\xe4\x97\x71\xff\xe8\x9f\x7d\xff\xe8\x9f\x7d\xff\xef\xb9\x95\xff\xf4\xcc\xa5\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf4\xcc\xa5\xff\xef\xb9\x95\xff\xe8\x9f\x7d\xff\xe1\xb0\x81\xff\xe1\xb0\x81\xff\xdf\xa5\x60\xff\xef\xb7\x60\xff\xef\xb7\x60\xff\xe9\xa6\x51\xff\xdf\xa5\x60\xff\xdf\xa5\x60\xff\xe6\x98\x59\xff\xe3\x84\x46\xff\xe4\x95\x47\xff\xc8\x82\x47\xff\xc8\x82\x47\xff\xd5\x4a\x25\xff\xd2\x3b\x19\xff\xd2\x3b\x19\xff\xd2\x3b\x19\xff\xc4\x38\x13\xff\x5e\x33\x1e\xff\x27\x2a\x2c\xff\x27\x2a\x2c\xff\x2c\x2f\x34\xff\x48\x37\x24\xff\x93\x28\x15\xff\xaf\x2b\x14\xff\xaf\x2b\x14\xff\x8b\x28\x15\xff\x6e\x2d\x1c\xff\x58\x26\x1c\xff\x93\x28\x15\xff\x9b\x28\x14\xff\x7e\x24\x14\xff\x7e\x24\x14\xff\x5e\x33\x1e\xff\x48\x36\x1b\xff\x5e\x37\x14\xff\x26\x1d\x1a\xff\x06\x12\x14\xff\x06\x12\x14\xff\x06\x12\x14\xff\x05\x0e\x10\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x01\x01\x01\xff\x01\x01\x01\xff\x0a\x0b\x0b\xff\x01\x01\x01\xff\x40\x43\x47\xff\x2c\x2f\x34\xff\x05\x06\x08\xff\x01\x01\x01\xff\x01\x01\x01\xff\x01\x01\x01\xff") then
            readbuff(buffs.bonfire, true)
          end
        end
      elseif aw == 10 and ah == 11 then
        local p = popupmessageimages[event:texturedata(ax, ay + 6, aw * 4)]
        if p then
          local s = fonts:tryreadpopup(event, i + verticesperimage)
        end
      end
    end

    if docheckxpgain and aw == 22 and ah == 24 and event:texturecompare(ax, ay + 9, "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00") and event:texturecompare(ax, ay + 10, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00") then
      local r, g, b = event:vertexcolour(i)
      local _, y = event:vertexxy(i)
      local lowestcolour = 2.0 / 255.0
      if ((not lastxpplusheight) or (lastxpplusheight <= y)) and (r < lowestcolour and g < lowestcolour and b < lowestcolour) then
        lastxpplusheight = y
        lastxpgaintime = t
      end
    end
  end
end)

bolt.onrender3d(function (event)
  if not (checkframe or any3dobjectexists) then return end
  local f = render3dlookup[event:vertexcount()]
  if f ~= nil then
    local model = f(event)
    if model then
      any3dobjectfound = true
      if (bolt.time() % 600000) <= 480000 then
        drawbox(model.center:transform(event:modelmatrix()), event:viewmatrix(), event:projectionmatrix(), model.boxsize, model.boxthickness)
      end
    end
  end
end)

bolt.onrendericon(function (event)
  if not checkframe then return end
  local modelcount = event:modelcount()
  local f = nil
  if modelcount == 1 then
    f = rendericonlookup1[event:modelvertexcount(1)]
  elseif modelcount == 2 then
    f = rendericonlookup2[event:modelvertexcount(1)]
  end
  if f ~= nil then
    nextrender2dbuff, nextrender2ddebuff = f(event)
    nextrender2dpxleft, nextrender2dpxtop, _, _ = event:xywh()
  end
end)

local lastnonafkaction = bolt.time()
bolt.onmousemotion(function (event)
  lastnonafkaction = bolt.time()
end)
bolt.onmousebutton(function (event)
  lastnonafkaction = bolt.time()
end)

bolt.onswapbuffers(function (event)
  any3dobjectexists = any3dobjectfound
  any3dobjectfound = false
  nextrender2dbuff = nil
  nextrender2ddebuff = nil

  if checkframe then
    for _, buff in pairs(buffs) do
      if not buff.foundoncheckframe then
        buff.active = false
      end
    end
    checkframe = false
  end

  local t = bolt.time()
  if t > checktime + checkinterval then
    checkframe = true
    checktime = checktime + checkinterval
    if checktime < t then
      checktime = t
    end

    for _, buff in pairs(buffs) do
      buff.foundoncheckframe = false
    end
  end

  if t > lastxpcheck + xpcheckinterval then
    docheckxpgain = true
    lastxpcheck = lastxpcheck + xpcheckinterval
    if lastxpcheck < t then
      lastxpcheck = t
    end
  else
    docheckxpgain = false
  end
end)
