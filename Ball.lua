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

-- max speed of a ball, in pixels per second, will be the screen's width
-- multiplied by this factor. Therefore the default value of 4 should mean
-- a ball can traverse the horizontal in 1/4 of a second
BALL_MAX_FACTOR = 4

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
    Ball:reset - Places the ball in the middle of the screen, with no movement
]]
function Ball:reset()
    self.x = self.start_x
    self.y = self.start_y
    self.dx = 0
    self.dy = 0
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

    paddle: Instance of `Paddle` class, that we just collided with
]]
function Ball:bounce(paddle)
    -- snap to position. Which paddle did we hit?
    if self.x < self.screen_width / 2 then
        -- paddle1
        self.x = paddle.x + paddle.width
    else
        self.x = paddle.x - self.width
    end

    -- direction to head? 1 (right) or -1 (left)
    direction = 0
    if self.dx < 0 then
        direction = 1
    elseif self.dx > 0 then
        direction = -1
    end

    -- calculate current speed, and what the new speed should be
    current_speed = math.sqrt(math.pow(self.dx, 2) + math.pow(self.dy, 2))
    new_speed = math.min(current_speed * BALL_ACCEL, self.max_speed)

    -- where did we hit the paddle?
    --  0.0  -> centre of ball hit very top of paddle
    --  0.5  -> centre of ball hit middle of paddle
    --  1.0  -> centre of ball hit very bottom of paddle
    ball_centre = self.y + self.height / 2
    pad_pos = (paddle.y + paddle.height - ball_centre) / paddle.height

    -- what should bounce angle be?
    --  0.0  -> 45º
    --  0.25 -> 68º
    --  0.50 -> 90º
    --  0.75 -> 113º
    --  1.0  -> 135º
    -- but in radians: radians = degrees * (π / 180)
    deflection_angle = math.rad(45 + (90 * pad_pos))

    if true then
        -- so want to move at new_speed at deflection_angle away from the
        -- vertical paddle we hit
        ball.dx = math.cos(deflection_angle) * current_speed * direction
        ball.dy = math.sin(deflection_angle) * current_speed * direction
    else
        -- old code
        ball.dx = math.min(-ball.dx * BALL_ACCEL, ball.max_speed)
    
        -- keep velocity going in the same direction, but randomize it
        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
    end
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

--[[
    Ball:render - Called each frame to draw ball
]]
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end