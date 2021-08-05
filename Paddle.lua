--[[
    GD50 2018
    Pong Remake

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
]]

Paddle = Class{}

--[[
    The `init` function on our class is called just once, when the object
    is first created. Used to set up all variables in the class and get it
    ready for use.

    Our Paddle should take an X and a Y, for positioning, as well as a width
    and height for its dimensions.

    Note that `self` is a reference to *this* object, whichever object is
    instantiated at the time this function is called. Different objects can
    have their own x, y, width, and height values, thus serving as containers
    for data. In this sense, they're very similar to structs in C.
]]
function Paddle:init(x, y, width, height, playerNum)
    self.x = x
    self.y = y
    self.orig_x = x 
    self.orig_y = y 
    self.width = width
    self.height = height
    self.orig_width = width
    self.orig_height = height 
    self.dy = 0
    self.playerNum = playerNum
    self.hitCount = 0  -- how many times have we hit the ball?
    self.ballIncoming = false  -- is ball heading towards us?
    self.strategy = 'normal'
end

function Paddle:reset(resetPosition)
    if resetPosition then
        self.x = self.orig_x
        self.y = self.orig_y
    end
    self.width = self.orig_width
    self.height = self.orig_height
    self.dy = 0
    self.hitCount = 0
    self.ballIncoming = false
    self.strategy = 'normal'
end

function Paddle:update(dt)
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- height (or else it will go partially below, since position is
    -- based on its top left corner)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--[[
    To be called by our main function in `love.draw`, ideally. Uses
    LÖVE2D's `rectangle` function, which takes in a draw mode as the first
    argument as well as the position and dimensions for the rectangle. To
    change the color, one must call `love.graphics.setColor`. As of the
    newest version of LÖVE2D, you can even draw rounded rectangles!
]]
function Paddle:render()
    -- go red if we're cheating, white otherwise
    r, g, b, a = love.graphics.getColor()
    if self.strategy == 'normal' then
        love.graphics.setColor(1, 1, 1, 1)
    else
        love.graphics.setColor(1, 0, 0, 1)
    end
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(r, g, b, a)
end

--[[
    Called to allow the human player to move the paddle. Pass in the key
    for `up` and `down` paddle based on which player (1 or 2) is moving
]]
function Paddle:humanmove(upkey, downkey, paddle_speed)
    if love.keyboard.isDown(upkey) then
        self.dy = -paddle_speed
    elseif love.keyboard.isDown(downkey) then
        self.dy = paddle_speed
    else
        self.dy = 0
    end
end

--[[
    Called when the computer is controlling the paddle. For now, we pass in
    the paddle_speed (same as for humans) and the ball's current position.
]]
function Paddle:automove(paddle_speed, ball, dt)
    -- simple method: track the ball, try and hit in the middle of the paddle
    -- For a bit of added "realism", we'll only move when the ball is heading 
    -- our way
    if (self.playerNum == 1 and ball.dx < 0) or (self.playerNum == 2 and ball.dx > 0) then
        -- ball is heading towards us, is that a change in direction?
        directionChanged = (self.ballIncoming == false)
        self.ballIncoming = true

        -- When direction has changed, pick the automove strategy
        -- Every third hit, take a 50% chance on chosing a "cheat" strategy
        if directionChanged and (self.hitCount % 3 == 2) and (math.random(1, 2) == 1) then
            self.strategy = 'cheat' .. math.random(1, 3)
            print(string.format("Player %d decided to %s on hit %d", self.playerNum, self.strategy, self.hitCount))
        elseif directionChanged then
            self.strategy = 'normal'
        end


        if self.strategy == 'normal' then
            -- normal strategy: track the ball height
            if ball.y < self.y + ball.height then
                self.dy = -paddle_speed
            elseif ball.y > self.y + self.height - ball.height then
                self.dy = paddle_speed
            else
                self.dy = 0
            end

        elseif self.strategy == 'cheat1' then
            -- cheat strategy: make the ball too big to miss
            ball.width = ball.width + 1
            ball.height = ball.height + 1
            ball.x = ball.x - 1
            ball.y = ball.y - 1

            -- Also, move the paddle without regards to speed
            ball_centre = ball.y + (ball.height / 2)
            paddle_centre = self.y + (self.height / 2)
            self.y = self.y + (ball_centre - paddle_centre)

        elseif self.strategy == 'cheat2' then
            -- cheat strategy: ignore the ball. Rapidly grow the paddle instead
            if self.y > 1 then
                self.dy = -paddle_speed * 2
            else
                self.dy = 0
            end
            if self.height < VIRTUAL_HEIGHT then
                self.height = self.height + (paddle_speed * dt * 2)
            end

        elseif self.strategy == 'cheat3' then
            -- cheat strategy: move perfectly and without regard to paddle_speed
            self.y = ball.y - (self.height / 2)

        else
            -- whoops -- uncoded cheat, reset to normal
            self.strategy = 'normal'
        end

    else
        self.dy = 0
        self.ballIncoming = false

        -- if our last strategy was to cheat, undo the damage
        if self.strategy == 'cheat1' then
            -- shrinl the ball to regular size again
            ball.width = math.max(ball.orig_width, ball.width - 2)
            ball.height = math.max(ball.orig_height, ball.height - 2)
            if ball.width == ball.orig_width and ball.height == ball.orig_height then
                self.strategy = 'normal'
            end
        elseif self.strategy == 'cheat2' then
            -- shrink the paddle to regular size, and track the ball a little
            self.height = math.max(self.orig_height, self.height - (paddle_speed * dt * 2))
            if ball.y > self.y + self.orig_height then
                self.dy = paddle_speed
            elseif ball.y < self.y then
                self.dy = -paddle_speed
            end
            if self.height == self.orig_height then
                self.strategy = 'normal'
            end

        elseif self.strategy == 'cheat3' then
            -- nothing to do really, just end the cheat mode
            self.strategy = 'normal'

        else
            -- in normal mode, head to the centre-ish, but only if ball that way
            if self.y < VIRTUAL_HEIGHT * 0.3 and ball.y > self.y + self.height then
                self.dy = paddle_speed
            elseif self.y > VIRTUAL_HEIGHT * 0.6 and ball.y < self.y then
                self.dy = -paddle_speed
            end
        end
    end
end

