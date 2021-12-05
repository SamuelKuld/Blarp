local dir = (...):gsub('%.[^%.]+$', '')
local files = {}
files.menu = require(dir .. ".menu")
files.noises = require(dir .. ".noises")
files.screen = require(dir .. ".screen")
files.blobs = require(dir .. "/loveblobs")
-- files.game_obj = require(dir .. ".game_obj")
return files