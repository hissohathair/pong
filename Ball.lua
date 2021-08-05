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
BALL_MAX_SPEED = 8

function Ball:init(virtual_width, virtual_height)
    self.x = virtual_width / 2 - BALL_WIDTH / 2
    self.y = virtual_height / 2 - BALL_HEIGHT / 2
    self.start_x = x 
    self.start_y = y 
    self.width = BALL_WIDTH
    self.height = BALL_HEIGHT
    self.virtual_width = virtual_width
    self.virtual_height = virtual_height
    self.max_speed = virtual_width * BALL_MAX_SPEED

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = 0
    self.dx = 0
end

--[[
    Expects a paddle as an argument and returns true or false, depending
    on whether their rectangles overlap.
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
    Reverses direction of a ball, called when it has been hit by a paddle
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
    Called when the ball has hit either the top or the bottom of the screen,
    and it needs to deflect
]]
function Ball:deflect(new_y)
    ball.y = new_y
    ball.dy = -ball.dy
end

--[[
    Places the ball in the middle of the screen, with no movement.
]]
function Ball:reset()
    self.x = self.start_x
    self.y = self.start_y
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    -- todo: not sure last_x/y needs to be member variables
    self.last_x = self.x 
    self.last_y = self.y 
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- when the ball is moving really fast, check to see if it passes a paddle
    -- boundary and "clip" it if it does
    -- TODO: these hard coded values need to go
    if self.last_x > 10 and self.x < 10 then
        self.x = 10
    elseif self.last_x < self.virtual_width - 10 and self.x > self.virtual_width - 10 then
        self.x = self.virtual_width - 10
    end
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end