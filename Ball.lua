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
BALL_ACCEL = 1.15 -- 1.03
BALL_MAX_FACTOR = 8

--[[
    Ball:init

    screen_width, screen_height: Size of screen in pixels
    left_edge, right_edge: Where the paddles are, in pixels
]]
function Ball:init(screen_width, screen_height, left_edge, right_edge)
    -- ball starts in center of screen
    self.start_x = screen_width / 2 - BALL_WIDTH / 2
    self.start_y = screen_height / 2 - BALL_HEIGHT / 2

    -- remember these - needed below
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
    Ball:reset: Places the ball in the middle of the screen, with no movement
]]
function Ball:reset()
    self.x = self.start_x
    self.y = self.start_y
    self.dx = 0
    self.dy = 0
end


--[[
    Ball:collides: Expects a paddle as an argument and returns true or false,
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
    Ball:bounce: Reverses direction of a ball, called when it collides with a
    paddle
]]
function Ball:bounce(new_x)
    ball.dx = math.min(-ball.dx * BALL_ACCEL, ball.max_speed)
    ball.x = new_x
    
    -- keep velocity going in the same direction, but randomize it
    if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
    else
        ball.dy = math.random(10, 150)
    end
end

--[[
    Ball:deflect: Called when the ball has hit either the top or the bottom of
    the screen, and it needs to deflect
]]
function Ball:deflect(new_y)
    ball.y = new_y
    ball.dy = -ball.dy
end

--[[
    Ball:update: Called each frame to update position of the ball

    dt:     Delta time, in seconds, since last update
]]
function Ball:update(dt)
    last_x = self.x 
    last_y = self.y 
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- TODO: Bug here -- self.y could be off screen

    -- when the ball is moving really fast, check to see if it passes a paddle
    -- boundary and "clip" it if it does
    -- TODO: these hard coded values need to go
    if last_x > self.left_edge and self.x < self.left_edge then
        self.x = self.left_edge
    elseif last_x < self.right_edge and self.x > self.right_edge then
        self.x = self.right_edge
    end
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end