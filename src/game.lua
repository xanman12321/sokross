local Game = {}

function Game:enter()
  print("Sokoma game")

  Undo:clear()

  self.turn = 0
  self.sound = {}
  self.parse_room = {}

  Level.static = false
  Level:reset()
  
  Level.room:parse()
  Level.room:updateTiles()
  self.sound = {}

  --print(dump(Level.room.rules.rules))
end

function Game:keypressed(key)
  if key == "d" then
    self:doTurn(1)
  elseif key == "s" then
    self:doTurn(2)
  elseif key == "a" then
    self:doTurn(3)
  elseif key == "w" then
    self:doTurn(4)
  elseif key == "z" then
    Undo:back()
    self:reparse()
  elseif key == "r" then
    Level:reset()
  elseif key == "return" then
    Gamestate.switch(Editor)
  end
end

function Game:doTurn(dir)
  Undo:new()
  self.turn = self.turn + 1
  Movement.move(dir)
  self:reparse()
  Level.room:updateTiles()
  self:checkWin()
  self:playSounds()
end

function Game:playSounds()
  if self.sound["enter"] then
    Assets.playSound("enter")
  elseif self.sound["exit"] then
    Assets.playSound("exit")
  elseif self.sound["push"] then
    if self.sound["click"] or self.sound["unclick"] then
      Assets.playSound("push", 0.75)
    else
      Assets.playSound("push")
    end
  end
  if self.sound["click"] then
    Assets.playSound("click", 0.75)
  elseif self.sound["unclick"] then
    Assets.playSound("unclick", 0.75)
  end
  self.sound = {}
end

function Game:reparse()
  local parse_list = {}
  for room,_ in pairs(self.parse_room) do
    table.insert(parse_list, room)
  end
  table.sort(parse_list, function(a, b)
    return a:getLayer() < b:getLayer()
  end)
  for _,room in ipairs(parse_list) do
    room:parse()
    for _,lower in ipairs(room.tiles_by_name["room"] or {}) do
      if lower.room and not parse_list[lower.room] then
        lower.room:parse()
      end
    end
  end
  self.parse_room = {}
end

function Game:checkWin()
  for _,tile in ipairs(Level.room:getTilesByName("tile")) do
    if not tile:getActivated() then return end
  end
  Level.room:win()
end

function Game:getTransform()
  local transform = love.math.newTransform()
  transform:translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  transform:scale(2, 2)
  transform:translate(-Level.room.width*TILE_SIZE/2, -Level.room.height*TILE_SIZE/2)
  return transform
end

function Game:draw()
  Assets.palettes[Level.room.palette]:setColor(0, 1)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

  love.graphics.applyTransform(self:getTransform())

  Level.room:draw()
end

return Game