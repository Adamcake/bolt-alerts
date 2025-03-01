-- takes each cmomand line arg, opens it as a file, and generates a .tar file with all of them in.
-- prints the .tar contents to stdout.

--  luarocks install dumbluaparser
local p = require('dumbParser')

-- luarocks install lua-zstd
local zstd = require('zstd').CCtx()

-- first arg is the absolute path to the repo, which is the path we want to be relative to when
-- defining paths of files in the archive
local basedir = arg[1]
local basedirpattern = '^' .. basedir:gsub('[%(%)%[%.%%%+%-%*%?%^%$]', function (c) return '%' .. c end)

-- current unix timestamp in seconds, which will be associated with every file in the archive
local timestamp = os.time(os.date("!*t"))
local timestampoctal = string.format("%011o", timestamp)

-- the header contains a checksum of the header... fortunately, all the stuff we want to write
-- in the header after the checksum is zeroes, so it's always the same and doesn't affect the checksum.
local headerafterchecksum = string.rep('\0', 356)

-- rest of the args are absolute file paths to files that need to be archived
for i = 2, #arg do
  local filename = arg[i]
  if not filename:find(basedirpattern) then goto continue end

  -- file contents that will go in the archive
  local content
  if filename:match("%.lua$") then
    local ast = p.parse(p.tokenizeFile(filename))
    p.minify(ast, true)
    content = p.toLua(ast)
  else
    local f = io.open(filename, 'rb')
    io.input(f)
    content = io.read('*a')
    f:close()
  end
  local contentlength = #content
  local paddedcontentlength = (contentlength + 511) & ~511
  
  -- trim filename to be relative to the root of the archive we're making
  -- note: we already checked at the start of the loop to make sure filename begins with basedir
  filename = filename:sub(#basedir + 1)
  
  local headerbeforechecksum = string.format("%s%s0000644\x000000000\x000000000\x00%011o\x00%s\x00", filename, string.rep('\0', 100 - #filename), contentlength, timestampoctal)
  local checksum = 256 -- sum of eight ASCII spaces
  for j = 1, #headerbeforechecksum do
    checksum = checksum + string.byte(headerbeforechecksum:sub(j, j))
  end
  local checksumstr = string.format("%06o\x00 ", checksum)
  
  -- compress all the tar contents for this file
  io.write(zstd:compressStream(headerbeforechecksum, 'continue'))
  io.write(zstd:compressStream(checksumstr, 'continue'))
  io.write(zstd:compressStream(headerafterchecksum, 'continue'))
  io.write(zstd:compressStream(content, 'continue'))
  io.write(zstd:compressStream(string.rep('\0', paddedcontentlength - contentlength), 'continue'))

  ::continue::
end

io.write(zstd:compressStream('', 'end'))
