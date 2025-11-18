local bolt = require("bolt")
bolt.checkversion(1, 0)

local base64 = require("base64")

local unitspertile = 512

local alertsfilename = "alerts.json"
local cfgname = "config.ini"
local cfg = {}

-- table of rulesets that determine how each rule should alert
local rulesets = {}

-- table of the rules that determine when to alert.
-- every rule has a "ruleset" value which is one of the objects in the "ruleset" table.
-- types of rule and their values (other than the "ruleset" value):
-- afktimer:
-- - alert: whether the timer is currently past the configured threshold (micros)
-- - threshold: time threshold, in microseconds, after which to alert the player
-- buff:
-- - alert: whether the alert condition is currently met
-- - ref: one of the entries in the buffs table
-- - comparator: one of the functions in the buffcomparators table
-- - threshold: the value that the actual buff timer will be compared to by comparators (except active and inactive, which ignore this value)
-- chat:
-- - find: the lua pattern string that each new chat message will be compared to, sending an alert if it matches
-- craftingprogress:
-- - alert: true if a crafting menu exists that's past the threshold, OR if no crafting menu exists
-- - threshold: a number between 0.0 and 1.0, for which an alert will be sent if the crafting progress exceeds this fraction
-- model:
-- - alert: whether the model is currently on-screen
-- - ref: one of the entries in the models table
-- popup:
-- - find: the lua pattern string that each new popup message will be compared to, sending an alert if it matches
-- position:
-- - region{x,y}{1,2}: the lower and upper bounds, inclusive, of the region of tiles to alert on
-- - regionh{1,2}: optionally, the lower and upper bounds of the height of the region to alert on
-- - regionisinside: boolean, if true the rule will alert when inside the region, if false it will alert when outside the region
-- stat:
-- - alert: whether the alert condition is currently met
-- - ref: one of the entries in the stats table
-- - threshold: a number between 0.0 and 1.0, for which an alert will be sent if the stat falls below this fraction
-- xpgain:
-- - alert: whether the timeout is currently met, if it has a threshold, otherwise unused
-- - threshold: the amount of time, in microseconds, to alert after no xp is gained; if nil, the rule will alert immediately on any xp gain
local rules = {}

(function ()
  local cfgstring = bolt.loadconfig(cfgname)
  if cfgstring ~= nil then
    for k, v in string.gmatch(cfgstring, "(%w+)=(%w+)") do
      cfg[k] = v
    end
  end
end)()

local function saveconfig ()
  local cfgstring = ""
  for k, v in pairs(cfg) do
    cfgstring = string.format("%s%s=%s\n", cfgstring, k, tostring(v))
  end
  bolt.saveconfig(cfgname, cfgstring)
end

local browser = (function ()
  local alertsstring = bolt.loadconfig(alertsfilename)
  local url = "plugin://app/dist/index.html"
  if alertsstring ~= nil then
    url = url .. '?list=' .. base64.encode(alertsstring)
  end
  return bolt.createembeddedbrowser(cfg.windowx or 0, cfg.windowy or 0, cfg.windoww or 250, cfg.windowh or 180, url)
end)()
browser:oncloserequest(bolt.close)

local updatecoordsnoop = function (_, _, _) end
local updatecoordsinbrowser = updatecoordsnoop
local forceupdatecoords = false
local browserisgettingcoords = false
local opentempbrowser = function (width, height, url)
  local menubrowser = bolt.createbrowser(width, height, url)
  local done = false
  if browserisgettingcoords then
    -- a browser is already being sent coords, so this one can't
    menubrowser:oncloserequest(function () menubrowser:close() end)
    menubrowser:onmessage(function (message)
      if done then return end
      browser:sendmessage(message)
      menubrowser:close()
      done = true
    end)
  else
    menubrowser:onmessage(function (message)
      if done then return end
      browserisgettingcoords = false
      browser:sendmessage(message)
      menubrowser:close()
      done = true
    end)
    menubrowser:oncloserequest(function ()
      browserisgettingcoords = false
      updatecoordsinbrowser = updatecoordsnoop
      menubrowser:close()
    end)
    updatecoordsinbrowser = function (x, y, z)
      local buf = bolt.createbuffer(12)
      buf:setuint32(0, x)
      buf:setuint32(4, y)
      buf:setuint32(8, z)
      menubrowser:sendmessage(buf)
    end
    browserisgettingcoords = true
    forceupdatecoords = true
  end
end

-- todo: forge phoenix & divine forge phoenix???, divine carpet dust, guthixian butterfly, catalyst of alteration (bik book)
local models = {
  -- 3d
  lostsoul = {center = bolt.point(0, 600, 0), boxsize = 370, boxthickness = 115}, -- lost/unstable/vengeful
  penguinagent = {center = bolt.point(0, 200, 0), boxsize = 450, boxthickness = 120}, -- 001 through 007, but not the disguised ones
  serenspirit = {center = bolt.point(0, 350, 0), boxsize = 400, boxthickness = 100},
  firespirit = {center = bolt.point(0, 300, 0), boxsize = 310, boxthickness = 105}, -- normal and divine
  eliteslayermob = {center = bolt.point(0, 150, 0), boxsize = 500, boxthickness = 120}, -- the white ring around all elite slayer mobs
  manifestedknowledge = {center = bolt.point(0, 580, 0), boxsize = 200, boxthickness = 60, anim = true},
  chroniclefragment = {center = bolt.point(0, 580, 0), boxsize = 200, boxthickness = 60, anim = true}, -- also elder chronicle
  runesphere = {center = bolt.point(0, 490, 0), boxsize = 350, boxthickness = 120, anim = true}, -- doesn't include the core (see runespherecore)

  -- billboard
  divineblessing = {center = bolt.point(0, 520, 0), boxsize = 300, boxthickness = 90},
  runespherecore = {center = bolt.point(0, 340, 0), boxsize = 350, boxthickness = 120},
  temporalinstability = {center = bolt.point(0, 340, 0), boxsize = 300, boxthickness = 90}, -- things that appear near anachronia remototem
}

-- both buffs and debuffs go in this table
local buffs = {
  -- potions
  overload = {},
  perfectplus = {},
  poisonous = {},
  antipoison = {},
  prayerrenewal = {},
  antifire = {},
  aggressionpotion = {},
  spiritattractionpotion = {},
  noadrenalinepotion = {},
  nopowerburst = {},

  -- powders
  powderofburials = {},
  powderofpenance = {},
  powderofitemprotection = {},
  powderofprotection = {},
  powderofpulverising = {},
  powderofdefence = {},

  -- incense
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
  
  -- miscellaneous combat-related
  bonfire = {},
  cannonballs = {},
  cannontimer = {},
  grimoire = {},
  signoflife = {},
  darkness = {},
  animatedead = {},
  noexcalibur = {},
  noritualshard = {},
  roarofosseous = {},
  godbook = {},
  scrimshaw = {},
  summon = {},
  stoneofjas = {},

  -- miscellaneous not-necessarily-combat-related
  pulsecore = {},
  cindercore = {},
  firelighter = {},
  rockofresilience = {},
  valentinesflip = {},
  valentinesslam = {},
  loveletter = {},
  proteanpowerup = {},
  clancitadel = {},
  wiseperk = {},
  porter = {},
  aura = {},
  crystalmask = {},
  luminiteinjector = {},
  materialmanual = {},
  hispecmonocle = {},
  tarpaulinsheet = {},
  triplecharms = {},
  archaeologiststea = {},
  giftoffriendship = {},
  knowledgebomb = {},
}

