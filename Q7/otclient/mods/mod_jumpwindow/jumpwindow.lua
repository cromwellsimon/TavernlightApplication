-- I'm not terribly happy with my code here, I'd prefer refactoring this some more but oh well.
-- I think a lot of the issues that I was having were related to the lack of type-safety with Lua. I wasn't able to just look at classes and definitions very conveniently here so I had to jump around between VSCode, Visual Studio, and the GitHub page for both ForgottenServer and OTClient a lot. I would definitely want to add a ton of type annotations to the project to make Lua development a lot simpler but that would be way outside of the scope of this

jumpButton = nil

---@type string
jumpLabel = 'Jump!'

function init()
  -- Search for 'g_lua.callGlobalField("g_game",' in this file: https://github.com/edubart/otclient/blob/e6861d79c90d1808bde3fd41d30b6458d1616bfe/src/client/game.cpp to see all callbacks for the g_game
  connect(g_game, 'onPing', update)

  -- Not quite sure what getRightPanel does ('right' as in direction or 'right' as in correct?) but this is the general flow for how all of the other modules create their UI
  jumpWindow = g_ui.displayUI('jumpwindow', modules.game_interface.getRightPanel())
  jumpWindow:hide()

  -- https://github.com/edubart/otclient/blob/e6861d79c90d1808bde3fd41d30b6458d1616bfe/src/framework/ui/uiwidget.h is the base class for buttons.
  -- Judging by https://github.com/edubart/otclient/blob/e6861d79c90d1808bde3fd41d30b6458d1616bfe/modules/corelib/ui/uibutton.lua, uibutton's script doesn't seem to add a whole lot to uiwidget other than adding the actual mouse release functionality
  jumpButton = jumpWindow:getChildById('buttonJump')

  jumpWindowButton = modules.client_topmenu.addRightGameToggleButton('jumpwindowButton', 'Jump Window', '', toggle)
end

-- I mostly based this off of the game_spelllist module because it seemed to share the most similarities with what I was looking for. This function is identical in that minus the variable names
function toggle()
  if jumpWindowButton:isOn() then
    jumpWindowButton:setOn(false)
    jumpWindow:hide()
  else
    jumpWindowButton:setOn(true)
    jumpWindow:show()
    jumpWindow:raise()
    jumpWindow:focus()
  end
end

-- Again, standard procedure for the other modules it seems
function terminate()
  disconnect(g_game, 'onPing', update)
  jumpWindow:destroy()
end

-- This gets called for each ping. I wasn't able to find anything else called on the g_game which was a 'tick' or 'update'. There was 'onUpdateNeeded' but that worked differently from what I was originally looking for
function update()
  local speed = 100
  local leftBounds = jumpWindow:getX()
  local finalPosition = 0
  if jumpButton:getX() - speed < leftBounds then
    -- If the new position would be out-of-range, then just jump
    jump()
    return
  else
    -- Otherwise, set the new position
    finalPosition = jumpButton:getX() + (speed * -1)
  end
  jumpButton:setX(finalPosition)
end

-- For bounds checking. There may be a better way of doing this but I didn't see anything that immediately stuck out to me looking through UIWidget.h
---@return number
function getRightmostPosition(ui)
  return ui:getX() + ui:getWidth()
end

---@return number
function getLowermostPosition(ui)
  return ui:getY() + ui:getHeight()
end

function jump()
  local jumpRange = 300
  local jumpOffset = math.random(-jumpRange, jumpRange)
  local finalPosition = 0
  -- in this engine, positive Y indicates going down while negative Y indicates going up
  if jumpOffset < 0 then
    -- I'm not quite sure how large the border at the top is but I went with this
    local upperBuffer = 45
    local upperBounds = jumpWindow:getY() + upperBuffer
    finalPosition = math.max(upperBounds, jumpOffset + jumpButton:getY())
    -- Retry the jump if it's out-of-range
    if finalPosition == upperBounds then
      jump()
      return
    end
  else
    local lowerBuffer = 30
    local lowerBounds = getLowermostPosition(jumpWindow) - lowerBuffer
    finalPosition = math.min(lowerBounds, jumpOffset + jumpButton:getY())
    -- Retry the jump if it's out-of-range
    if finalPosition == lowerBounds then
      jump()
      return
    end
  end
  jumpButton:setY(finalPosition)

  local rightBuffer = 15 + jumpButton:getWidth()
  jumpButton:setX(getRightmostPosition(jumpWindow) - rightBuffer)
end