--------------
-- ## init
--------------

mp_utils = require 'mp.utils'

BMARK_FNAME = "bookmarks.json" 

BMARKS = {}
PLACEHOLDER = {
  { id = 1, path = "placeholder", pos = 1.100000, name = "placeholder"},
  { id = 2, path = "placeholder2", pos = 1.100000, name = "placeholder2"}
}


----------
-- ## fxs
----------

---clean fpath
---@param path string
---@return string
function parse_path(path)
  if type(path) == "string" then path, _ = path:gsub("\\", "/") end
  return path
end

---convert a pos (seconds) to hh:mm:ss.mmm format
---@param pos number
---@return string
function parse_time(pos)
  local hrs = math.floor(pos/3600)
  local mins = math.floor((pos % 3600)/60)
  local secs = math.floor((pos % 60))
  local ms = math.floor(pos % 1 * 1000)
  return string.format("%02d:%02d:%02d.%03d", hrs, mins, secs, ms)
end

---get the filepath of a file in the mpv config directory
---@param filename string
---@return string
function get_json_path(filename)
  return os.getenv("APPDATA"):gsub("\\", "/") .. "/mpv/" .. filename
end

---check whether a file exists
---@param path string
---@return boolean
function exists(path)
  local f = io.open(path,"r")
  if f~=nil then
    io.close(f)
    return true
  else
    return false
  end
end

---save tbl as json
---@param tbl table
---@param path string
function save_tbl(tbl, path)
  local contents = mp_utils.format_json(tbl)
  local file = io.open(path .. ".tmp", "wb")
  file:write(contents)
  io.close(file)
  os.remove(path)
  os.rename(path .. ".tmp", path)
end

---load table from json file
---@param path string
---@return table
function load_tbl(path)
  local t_tbl = {}
  local file = io.open(path, "r" )
  if file then
    local contents = file:read( "*a" )
    t_tbl = mp_utils.parse_json(contents);
    io.close(file)
    return t_tbl
  end
  return t_tbl
end

---create bookmark json file if it doesn't already exist then loads into global `BMARKS` var
function init_bmarks()
  bmark_file_exists = exists(get_json_path(BMARK_FNAME))
  if not bmark_file_exists then
    save_tbl(PLACEHOLDER, get_json_path(BMARK_FNAME))
  end
  BMARKS = load_tbl(get_json_path(BMARK_FNAME))
end

---create bookmark
---@return table --> table[id: int, path: str, pos: float, name: str] // empty table if path is nil
function make_bmark()
  local t_path = mp.get_property("path")
  if t_path == nil then
    return {}
  else
    local t_id = #BMARKS + 1
    local t_pos = mp.get_property_number("time-pos")
    local bookmark = {
      id = t_id,
      path = parse_path(t_path),
      pos = t_pos,
      name = tostring(t_id) .. " @ " .. parse_time(t_pos)
    }
    return bookmark
  end
end

---add bookmark to global BMARKS table and save to json
function quick_save()
  init_bmarks()
  local bmark = make_bmark()
  if bmark['id'] == nil then
    mp.osd_message("Open a file first")
  else
    table.insert(BMARKS, bmark)
    save_tbl(BMARKS, get_json_path(BMARK_FNAME))
    mp.osd_message("Saved new bookmark at slot " .. #BMARKS)
  end
end

---find latest bookmark id for current file
---@return table --> [bool, int]
function find_rel_id()
  local t_id = 1
  local path_match = false

  assert(mp.get_property("path") ~= nil, "open a file first")
  local t_path = parse_path(mp.get_property("path"))

  for _, tbl in ipairs(BMARKS) do
      if tbl.path == t_path then
          t_id = tbl.id
          path_match = true
      end
  end
  return {path_match, t_id}
end

---load
function quick_load()
  init_bmarks()
  local path_match, id = table.unpack(find_rel_id())
  if path_match then 
    mp.set_property_number("time-pos", BMARKS[id].pos)
  else
    mp.osd_message("No bookmarks found for this file")
  end
end


--------------------
-- ## shortcuts
--------------------

mp.register_script_message("bookmarker-quick-load", quick_load)
mp.register_script_message("bookmarker-quick-save", quick_save)