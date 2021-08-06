--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- new Player class, which controls the logic for moving Paddles
require 'Player'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200
PADDLE_WIDTH = 5
PADDLE_HEIGHT = 20
PADDLE_GUTTER = 10

-- player settings
MAX_SCORE = 1000

-- used to decide when computer player should serve
nextServeTime = 0

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    numHumanPlayers = 2
    paddle1 = Paddle(PADDLE_GUTTER, 30, PADDLE_WIDTH, PADDLE_HEIGHT)
    paddle2 = Paddle(VIRTUAL_WIDTH - PADDLE_GUTTER, VIRTUAL_HEIGHT - 30, PADDLE_WIDTH, PADDLE_HEIGHT)

    -- create ball, the Ball class will place in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, PADDLE_GUTTER, VIRTUAL_WIDTH - PADDLE_GUTTER)

    -- intialize players; a player needs to know about the paddle it controls,
    -- and the size of the ball (which won't change)
    player1 = Player(1, paddle1, ball.height)
    player2 = Player(2, paddle2, ball.height)

    -- initialize score variables; scores are kept separate because we can't
    -- have players in direct control of their scores
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- player who won the game; not set to a proper value until we reach
    -- that state in the game
    winningPlayer = 0

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
    gameState = 'start'
end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Called every frame, passing in `dt` since the last frame. `dt`
    is short for `deltaTime` and is measured in seconds. Multiplying
    this by any changes we wish to make in our game will allow our
    game to perform consistently across all hardware; otherwise, any
    changes we make will be applied as fast as possible and will vary
    across system hardware.
]]
function love.update(dt)
    if gameState == 'serve' then
        -- if the serving player is computer controlled, we should start
        -- the serve on our own
        if numHumanPlayers == 0 or (numHumanPlayers == 1 and servingPlayer == 2) then
            if nextServeTime == 0 then
                -- start serve 3 seconds from now
                nextServeTime = love.timer.getTime() + 3.0

            elseif nextServeTime > 0 and love.timer.getTime() >= nextServeTime then
                -- before switching to play, initialize ball's velocity based
                -- on player who last scored
                ball:serve(servingPlayer)
                gameState = 'play'
                nextServeTime = 0
            end
        end

    elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position
        -- at which it collided, then playing a sound effect
        if ball:collides(paddle1) then
            ball:bounce(paddle1.x + paddle1.width, paddle1)
            sounds['paddle_hit']:play()
        end
        if ball:collides(paddle2) then
            ball:bounce(paddle2.x - ball.width, paddle2)
            sounds['paddle_hit']:play()
        end

        -- detect upper and lower screen boundary collision, playing a sound
        -- effect and reversing dy if true
        if ball.y <= 0 then
            ball:deflect(0)
            sounds['wall_hit']:play()
        end

        -- -ball.height to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - ball.height then
            ball:deflect(VIRTUAL_HEIGHT - ball.height)
            sounds['wall_hit']:play()
        end

        -- if we reach the left edge of the screen, go back to serve
        -- and update the score and serving player
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
            if player2Score == MAX_SCORE then
                winningPlayer = 2
                gameState = 'done'
                numHumanPlayers = 2
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
                paddle1:reset()
                paddle2:reset()
            end
        end

        -- if we reach the right edge of the screen, go back to serve
        -- and update the score and serving player
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
            if player1Score == MAX_SCORE then
                winningPlayer = 1
                gameState = 'done'
                numHumanPlayers = 2
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
                paddle1:reset()
                paddle2:reset()
            end
        end
    end

    --
    -- paddles can move no matter what state we're in, but only if the
    -- humans are in charge!
    --

    if numHumanPlayers == 1 then
        -- player 1 human; player 2 is computer
        paddle1.dy = player1:humanmove(PADDLE_SPEED, 'w', 's')
        paddle2.dy = player2:automove(PADDLE_SPEED, ball.x, ball.y)
    elseif numHumanPlayers == 2 then
        -- player 1 and 2 are human
        paddle1.dy = player1:humanmove(PADDLE_SPEED, 'w', 's')
        paddle2.dy = player2:humanmove(PADDLE_SPEED, 'up', 'down')
    else
        -- player 1 and 2 are computer
        paddle1.dy = player1:automove(PADDLE_SPEED, ball.x, ball.y)
        paddle2.dy = player2:automove(PADDLE_SPEED, ball.x, ball.y)
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    paddle1:update(dt)
    paddle2:update(dt)
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    -- `key` will be whatever key this callback detected as pressed
    if key == 'escape' then
        if gameState == 'play' then
            gameState = 'start'
        else
            -- the function LÖVE2D uses to quit the application
            love.event.quit()
        end

    elseif key == '0' or key == '1' or key == '2' then
        -- enter 0, 1 or 2 is only valid at the start, and sets the number of
        -- human players
        if gameState == 'start' then
            gameState = 'serve'
            numHumanPlayers = tonumber(key)
        end

    elseif key == 'enter' or key == 'return' or key == 'space' then
        -- if we press enter during either the start or serve phase, it should
        -- transition to the next appropriate state
        if gameState == 'serve' then
            -- before switching to play, initialize ball's velocity based
            -- on player who last scored
            ball:serve(servingPlayer)
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'start'

            ball:reset()
            paddle1:reset()
            paddle2:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    -- render different things depending on which part of the game we're in
    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('How many humans playing (1, 2, or 0)?', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        if numHumanPlayers == 0 or (numHumanPlayers == 1 and servingPlayer == 2) then
            love.graphics.printf(string.format('Computer to serve in %d!', nextServeTime - love.timer.getTime() + 0.5), 
                0, 20, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        end
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- show the score before ball is rendered so it can move over the text
    displayScore()
    
    paddle1:render()
    paddle2:render()
    ball:render()

    -- display FPS for debugging; simply comment out to remove
    displayFPS()

    -- end our drawing to push
    push:apply('end')
end

--[[
    Simple function for rendering the scores.
]]
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
