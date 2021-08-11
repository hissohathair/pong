--[[
    GD50 2018
    Pong Remake

    -- Ball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a ball which will bounce back and forth between paddles
    and walls until it passes a left or right boundary of the screen,
    scoring a point for the opponent.
]]

Ball = Class{}

-- ball settings
BALL_WIDTH = 4
BALL_HEIGHT = 4
BALL_ACCEL = 1.07 -- 1.03

-- max speed of a ball, in pixels per second, will be the screen's width
-- multiplied by this factor. Therefore the default value of 4 should mean
-- a ball can traverse the horizontal in 1/4 of a second
BALL_MAX_FACTOR = 3

-- There are 8 preset dy values based on what part of the paddle the
-- ball hits. Values are what multiple of dx should be applied to calculate dy.
-- Note that Lua customarily starts arrays at index "1"
BOUNCE_ANGLES = {1.0, 0.40, 0.15, 0.03, -0.03, -0.15, -0.40, -1.0}

--[[
    Ball:init

    screen_width, screen_height: Size of screen in pixels
    left_edge, right_edge: Where the paddles are, in pixels
]]
function Ball:init(screen_width, screen_height, paddle_width, left_edge, right_edge)
    -- ball starts in center of screen
    self.start_x = screen_width / 2 - BALL_WIDTH / 2
    self.start_y = screen_height / 2 - BALL_HEIGHT / 2

    -- remember these - needed below
    self.paddle_width = paddle_width
    self.left_edge = left_edge
    self.right_edge = right_edge
    self.screen_width = screen_width
    self.screen_height = screen_height

    -- ball class controls these
    self.width = BALL_WIDTH
    self.height = BALL_HEIGHT
    self.max_speed = screen_width * BALL_MAX_FACTOR

    -- We also have x, y, and dx, dy (for movement). They are initialised
    -- by reset()
    self:reset()
end

--[[
    Ball:reset - Places the ball in the middle of the screen, with no movement
]]
function Ball:reset()
    self.x = self.start_x
    self.y = self.start_y
    self.dx = 0
    self.dy = 0
end

--[[
    Ball:speed - Report speed in pixels per second across x and y
]]
function Ball:speed()
    s = math.sqrt(self.dx ^ 2 + self.dy ^ 2)
    return s
end


--[[
    Ball:collides - Expects a paddle as an argument and returns true or false,
    depending on whether their rectangles overlap.
]]
function Ball:collides(paddle)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Ball:bounce - Reverses direction of a ball, called when it collides with a
    paddle

    new_x: Snap ball to new x coordinate
    paddle: The Paddle instance that the ball hit
]]
function Ball:bounce(new_x, paddle)
    -- snap to position
    self.x = new_x

    -- easy enough to reverse the x direction
    self.dx = math.min(-self.dx * BALL_ACCEL, self.max_speed)

    -- the y direction is a function of where the ball hit the paddle. We're
    -- going to use the same "8 segments" approach as the original. There's a
    -- flaw in my math that means we occassionally get segment "9" which is
    -- out of bounds so as a quick fix we lock in a max value of 8
    segment = math.min(math.floor((paddle.y + paddle.height - ball.y) / paddle.height * 7 + 1.5), 8)
    self.dy = BOUNCE_ANGLES[segment] * math.abs(self.dx)
end

--[[
    Ball:deflect - Called when the ball has hit either the top or the bottom of
    the screen, and it needs to deflect
]]
function Ball:deflect(new_y)
    ball.y = new_y
    ball.dy = -ball.dy
end

--[[
    Ball:serve - Called when ball is being "served"

    servingPlayer: Player who is serving (1 or 2)
]]
function Ball:serve(servingPlayer)
    -- vertical direction randomised
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
        ball.dx = math.random(140, 200)
    else
        ball.dx = -math.random(140, 200)
    end
end

--[[
    Ball:update - Called each frame to update position of the ball

    dt:     Delta time, in seconds, since last update
]]
function Ball:update(dt)
    last_x = self.x 
    last_y = self.y
    dx = self.dx * dt
    dy = self.dy * dt

    -- when the ball is moving really fast, check to see if it passes a paddle
    -- boundary and "clip" it if it does
    --
    if dx < 0 and last_x > self.left_edge + self.paddle_width and self.x + dx + self.width < self.left_edge then
        -- ball moving left (dx<0), and went from out in front of paddle to behind 
        -- in one step. Shrink that back to be on the paddle
        new_dx = self.left_edge - self.x
        dy = dy * (new_dx / dx)
        dx = new_dx
        --[[print(string.format("DEBUG: Left snapping ball(%d, %d) to (%d, %d) delta=(%f, %f) @ %f", 
            last_x, last_y, self.x + dx, self.y + dy, dx, dy, dt))
        ]]

    elseif dx > 0 and last_x + self.width < self.right_edge and self.x + dx > self.right_edge + self.paddle_width then
        -- ball moving right (dx>0), and moved from in front of paddle to
        -- behind in one step
        new_dx = self.right_edge - self.x
        dy = dy * (new_dx / dx)
        dx = new_dx
        --[[print(string.format("DEBUG: Right snapping ball(%d, %d) to (%d, %d) delta=(%f, %f) @ %f", 
            last_x, last_y, self.x + dx, self.y + dy, dx, dy, dt)) 
        ]]
    end


    self.x = self.x + dx
    self.y = self.y + dy

end

--[[
    Ball:render - Called each frame to draw ball
]]
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end