local buffcomparators = {
  lessthan = function (rule, buff)
    return not buff.foundoncheckframe or buff.number == nil or buff.number < rule.threshold
  end,
  greaterthan = function (rule, buff)
    return buff.foundoncheckframe and buff.number and buff.number > rule.threshold
  end,
  parenslessthan = function (rule, buff)
    return buff.foundoncheckframe and buff.parensnumber and buff.parensnumber < rule.threshold
  end,
  parensgreaterthan = function (rule, buff)
    return buff.foundoncheckframe and buff.parensnumber and buff.parensnumber > rule.threshold
  end,
  active = function (_, buff)
    return buff.foundoncheckframe
  end,
  inactive = function (_, buff)
    return not buff.foundoncheckframe
  end,
}

local stats = {
  health = {fraction = 1.0},
  adrenaline = {fraction = 1.0},
  prayer = {fraction = 1.0},
  summoning = {fraction = 1.0},
}

-- top row of pixels from106x4 images
local statbars = {
  ["\xf8\x76\x50\x00\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf8\x76\x50\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\xff\xf3\x57\x37\x00"]
    = stats.health,
  ["\xed\xcd\x1f\x00\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xed\xcd\x1f\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xed\xcd\x1f\xff\xed\xcd\x1f\xff\xed\xcd\x1f\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xed\xcd\x1f\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\xff\xe3\xb6\x21\x00"]
    = stats.adrenaline,
  ["\x82\x61\xb5\x00\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x82\x61\xb5\xff\x74\x51\xab\xff\x74\x51\xab\xff\x74\x51\xab\x00"]
    = stats.prayer,
  ["\x1f\xac\xa0\x00\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x1f\xac\xa0\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\xff\x18\x9e\x8f\x00"]
    = stats.summoning,
}

local messagehandlers = {
  [1] = function (message)
    -- open "new ruleset" menu
    opentempbrowser(270, 450, "plugin://app/dist/ruleset.html")
  end,

  [2] = function (message)
    -- open "edit ruleset" menu
    opentempbrowser(270, 450, "plugin://app/dist/ruleset.html?" .. string.sub(message, 3))
  end,

  [3] = function (message)
    -- save alerts file
    local filecontents = string.sub(message, 3)
    bolt.saveconfig(alertsfilename, filecontents)
  end,

  [4] = function (message)
    -- open "add rule" menu
    opentempbrowser(270, 480, "plugin://app/dist/rule.html?" .. string.sub(message, 3))
  end,

  [5] = function (message)
    -- new rules and rulesets
    rulesets = {}
    rules = {}
    for _, model in pairs(models) do
      model.dohighlight = false
    end

    local cursor = 2
    local readbool = function ()
      local r = bolt.buffergetuint8(message, cursor)
      cursor = cursor + 1
      return r ~= 0
    end
    local readuint = function ()
      local r = bolt.buffergetuint32(message, cursor)
      cursor = cursor + 4
      return r
    end
    local readint = function ()
      local r = bolt.buffergetint32(message, cursor)
      cursor = cursor + 4
      return r
    end
    local readstring = function ()
      local len = readuint()
      if len == 0 then return '' end
      local r = string.sub(message, cursor + 1, cursor + len)
      cursor = cursor + len
      return r
    end
    local readoptional = function (f)
      if readbool() then return f() end
      return nil
    end

    local rulesetcount = readuint()
    local ruleindex = 1
    for i = 1, rulesetcount do
      local rulesetid = readstring()
      local rulesetpaused = readbool()
      local alert = readbool()
      local flashwindow = readbool()
      local onlyifunfocused = readbool()
      local ruleset = { id = rulesetid, paused = rulesetpaused, alert = alert, flashwindow = flashwindow, onlyifunfocused = onlyifunfocused }

      local rulecount = readuint()
      for _ = 1, rulecount do
        local ruleid = readstring()
        local type = readstring()
        local rulepaused = readbool()
        local alert = readoptional(readbool)
        local threshold = readoptional(readint)
        local ref = readoptional(readstring)
        local comparator = readoptional(readstring)
        local find = readoptional(readstring)
        local regionx1 = readoptional(readint)
        local regionx2 = readoptional(readint)
        local regiony1 = readoptional(readint)
        local regiony2 = readoptional(readint)
        local regionh1 = readoptional(readint)
        local regionh2 = readoptional(readint)
        local regionisinside = readoptional(readbool)

        if ref then
          if type == 'model' then
            ref = models[ref]
            if ref then ref.dohighlight = true end
          elseif type == 'buff' then
            ref = buffs[ref]
            comparator = buffcomparators[comparator]
          elseif type == 'stat' then
            ref = stats[ref]
          end
        end

        if type == 'craftingprogress' or type == 'stat' then
          threshold = threshold / 100.0
        end

        rules[ruleindex] = {
          id = ruleid, paused = rulepaused, ruleset = ruleset, type = type, alert = alert, threshold = threshold, ref = ref, comparator = comparator, find = find,
          regionx1 = regionx1, regionx2 = regionx2, regiony1 = regiony1, regiony2 = regiony2, regionh1 = regionh1, regionh2 = regionh2, regionisinside = regionisinside,
        }
        ruleindex = ruleindex + 1
        forceupdatecoords = true
      end
      rulesets[i] = ruleset
    end
  end,
}

browser:onmessage(function (message)
  local msgtype = bolt.buffergetuint16(message, 0)
  local handler = messagehandlers[msgtype]
  if handler then handler(message) end
end)

browser:onreposition(function (event)
  local x, y, w, h = event:xywh()
  cfg.windowx = x
  cfg.windowy = y
  cfg.windoww = w
  cfg.windowh = h
  saveconfig()
end)

local modules = {
  chat = require("modules.chat.chat"),
  buffs = require("modules.buffs.buffs"),
  popup = require("modules.popup.popup"),
}

local checkframe = false
local checktime = bolt.time()
local checkinterval = 500000 -- check twice per second

local redpixel = bolt.createsurfacefromrgba(1, 1, "\xD0\x10\x10\xFF")
local blackpixel = bolt.createsurfacefromrgba(1, 1, "\x00\x00\x00\xFF")

local nextrender2dbuff = nil
local nextrender2ddebuff = nil
local nextrender2dpxleft = 0
local nextrender2dpxtop = 0
for name, buff in pairs(buffs) do
  buff.name = name
  buff.active = false
end

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

local sendalertmessage = function (rule, state)
  local message = string.format("\x03\x00ruleset_id=%s&rule_id=%s&alert=%s", rule.ruleset.id, rule.id, state and '1' or '0')
  browser:sendmessage(message)
end

local setrulealertstate = function (rule, state)
  if rule.alert ~= state then sendalertmessage(rule, state) end
  rule.alert = state
end

local alertbyrule = function (rule)
  if rule.paused or rule.ruleset.paused or rule.alert then return end
  if rule.ruleset.onlyifunfocused and bolt.isfocused() then return end
  if rule.alert ~= nil then
    setrulealertstate(rule, true)
  else
    sendalertmessage(rule, true)
  end
  local ruleset = rule.ruleset
  if ruleset.alert then return end
  ruleset.alert = true
  if ruleset.flashwindow then bolt.flashwindow() end
