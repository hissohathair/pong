# pong
 
The original code is from [Project 0](https://cs50.harvard.edu/games/2018/projects/0/) 
from HarvardX's [CS50 Introduction to Game Development](https://learning.edx.org/course/course-v1:HarvardX+CS50G+Games/home)

# Goal

Writing a version where different computer players can play against
each other. This time we want to make it difficult for a computer player
to cheat.

# Status

The current computer player implementation is good enough that when it
plays itself the game approaches a stalemate. 

The problem is that the balls velocity is dominated by the dx movement. As
the ball accelerates at each "hit" of the paddle it's eventually moving
very fast back and forth with little vertical movement -- so paddles need
hardly move at all.

The original pong implementation from the CS50 course allowed a ball to
"pass through" a paddle if it was moving fast enough (the collision
detector never had a chance to kick in, because the ball went from "just
in front of" to "just behind" in a single step). I "fixed" that by "clipping"
the ball to the y coordinate of a paddle if it passed through too quickly.
But as a consequence, stalemate occurs.

Current plan:

* See if increased `MAX_BALL_SPEED` reduces stalemate
* Refactor some of the code in preparation for changing ball and paddle
  behaviour

Later:

* Introduce new `Player` class, separate from the `Paddle` class, to make
  it harder to cheat by directly manipulating internal state
* Pass different `Player` classes to the game and have it print out the
  winner

