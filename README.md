# pong
 
The original code is from [Project 0](https://cs50.harvard.edu/games/2018/projects/0/) from HarvardX's [CS50 Introduction to Game Development](https://learning.edx.org/course/course-v1:HarvardX+CS50G+Games/home)

# Goal

Writing a version where different computer players (I think calling them "AI" is setting the bar way too low) can play against each other. This time we want to make it difficult for a computer player to cheat.

# Status

The current computer player implementation is good enough that when it plays itself the game approaches a stalemate. 

The problem is that the ball's velocity is dominated by the dx movement. As the ball accelerates at each "hit" of the paddle it's eventually moving very fast back and forth with little vertical movement -- so paddles need hardly move at all.

The pong implementation from the CS50 course allowed a ball to "pass through" a paddle if it was moving fast enough (the collision detector never had a chance to kick in, because the ball went from "just in front of" to "just behind" in a single step). I "fixed" that by "clipping" the ball to the y coordinate of a paddle if it passed through too quickly. But as a consequence, stalemate occurs.

The original game of pong (from memory) allowed the player some control over the angle of deflection when the ball bounces off the paddle. If the ball hit the paddle's edge, the ball might bounce off at 45 degrees. If it hit the middle of the paddle, the ball would come off at right angles to the paddle. This behaviour could be useful.

Current plan:

* Introduced new `Player` class, separate from the `Paddle` class, to make it harder to cheat by directly manipulating internal state
* Fix `Ball` class so that vertical movement is retained, even at high speeds

Later:

* Use Lua's method of making member variables "private" (see [Programming in Lua, s16.4](https://www.lua.org/pil/16.4.html)) to protect `Paddle` instances from direct manipulation by `Player`s 
* Pass different `Player` classes to the game and have it print out the winner
* Check this Pong implementation against the [original Pong mechanics](https://gamemechanics.fandom.com/wiki/Pong)


# Rules (Mechanics)

These are all still TODO:

* In the original, the paddle was divided into 8 segments, and where the ball hit would determine the angle the ball deflected
* The original also had a limitation that made the very top and very bottom of the screen inaccessible to paddles. This could be exploited by skilled players to score points - otherwise the game could go on too long
* Hitting the ball with a paddle that is moving could impart some momentum to the ball, consistent with the direction the paddle was moving at time of collision
* Hitting the ball with a paddle that is still could slightly decrease the velocity of the ball


Sources: [Game Mechanics: Pong](https://gamemechanics.fandom.com/wiki/Pong); [Wikipedia: Pong](https://en.wikipedia.org/wiki/Pong)