end

local any3dobjectexists = false
local any3dobjectfound = false
local render3dlookup = {
  [150] = function (event)
    -- manifested knowledge
    local anim = event:animated()
    local x, y, z = event:vertexpoint(1):get()
    if anim and x == -44 and y == 589 and z == -33 then return models.manifestedknowledge end
    -- could differentiate between chronicle fragment and elder chronicle here based on vertex colour,
    -- but I don't expect anyone wants that
    if anim and x == -46 and y == 594 and z == -230 then return models.chroniclefragment end
    return nil
  end,

  [672] = function (event)
    -- normal fire spirit
    local x, y, z = event:vertexpoint(1):get()
    if x == 0 and y == 401 and z == 0 then return models.firespirit end
    return nil
  end,

  [1200] = function (event)
    -- runesphere (not the core, as that's a billboard)
    local x, y, z = event:vertexpoint(1):get()
    if x == 215 and y == 350 and z == 0 then return models.runesphere end
    return nil
  end,

  [1239] = function (event)
    -- runesphere (not the core, as that's a billboard)
    local x, y, z = event:vertexpoint(1):get()
    if x == 215 and y == 350 and z == 0 then return models.runesphere end
    return nil
  end,

  [1248] = function (event)
    -- divine fire spirit
    local x, y, z = event:vertexpoint(1):get()
    if x == 0 and y == 394 and z == 0 then return models.firespirit end
    return nil
  end,

  [1533] = function (event)
    -- runesphere (not the core, as that's a billboard)
    local x, y, z = event:vertexpoint(1):get()
    if x == -215 and y == 350 and z == 0 then return models.runesphere end
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

  [6612] = function (event)
    local x, y, z = event:vertexpoint(1):get()
    if x == 298 and y == 131 and z == 163 then return models.eliteslayermob end
    return nil
  end,

  [27171] = function (event)
    local x, y, z = event:vertexpoint(1):get()
    if x == -35 and y == 329 and z == -33 then return models.penguinagent end
    return nil
  end,
}

local anybillboardexists = false
local anybillboardfound = false
local renderbillboardlookup = {
  [66] = function (event)
    local r, g, b = event:vertexcolour(1)
    if rougheqrgb(r, g, b, 239, 237, 59) then return models.runespherecore end
    return nil
  end,

  [360] = function (event)
    local r, g, b = event:vertexcolour(1)
    if rougheqrgb(r, g, b, 17, 17, 33) then return models.temporalinstability end
    return nil
  end,

  [552] = function (event)
    local r, g, b = event:vertexcolour(1)
    if rougheqrgb(r, g, b, 127, 120, 52) then return models.divineblessing end
    return nil
  end,
}

local rendericonlookup1godbookmatch = function (event)
  local x, y, z = event:modelvertexpoint(1, 1):get()
  if x == -7 and y == 67 and z == 81 then return buffs.godbook, nil end
  return nil, nil
end

local rendericonlookup1 = {
  [72] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -76 and y == 0 and z == 0 then return nil, buffs.signoflife end
    return nil, nil
  end,

  [138] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -56 and y == 12 and z == -72 then return buffs.materialmanual, nil end
    return nil, nil
  end,

  [144] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -16 and y == 12 and z == 16 then return nil, buffs.noritualshard end
    return nil, nil
  end,

  [180] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -1 and y == 4 and z == -9 then return buffs.loveletter, nil end
    return nil, nil
  end,

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

  [270] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -62 and y == 16 and z == 7 then return buffs.triplecharms, nil end
    return nil, nil
  end,

  [285] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 0 and y == 20 and z == 128 then return buffs.tarpaulinsheet, nil end
    return nil, nil
  end,

  [366] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -86 and y == 15 and z == -21 then return buffs.porter, nil end
    return nil, nil
  end,

  [378] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -16 and y == 68 and z == 36 then return buffs.archaeologiststea, nil end
    return nil, nil
  end,

  [525] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -44 and y == 52 and z == -80 then
      local r, g, b = event:modelvertexcolour(1, 1)
      if rougheqrgb(r, g, b, 62, 16, 13) then return buffs.powderofburials, nil end
      if rougheqrgb(r, g, b, 20, 18, 18) then return buffs.powderofdefence, nil end
      if rougheqrgb(r, g, b, 26, 39, 64) then return buffs.powderofitemprotection, nil end
      if rougheqrgb(r, g, b, 90, 72, 37) then return buffs.powderofpenance, nil end
      if rougheqrgb(r, g, b, 43, 64, 41) then return buffs.powderofprotection, nil end
      if rougheqrgb(r, g, b, 38, 26, 64) then return buffs.powderofpulverising, nil end
    end
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

  [726] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 48 and y == 12 and z == 139 then return nil, buffs.noexcalibur end
    return nil, nil
  end,

  [888] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 41 and y == 6 and z == -24 then return buffs.luminiteinjector, nil end
    return nil, nil
  end,

  [1182] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -135 and y == 466 and z == -43 then return buffs.knowledgebomb, nil end
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

  [2388] = function (event)
    -- scripture of bik
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == 41 and y == 46 and z == 21 then return buffs.godbook, nil end
    return nil, nil
  end,

  [2652] = function (event)
    -- scripture of amascut
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -2 and y == 66 and z == 16 then return buffs.godbook, nil end
    return nil, nil
  end,

  [2658] = function (event)
    local x, y, z = event:modelvertexpoint(1, 1):get()
    if x == -2 and y == 0 and z == 21 then return buffs.proteanpowerup, nil end
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
  [2484] = rendericonlookup1godbookmatch, -- ful
  [2502] = rendericonlookup1godbookmatch, -- jas
  [2856] = rendericonlookup1godbookmatch, -- elidinis
}

local rendericonlookup2 = {
  [24] = function (event)
    -- note: perfect plus and supreme overload have the same icon, so we can't distinguish them.
    -- here we assume the icon is a perfect plus potion since those are far more popular/useful.
    if event:modelvertexcount(2) == 1626 then
      local x, y, z = event:modelvertexpoint(2, 1):get()
      if not (x == -30 and y == 11 and z == -19) then return nil end
      local r, g, b, _ = event:modelvertexcolour(2, 1626)
      if rougheqrgb(r, g, b, 69, 147, 168) then return buffs.overload, nil end -- elder overload icon
      if rougheqrgb(r, g, b, 126, 202, 223) then return buffs.perfectplus, nil end
    end
    return nil, nil
  end,

  [66] = function (event)
    if event:modelvertexcount(2) == 240 then
      local x, y, z = event:modelvertexpoint(2, 1):get()
      if not (x == 4 and y == 84 and z == 20) then return nil, nil end
      local r, g, b, _ = event:modelvertexcolour(2, 49)
      if rougheqrgb(r, g, b, 142, 29, 123) then return buffs.spiritattractionpotion, nil end
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

  [276] = function (event)
    if event:modelvertexcount(2) == 18 then
      local x, y, z = event:modelvertexpoint(1, 1):get()
      if x == 40 and y == 28 and z == 16 then return buffs.hispecmonocle, nil end
      return nil, nil
    end
  end,

  [1239] = function (event)
    local r, g, b, _ = event:modelvertexcolour(2, 1)
    if rougheqrgb(r, g, b, 16, 169, 174) then return buffs.pulsecore, nil end
    if rougheqrgb(r, g, b, 155, 45, 14) then return buffs.cindercore, nil end
    return nil, nil
  end,

  [1314] = function (event)
    if event:modelvertexcount(2) == 1347 then
      local x, y, z = event:modelvertexpoint(1, 1):get()
      if x == 8 and y == 58 and z == 65 then return buffs.stoneofjas, nil end
      return nil, nil
    end
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

local setbuffdetails = function (buff, isvalid, number, parensnumber)
  if isvalid then
    buff.number = number
    buff.parensnumber = parensnumber
    buff.active = true
    buff.foundoncheckframe = true
  end
end

local lastxpplusheight = nil
local lastxpgaintime = bolt.time()
local didgainxp = false
local lastxpcheck = bolt.time()
local xpcheckinterval = 100000 -- ten times per second
local docheckxpgain = false
local popupfound = false
local craftingprogress = nil
local lastpopupmessage = nil
local mostrecentmessage = nil
local checkchat = false
bolt.onrender2d(function (event)
  local t = bolt.time()
  if not (checkframe or docheckxpgain) then return end

  if nextrender2dbuff then
    setbuffdetails(nextrender2dbuff, modules.buffs:tryreadbuffdetails(event, 1, nextrender2dpxleft, nextrender2dpxtop, true))
    nextrender2dbuff = nil
  end
  if nextrender2ddebuff then
    setbuffdetails(nextrender2ddebuff, modules.buffs:tryreadbuffdetails(event, 1, nextrender2dpxleft, nextrender2dpxtop, false))
    nextrender2ddebuff = nil
  end

  local vertexcount = event:vertexcount()
  local verticesperimage = event:verticesperimage()
  for i = 1, vertexcount, verticesperimage do
    local ax, ay, aw, ah, _, _ = event:vertexatlasdetails(i)
    if checkframe then
      local pxleft, pxtop = event:vertexxy(i + 2)
      local readbuff = function (buff, isbuff)
        setbuffdetails(buff, modules.buffs:tryreadbuffdetails(event, i + verticesperimage, pxleft, pxtop, isbuff))
      end

      if aw == ah then
        if aw == 11 then
          if checkchat and event:texturecompare(ax, ay + 5, '\x00\x00\x01\xff\xc4\xd0\xcd\xff\xc4\xd0\xcd\xff\xd9\xe0\xde\xff\xc4\xd0\xcd\xff\xc4\xd0\xcd\xff\xc4\xd0\xcd\xff\xc4\xd0\xcd\xff\x9f\xd9\xce\xff\x9f\xd9\xce\xff\x00\x00\x01\xff') then
            local ischat, isscrolled = modules.chat:tryreadchat(event, i + verticesperimage, mostrecentmessage, function (message)
              mostrecentmessage = message
              local _, _, strippedmessage = string.find(message, "^%[%d%d:%d%d:%d%d%](.+)")
              if strippedmessage then
                for _, rule in ipairs(rules) do
                  if rule.type == "chat" then
                    if string.find(strippedmessage, rule.find) then
                      alertbyrule(rule)
                    end
                  end
                end
              end
            end)
            if ischat then
              checkchat = false
              if isscrolled then
                print("can't read chat because it's scrolled up")
              end
            end
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
          elseif event:texturecompare(ax, ay + 4, "\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x22\x74\xcb\xd2\xed\x82\xdb\xe2\xff\x49\x8d\x92\xa6\x00\x00\x01\x2e\x00\x00\x01\x1b\x00\x00\x01\x21\x0a\x13\x14\x35\x3c\x73\x77\x70\x5c\xa3\xa8\xab\x6c\xc3\xca\xdb\x7b\xd8\xdf\xfb\x82\xdb\xe2\xff\x82\xdb\xe2\xff\x82\xdb\xe2\xff\x82\xdb\xe2\xff\x82\xdb\xe2\xff\x7b\xd8\xdf\xfc\x6c\xc3\xca\xdc\x5c\xa3\xa8\xad\x3c\x73\x77\x74\x0f\x1b\x1c\x37\x00\x00\x01\x1b\x00\x00\x01\x08\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00") then
            readbuff(buffs.wiseperk, true)
          end
        elseif aw == 60 then
          if event:texturecompare(ax, ay + 30, "\x14\x10\x57\x0f\x10\x08\x47\x00\x14\x10\x57\x00\x14\x10\x57\x00\x14\x10\x57\x00\x14\x10\x57\x2d\x10\x35\x54\x8d\x1a\x34\x6b\xd9\x1a\x34\x6b\xfa\x4e\xb6\x65\xff\x96\xf3\x7c\xff\x96\xf3\x7c\xff\x96\xf3\x7c\xff\x3d\xf1\x7a\xff\x0e\xd5\x55\xff\x0e\xd5\x55\xff\x15\xfa\x57\xff\x0e\xd5\x55\xff\x0e\xd5\x55\xff\x0e\xd5\x55\xff\x15\xfa\x57\xff\x15\xfa\x57\xff\x0e\x6b\x6b\xff\x1b\x15\x69\xff\x1a\x34\x6b\xff\x13\x55\x66\xff\x0e\xd5\x55\xff\x15\xfa\x57\xff\x1e\xf9\x65\xff\x0b\xd7\x6c\xff\x0a\x54\x40\xff\x04\x14\x21\xff\x08\x38\x38\xff\x0e\x8f\x4a\xff\x14\xd7\x3c\xff\x0b\xb6\x49\xff\x0b\xb6\x49\xff\x3c\xd2\x6b\xff\x7a\xf5\x7c\xff\x96\xf3\x7c\xff\x7a\xf5\x7c\xff\x7a\xf5\x7c\xff\x96\xf3\x7c\xff\xf9\xe7\x7b\xff\x8a\xa4\x66\xff\x5e\xda\x71\xff\x3c\xd2\x6b\xff\x25\xb8\x48\xff\x0a\x54\x30\xff\x08\x38\x38\xe1\x15\x54\x7e\x9a\x1a\x34\x6b\x4e\x14\x10\x57\x14\x14\x10\x57\x00\x14\x10\x57\x00\x14\x10\x57\x00\x14\x10\x57\x00\x14\x10\x57\x00\x14\x10\x57\x00\x14\x10\x57\x00") then
            readbuff(buffs.crystalmask, true)
          end
        elseif aw == 81 then
          if event:texturecompare(ax, ay + 40, "\x2f\x34\x38\xff\x2f\x34\x38\xff\x30\x35\x39\xff\x49\x2e\x2c\xff\x49\x2e\x2c\xff\x49\x2e\x2d\xff\xdc\x26\x66\xff\xde\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\x4a\x2e\x2c\xff\x49\x2e\x2c\xff\x49\x2d\x2c\xff\x30\x33\x37\xff\x33\x33\x35\xff\x43\x37\x32\xff\xe2\x62\x1d\xff\xee\x6a\x19\xff\xef\x6f\x18\xff\xed\x74\x18\xff\x7e\x4e\x24\xff\x3e\x34\x2b\xff\x33\x2f\x2b\xff\x33\x2f\x29\xff\x41\x35\x26\xff\x80\x5a\x1f\xff\xd8\x90\x17\xff\xf6\xa6\x16\xff\xf8\xac\x18\xff\xf0\xa9\x1a\xff\xbc\x7b\x1d\xff\xb0\x67\x1a\xff\xb0\x68\x1b\xff\xb1\x66\x1e\xff\xd1\x39\x51\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xd2\x3e\x53\xff\xb4\x76\x23\xff\xb3\x78\x20\xff\xb3\x76\x1e\xff\xbd\x78\x15\xff\xf2\xa6\x0e\xff\xfa\xab\x0d\xff\xdd\x97\x10\xff\x32\x2c\x25\xff\x29\x28\x27\xff\x29\x29\x29\xff\x2d\x2c\x2a\xff\x58\x40\x27\xff\xf1\x84\x16\xff\xf2\x7f\x15\xff\xf1\x77\x17\xff\xf0\x71\x18\xff\xee\x6b\x1a\xff\xbd\x58\x21\xff\x37\x34\x34\xff\x32\x33\x35\xff\x30\x33\x37\xff\x49\x2d\x2b\xff\x4a\x2d\x2c\xff\x4a\x2e\x2c\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xdf\x26\x67\xff\xde\x26\x67\xff\xdc\x26\x66\xff\x4a\x2f\x2d\xff\x49\x2e\x2c\xff\x49\x2e\x2c\xff\x30\x35\x39\xff\x2f\x34\x38\xff\x2f\x34\x38\xff") then
            readbuff(buffs.antifire, true)
          elseif event:texturecompare(ax, ay + 40, "\x2f\x34\x38\xff\x2f\x34\x38\xff\x30\x35\x39\xff\x4e\x23\x33\xff\x4e\x23\x33\xff\x4e\x24\x33\xff\xda\x31\x60\xff\xde\x32\x60\xff\xdd\x32\x60\xff\xdd\x31\x60\xff\xdd\x32\x60\xff\xde\x32\x61\xff\x4f\x23\x33\xff\x4e\x23\x32\xff\x4e\x23\x32\xff\x2f\x33\x37\xff\x2f\x33\x36\xff\x2d\x33\x34\xff\x2d\x33\x32\xff\x2b\x35\x2e\xff\x29\x37\x2b\xff\x27\x3a\x26\xff\x24\x3f\x22\xff\x22\x44\x1d\xff\x20\x4b\x18\xff\x37\xbe\x05\xff\x3d\xc1\x05\xff\x3e\xb5\x07\xff\x3f\xb1\x08\xff\x3f\xb1\x08\xff\x3e\xb1\x08\xff\x42\xac\x09\xff\x52\x8a\x15\xff\x53\x80\x17\xff\x53\x80\x17\xff\x56\x7e\x18\xff\xb3\x49\x4a\xff\xdc\x32\x60\xff\xdc\x32\x61\xff\xdc\x32\x60\xff\xdc\x33\x61\xff\xdc\x32\x61\xff\xdc\x32\x61\xff\xdc\x33\x60\xff\xb3\x49\x4a\xff\x57\x7d\x19\xff\x53\x80\x17\xff\x53\x80\x17\xff\x52\x8a\x15\xff\x42\xac\x0a\xff\x3f\xb1\x08\xff\x3f\xb1\x08\xff\x3f\xb1\x08\xff\x3e\xb5\x07\xff\x3d\xc1\x05\xff\x37\xbe\x05\xff\x1f\x4b\x18\xff\x22\x45\x1c\xff\x24\x40\x21\xff\x27\x3a\x27\xff\x29\x37\x2b\xff\x2b\x35\x2e\xff\x2d\x33\x32\xff\x2d\x33\x34\xff\x2f\x33\x35\xff\x2f\x33\x37\xff\x4e\x23\x32\xff\x4e\x23\x32\xff\x4f\x23\x33\xff\xde\x32\x61\xff\xdd\x31\x61\xff\xdd\x32\x61\xff\xde\x31\x61\xff\xdd\x32\x61\xff\xdb\x31\x60\xff\x4f\x24\x33\xff\x4e\x23\x33\xff\x4e\x23\x33\xff\x30\x35\x39\xff\x2f\x34\x38\xff\x2f\x34\x38\xff") then
            readbuff(buffs.antipoison, true)
          elseif event:texturecompare(ax, ay + 40, "\x2f\x34\x37\xff\x2e\x33\x37\xff\x2e\x33\x37\xff\x2e\x33\x35\xff\x2d\x32\x34\xff\x2c\x31\x32\xff\x2b\x2f\x31\xff\x29\x2e\x2e\xff\x28\x2c\x2b\xff\x26\x2a\x29\xff\x23\x2d\x25\xff\x24\x2e\x25\xff\x26\x2c\x20\xff\x39\x1e\x14\xff\x40\x1f\x14\xff\x4e\x37\x32\xff\x5e\x58\x5e\xff\x63\x5e\x69\xff\x66\x64\x71\xff\x6b\x68\x76\xff\x6f\x6b\x7c\xff\x81\x80\x90\xff\x8d\x91\x9d\xff\x43\x4b\x42\xff\x20\x28\x1e\xff\x1f\x28\x1e\xff\x1f\x26\x1d\xff\x1e\x22\x1b\xff\x1d\x20\x1a\xff\x1d\x26\x1a\xff\x40\x41\x2e\xff\x94\x82\x64\xff\x91\x7e\x63\xff\x50\x43\x34\xff\x4a\x3f\x32\xff\x4c\x3f\x32\xff\x5a\x4b\x3b\xff\x88\x71\x5b\xff\xa2\x88\x6d\xff\xa6\x8c\x72\xff\xa9\x8e\x73\xff\xaa\x8e\x74\xff\xa7\x8c\x71\xff\x8e\x76\x5f\xff\x5f\x4e\x3c\xff\x4e\x40\x32\xff\x4c\x40\x31\xff\x54\x47\x35\xff\xa2\x8d\x6d\xff\xa4\x92\x71\xff\x44\x46\x31\xff\x1d\x26\x1b\xff\x1d\x22\x1a\xff\x1e\x22\x1b\xff\x1f\x26\x1d\xff\x1f\x28\x1d\xff\x20\x28\x1e\xff\x35\x3e\x33\xff\x7d\x81\x88\xff\x76\x75\x85\xff\x6d\x69\x79\xff\x68\x65\x73\xff\x65\x62\x6e\xff\x63\x5d\x6a\xff\x5e\x57\x5f\xff\x4d\x37\x32\xff\x3f\x1f\x15\xff\x34\x21\x17\xff\x24\x2e\x24\xff\x24\x2e\x25\xff\x24\x2d\x26\xff\x26\x2a\x29\xff\x28\x2c\x2c\xff\x29\x2e\x2e\xff\x2b\x30\x31\xff\x2c\x31\x33\xff\x2d\x32\x34\xff\x2e\x33\x35\xff\x2e\x33\x37\xff\x2e\x33\x37\xff\x2f\x34\x37\xff") then
            readbuff(buffs.poisonous, true)
          elseif event:texturecompare(ax, ay + 20, "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x3e\x32\x2d\x15\x5f\x4d\x3f\xf4\x64\x52\x3e\xff\x68\x58\x3c\xff\xa6\x97\x65\xff\xde\xd0\x8a\xff\xe2\xd5\x8c\xff\xe3\xd6\x8c\xff\xe3\xd6\x8c\xff\xe4\xd6\x8c\xff\xe4\xd6\x8c\xff\xe4\xd6\x8c\xff\xe3\xd6\x8c\xff\xe3\xd6\x8c\xff\xe2\xd4\x8f\xff\xbf\xb9\x95\xff\x8b\x92\x9f\xff\x88\x8e\x9f\xff\x86\x8e\xa0\xff\x87\x8f\xa1\xff\x87\x8f\xa1\xff\x88\x8f\xa1\xff\x89\x90\xa1\xff\x8a\x90\xa1\xff\x8a\x90\xa1\xff\x8a\x91\xa2\xff\x8b\x91\xa3\xff\x8b\x92\xa3\xff\x8b\x91\xa3\xff\x8a\x91\xa3\xff\x8a\x91\xa3\xff\x8a\x91\xa1\xff\x73\x78\x8c\xff\x2e\x2f\x4d\xff\x2b\x2c\x4a\xff\x2b\x2b\x49\xff\x2a\x2b\x49\xff\x2b\x2b\x4a\xff\x2b\x2b\x4b\xff\x2b\x2d\x4b\xff\x2b\x2d\x4b\xff\x28\x29\x47\xed\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00") then
            readbuff(buffs.animatedead, true)
          end
        elseif aw == 84 then
          if event:texturecompare(ax, ay + 42, "\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x02\x12\x05\x04\x01\x83\x0b\x5a\x01\x73\x0a\x45\x16\x1d\x18\x03\x13\x22\x17\x04\x13\x22\x17\x05\x14\x2a\x19\x06\x13\x33\x1b\x09\x1a\x3b\x23\x0b\x1b\x43\x26\x0f\x1b\x4b\x26\x13\x1b\x53\x29\x18\x1c\x5b\x2b\x1e\x1d\x6c\x31\x23\x22\x73\x35\x2d\x23\x7b\x3a\x35\x1b\x7b\x34\x39\x0d\x3b\x19\x1f\x11\x44\x1d\x22\x5e\x98\x63\x6e\xa3\xcb\xa6\xb4\xab\xce\xaf\xbf\xba\xd7\xbd\xca\x92\xb3\x94\x9b\x92\xa7\x93\x92\x87\xac\x8b\x92\x87\xb6\x8b\x91\x68\xc8\x7f\x90\x2a\xbc\x50\x75\x2a\xbc\x50\x75\x2a\xbc\x50\x75\x2a\xbc\x50\x75\x2a\xbc\x50\x77\x2a\xbc\x50\x77\x2b\xc4\x52\x7a\x2b\xc4\x52\x80\x2d\xcb\x56\x84\x2d\xcb\x56\x8b\x2f\xd3\x5a\x95\x32\xdb\x5e\xa1\x43\xda\x6a\xb2\x5c\xf7\x85\xc7\x75\xfe\x99\xd9\x75\xfe\x99\xdd\x68\xfd\x8e\xdb\x13\x5a\x26\x3b\x3b\xc0\x41\x93\x3d\xfb\x41\xd5\x47\xfa\x4b\xd2\x00\x53\x05\x35\x01\x4b\x07\x31\x1c\x81\x36\x5d\x47\xc6\x65\x9f\x5c\xf7\x85\xd0\x68\xfd\x8e\xdb\x4d\xfd\x7b\xd7\x29\xba\x4e\x8b\x15\x58\x1c\x37\x1f\x80\x2a\x56\x00\x68\x07\x44\x05\x32\x0b\x1e\x29\xa4\x49\x60\x22\x8d\x3e\x48\x1b\x7b\x34\x39\x16\x69\x2c\x2c\x13\x5a\x26\x22\x11\x4c\x21\x1b\x0e\x42\x1c\x15\x0b\x33\x15\x0f\x09\x2b\x12\x0b\x07\x22\x0e\x08\x05\x1b\x0b\x06\x04\x14\x08\x04\x01\x73\x0a\x4a\x01\x83\x0b\x5c\x02\x12\x05\x05\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00") then
            readbuff(buffs.giftoffriendship, true)
          end
        elseif aw == 108 then
          if event:texturecompare(ax, ay + 54, "\x00\x00\x00\x03\x00\x00\x00\x05\x00\x00\x00\x0a\x00\x00\x00\x10\x00\x00\x00\x17\x00\x00\x00\x20\x00\x00\x00\x2b\x00\x00\x00\x38\x00\x00\x00\x46\x47\x40\x2e\x98\xc9\xb3\x76\xff\xcf\xb9\x7e\xff\xcf\xb9\x7e\xff\xce\xb9\x7d\xff\xcc\xb7\x7b\xff\xad\x9a\x63\xff\x5b\x4b\x32\xff\x54\x46\x31\xff\x55\x47\x32\xff\x7e\x6a\x43\xff\xb9\x9c\x61\xff\xac\x90\x59\xff\xbe\xa3\x66\xff\x81\x6c\x43\xff\x5b\x49\x32\xff\x51\x43\x31\xff\x48\x3e\x30\xff\x42\x3a\x2e\xff\x40\x39\x2e\xff\x41\x39\x2f\xff\x44\x3a\x30\xff\x47\x3c\x30\xff\x4c\x40\x30\xff\x53\x45\x30\xff\x58\x49\x31\xff\x5e\x4c\x33\xff\x9e\x82\x50\xff\xb5\x96\x5b\xff\xb5\x97\x5b\xff\xb6\x97\x5b\xff\xb2\x94\x5a\xff\xb0\x92\x58\xff\xb0\x92\x59\xff\xb3\x95\x5a\xff\xb4\x96\x5a\xff\xb3\x95\x5a\xff\xb8\x9a\x5d\xff\xbe\xa2\x63\xff\xbd\xa1\x62\xff\xbe\xa1\x64\xff\xbe\xa2\x65\xff\xbf\xa4\x67\xff\xb9\x9e\x61\xff\x89\x72\x48\xff\x5e\x4b\x33\xff\x5c\x49\x31\xff\x5b\x49\x31\xff\x5b\x49\x31\xff\x59\x48\x31\xff\x55\x46\x31\xff\x54\x45\x31\xff\x54\x45\x31\xff\x56\x46\x31\xff\x59\x49\x31\xff\x5b\x49\x31\xff\x5b\x49\x31\xff\x72\x5d\x3c\xff\xa3\x88\x54\xff\xba\x9c\x5f\xff\xbb\x9c\x5f\xff\xbb\x9c\x5f\xff\xb9\x9b\x5e\xff\xba\x9d\x5f\xff\xb6\x98\x5c\xff\xb4\x95\x5a\xff\xb4\x96\x5b\xff\xb1\x94\x5a\xff\xa0\x88\x53\xff\x9d\x86\x52\xff\x83\x6e\x43\xed\x00\x00\x00\xaa\x00\x00\x00\x9e\x00\x00\x00\x94\x00\x00\x00\x8c\x00\x00\x00\x85\x00\x00\x00\x7f\x00\x00\x00\x7a\x00\x00\x00\x77\x00\x00\x00\x74\x7b\x6c\x49\xc4\xc6\xb0\x79\xff\xd6\xc5\x8c\xff\xd4\xc6\x8f\xff\xaf\xa1\x72\xcf\x00\x00\x00\x5a\x00\x00\x00\x51\x00\x00\x00\x48\x00\x00\x00\x40\x00\x00\x00\x37\x00\x00\x00\x2e\x00\x00\x00\x25\x00\x00\x00\x1c\x00\x00\x00\x15\x00\x00\x00\x0f\x00\x00\x00\x09\x00\x00\x00\x06\x00\x00\x00\x04\x00\x00\x00\x03") then
            readbuff(buffs.roarofosseous, true)
          end
        elseif aw == 128 then
          if event:texturecompare(ax, ay + 64, "\x01\x01\x01\xff\x01\x01\x01\xff\x01\x01\x01\xff\x05\x06\x08\xff\x2c\x2f\x34\xff\x40\x43\x47\xff\x01\x01\x01\xff\x0a\x0b\x0b\xff\x01\x01\x01\xff\x01\x01\x01\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x05\x0e\x10\xff\x0b\x11\x13\xff\x1b\x14\x13\xff\x12\x14\x16\xff\x1b\x14\x13\xff\x09\x19\x1c\xff\x26\x1d\x1a\xff\x52\x34\x17\xff\x5e\x33\x1e\xff\x6f\x4e\x1c\xff\x87\x5d\x19\xff\x7f\x50\x1e\xff\x7f\x3e\x18\xff\x8f\x33\x19\xff\xbb\x2b\x12\xff\xce\x2c\x11\xff\xb3\x37\x18\xff\x6f\x3f\x1a\xff\x0c\x1e\x21\xff\x32\x20\x1c\xff\x7f\x3e\x18\xff\xbe\x48\x19\xff\xbb\x36\x16\xff\xab\x38\x1b\xff\xa0\x3d\x19\xff\xbe\x62\x21\xff\xbe\x62\x21\xff\xd0\x5f\x24\xff\xdc\x64\x22\xff\xdc\x65\x2b\xff\xdf\x86\x36\xff\xe4\x95\x47\xff\xe6\x98\x59\xff\xe4\x97\x71\xff\xe4\x97\x71\xff\xe8\x9f\x7d\xff\xe8\x9f\x7d\xff\xef\xb9\x95\xff\xf4\xcc\xa5\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf6\xdc\xb6\xff\xf4\xcc\xa5\xff\xef\xb9\x95\xff\xe8\x9f\x7d\xff\xe1\xb0\x81\xff\xe1\xb0\x81\xff\xdf\xa5\x60\xff\xef\xb7\x60\xff\xef\xb7\x60\xff\xe9\xa6\x51\xff\xdf\xa5\x60\xff\xdf\xa5\x60\xff\xe6\x98\x59\xff\xe3\x84\x46\xff\xe4\x95\x47\xff\xc8\x82\x47\xff\xc8\x82\x47\xff\xd5\x4a\x25\xff\xd2\x3b\x19\xff\xd2\x3b\x19\xff\xd2\x3b\x19\xff\xc4\x38\x13\xff\x5e\x33\x1e\xff\x27\x2a\x2c\xff\x27\x2a\x2c\xff\x2c\x2f\x34\xff\x48\x37\x24\xff\x93\x28\x15\xff\xaf\x2b\x14\xff\xaf\x2b\x14\xff\x8b\x28\x15\xff\x6e\x2d\x1c\xff\x58\x26\x1c\xff\x93\x28\x15\xff\x9b\x28\x14\xff\x7e\x24\x14\xff\x7e\x24\x14\xff\x5e\x33\x1e\xff\x48\x36\x1b\xff\x5e\x37\x14\xff\x26\x1d\x1a\xff\x06\x12\x14\xff\x06\x12\x14\xff\x06\x12\x14\xff\x05\x0e\x10\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x03\x0a\x0a\xff\x01\x01\x01\xff\x01\x01\x01\xff\x0a\x0b\x0b\xff\x01\x01\x01\xff\x40\x43\x47\xff\x2c\x2f\x34\xff\x05\x06\x08\xff\x01\x01\x01\xff\x01\x01\x01\xff\x01\x01\x01\xff") then
            readbuff(buffs.bonfire, true)
          elseif event:texturecompare(ax, ay + 64, "\x1c\x16\x37\xff\x1f\x17\x3c\xff\x22\x18\x44\xff\x28\x1a\x4e\xff\x2e\x1e\x5a\xff\x37\x22\x69\xff\x40\x26\x7a\xff\x41\x26\x7f\xff\x1b\x0a\x36\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x17\x06\x2e\xff\x18\x07\x30\xff\x8b\x44\xc8\xff\xb1\x58\xfa\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x56\xf2\xff\xab\x55\xf2\xff\xb3\x59\xfc\xff\x53\x26\x7d\xff\x0e\x02\x22\xff\x18\x06\x30\xff\x18\x0b\x2e\xff\x17\x14\x28\xff\x17\x14\x28\xff\x19\x15\x2a\xff\x17\x0f\x2a\xff\x11\x07\x26\xff\x0b\x09\x1e\xff\x0c\x09\x1e\xff\x0f\x09\x23\xff\x17\x07\x30\xff\x15\x07\x2b\xff\x19\x06\x43\xff\x37\x02\xc1\xff\x3b\x03\xf4\xff\x34\x03\xf9\xff\x34\x03\xf7\xff\x34\x03\xf9\xff\x34\x03\xec\xff\x33\x04\xda\xff\x36\x03\xe4\xff\x28\x04\x8b\xff\x14\x07\x28\xff\x18\x07\x30\xff\x17\x07\x31\xff\x0e\x09\x22\xff\x0d\x09\x1f\xff\x0c\x09\x1f\xff\x0c\x09\x1f\xff\x0c\x09\x1f\xff\x0c\x09\x1f\xff\x0c\x09\x1f\xff\x0c\x09\x1f\xff\x0d\x09\x1f\xff\x0e\x09\x22\xff\x17\x07\x31\xff\x18\x07\x30\xff\x14\x07\x28\xff\x28\x04\x8b\xff\x36\x03\xe4\xff\x33\x04\xda\xff\x34\x03\xec\xff\x34\x03\xf9\xff\x34\x03\xf7\xff\x34\x03\xf9\xff\x3b\x03\xf4\xff\x37\x02\xc1\xff\x19\x06\x43\xff\x15\x07\x2b\xff\x17\x07\x30\xff\x0f\x09\x23\xff\x0b\x09\x1e\xff\x0c\x09\x1e\xff\x11\x07\x26\xff\x1b\x13\x2e\xff\x21\x1e\x33\xff\x1a\x18\x2b\xff\x1a\x18\x2a\xff\x19\x0c\x2e\xff\x18\x06\x30\xff\x0f\x02\x23\xff\x53\x26\x7e\xff\xb3\x59\xfc\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x56\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x55\xf2\xff\xab\x56\xf2\xff\xb1\x58\xfa\xff\x8b\x45\xc8\xff\x18\x07\x30\xff\x17\x06\x2e\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x18\x07\x30\xff\x1b\x09\x37\xff\x45\x27\x87\xff\x42\x27\x84\xff\x3a\x23\x74\xff\x33\x1f\x66\xff\x2c\x1b\x5b\xff\x27\x19\x52\xff\x23\x17\x4a\xff\x20\x16\x44\xff") then
            readbuff(buffs.darkness, true)
          end
        end
      elseif aw == 10 and ah == 11 then
        local p = popupmessageimages[event:texturedata(ax, ay + 6, aw * 4)]
        if p then
          local message = modules.popup:tryreadpopup(event, i + verticesperimage)
          if message then
            popupfound = true
            if message ~= lastpopupmessage then
              lastpopupmessage = message
              for _, rule in ipairs(rules) do
                if rule.type == "popup" and string.find(message, rule.find) then
                  alertbyrule(rule)
                end
              end
            end
          end
        end
      elseif aw == 106 and ah == 4 then
        local bar = statbars[event:texturedata(ax, ay, 106 * 4)]
        if bar then
          local x2, _ = event:vertexxy(i)
          local x1, _ = event:vertexxy(i + 2)
          bar.fraction = (x2 - (x1 + 1)) / 82.0
        end
      elseif aw == 6 and ah == 19 and vertexcount >= (i + verticesperimage) and event:texturecompare(ax, ay + 10, "\x11\x1e\x0d\xff\x22\x3c\x1a\xff\x33\x4b\x26\xff\x3b\x5d\x2d\xff\x3b\x5d\x2d\xff\x3b\x5d\x2d\xff") then
        local ax2, ay2, aw2, ah2, _, _ = event:vertexatlasdetails(i + verticesperimage)
        if aw2 == aw and ah2 == ah and event:texturecompare(ax2, ay2 + 10, "\x4d\x72\x3a\xff\x5b\x81\x43\xff\x5b\x81\x43\xff\x59\x7c\x41\xff\x20\x35\x18\xff\x1d\x19\x13\xff") then
          local x1 = event:vertexxy(i + 2)
          local x2 = event:vertexxy(i + verticesperimage)
          craftingprogress = (x2 - x1) / 304.0
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
        didgainxp = true
      end
    end
  end
end)

bolt.onrender3d(function (event)
  if not (checkframe or any3dobjectexists) then return end
  local f = render3dlookup[event:vertexcount()]
  if f ~= nil then
    local model = f(event)
    if model and model.dohighlight then
      any3dobjectfound = true
      if (bolt.time() % 600000) <= 480000 then
        local m = model.center
        if model.anim then
          m = m:transform(event:vertexanimation(1))
        end
        drawbox(m:transform(event:modelmatrix()), event:viewmatrix(), event:projectionmatrix(), model.boxsize, model.boxthickness)
      end
      if checkframe then
        model.foundoncheckframe = true
        for _, rule in ipairs(rules) do
          if rule.type == "model" and rule.ref == model then
            alertbyrule(rule)
          end
        end
      end
    end
  end
end)

bolt.onrenderbillboard(function (event)
  if not (checkframe or anybillboardexists) then return end
  local f = renderbillboardlookup[event:vertexcount()]
  if f ~= nil then
    local model = f(event)
    if model and model.dohighlight then
      anybillboardfound = true
      if (bolt.time() % 600000) <= 480000 then
        local m = model.center
        drawbox(m:transform(event:modelmatrix()), event:viewmatrix(), event:projectionmatrix(), model.boxsize, model.boxthickness)
      end
      if checkframe then
        model.foundoncheckframe = true
        for _, rule in ipairs(rules) do
          if rule.type == "model" and rule.ref == model then
            alertbyrule(rule)
          end
        end
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

local startcheckframe = function (t)
  for _, buff in pairs(buffs) do
    buff.foundoncheckframe = false
  end

  for _, model in pairs(models) do
    model.foundoncheckframe = false
  end

  for _, rule in ipairs(rules) do
    if rule.type == "chat" then
      -- enable chat-reading for this frame only if we have any rules that require it,
      -- because reading chat is computationally expensive (can take upwards of 0.4 millis on my pc)
      -- and we don't want to spend that twice-per-second for no reason
      checkchat = true
    elseif rule.type == "afktimer" then
      if t - lastnonafkaction >= rule.threshold then
        alertbyrule(rule)
      else
        setrulealertstate(rule, false)
      end
    end
  end
end

local endcheckframe = function (t)
  for _, buff in pairs(buffs) do
    if not buff.foundoncheckframe then
      buff.active = false
    end
  end
  if not popupfound then
    lastpopupmessage = nil
  end

  for _, ruleset in ipairs(rulesets) do
    ruleset.alert = false
  end

  for _, rule in ipairs(rules) do
    if rule.type == "buff" then
      local buff = rule.ref
      if rule:comparator(buff) then
        alertbyrule(rule)
      else
        setrulealertstate(rule, false)
      end
    elseif rule.type == "stat" then
      local stat = rule.ref
      if stat.fraction < rule.threshold then
        alertbyrule(rule)
      else
        setrulealertstate(rule, false)
      end
    elseif rule.type == "xpgain" then
      if rule.threshold then
        if t - lastxpgaintime > rule.threshold then
          alertbyrule(rule)
        else
          setrulealertstate(rule, false)
        end
      elseif didgainxp then
        alertbyrule(rule)
      end
    elseif rule.type == "model" then
      if not rule.ref.foundoncheckframe then
        setrulealertstate(rule, false)
      end
    elseif rule.type == "craftingprogress" then
      if craftingprogress == nil or craftingprogress >= rule.threshold then
        alertbyrule(rule)
      else
        setrulealertstate(rule, false)
      end
    end

    if rule.alert then
      rule.ruleset.alert = true
    end
  end

  didgainxp = false
  popupfound = false
  craftingprogress = nil
end

local lastknownposx = 0
local lastknownposy = 0
local lastknownposz = 0

bolt.onswapbuffers(function (event)
  any3dobjectexists = any3dobjectfound
  any3dobjectfound = false

  anybillboardexists = anybillboardfound
  anybillboardfound = false

  nextrender2dbuff = nil
  nextrender2ddebuff = nil

  local worldpoint = bolt.playerposition()
  if worldpoint then
    local x, y, z = worldpoint:get()
    local xmod = math.floor(x / unitspertile)
    local ymod = math.floor(y)
    local zmod = math.floor(z / unitspertile)
    if (forceupdatecoords or xmod ~= lastknownposx or ymod ~= lastknownposy or zmod ~= lastknownposz) and x > 1 and z > 1 then
      forceupdatecoords = false
      lastknownposx = xmod
      lastknownposy = ymod
      lastknownposz = zmod
      updatecoordsinbrowser(xmod, ymod, zmod)
      
      for _, rule in ipairs(rules) do
        if rule.type == "position" then
          local insideheight = true
          if rule.regionh1 ~= nil and rule.regionh2 ~= nil then
            insideheight = ymod >= rule.regionh1 and ymod <= rule.regionh2
          end
          local inside = xmod >= rule.regionx1 and xmod <= rule.regionx2 and zmod >= rule.regiony1 and zmod <= rule.regiony2 and insideheight
          if (inside and rule.regionisinside) or (not inside and not rule.regionisinside) then
            alertbyrule(rule)
          else
            setrulealertstate(rule, false)
          end
        end
      end
    end
  end

  local t = bolt.time()
  if checkframe then
    endcheckframe(t)
    checkframe = false
  end

  if t > checktime + checkinterval then
    checkframe = true
    checktime = checktime + checkinterval
    if checktime < t then
      checktime = t
    end
    startcheckframe(t)
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
