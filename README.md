# Super Mario Bros

## Table of Contents
1. [How to run](#how-to-run)
2. [Game Mechanics](#game-mechanics)
    * [Game States](#game-states)
    * [Player States](#player-states)
    * [Ennemy States](#ennemy-states)
3. [Animation](#animation)
4. [Game Data](#game-data)
5. [Collision Detection](#collision-detection)
6. [Level Generation](#level-generation)
7. [Game Control](#game-control)

## how to run
In order to run the game you need to download the game framework love2d from the website love2d.org
downloading the file super-mario-bros.love is the only one necessary which contains the code source compressed, the other files contains the code source for reviewing purpose, starting with main.lua .
run the downloaded file using the game framework previously downloaded, and then enjoy the game.

## Game mechanics
The implementation of this game make use of several design pattern to solve the encountered problems, notably the **State Pattern**. <br/>
* The game in composed of 4 different states:
    1. Start state
    2. Play state
    3. Victory state
    4. Game over State

### Game States
Each of the states mentionned above are objects, their corresponding classes are in the stateMachine file. <br/>
The start, victory, and game over state, are simple states, they manifest with a blue screen telling the user what he should do to start the game, replay again, etc...
The main action happens in the transition between start state and play state, when the algorithm present in <code>LevelMaker.lua</code> will generate all the objects and entities present in the game. After that the process of updating all the objects and entities, as well as drawing them is at the charge of the play state.
The task of transitionning between the states is taken care of by the class StateMachine, where call the different states will keep track of the stateMachine instance and will call the change method apropriately.

### Player States
The main character of the game (Mario), is also modeled using a different states. <br/>
We have have two state categories : 
* Mario's shape:
    1. Small mario
    2. Big mario
    3. Shooting mario
    4. Small mario recovering (after being hit by the ennemy, when his image starts to blink)

* Mario's action:
    1. Mario idle state
    2. Mario walking state
    3. Mario jumping state
    4. Mario falling state
    5. Mario crouching state

At any moment in the game, we should be able to have any two combination of these states (small mario idle, big mario jumping, small mario recovering walking). <br/>
In order to have any combination of these two state categories, we also have created a BaseState interface, which all the of the states mentionned above implements. <br/>
Each of these states have its own class where it overrides the methods update and draw, so that it have its own behaviour, and its own interactions with the different encountered game objects and entities. (for example small mario recovering will not die when he touchs the ennemy, while a falling mario will kill that ennemy, big mario will transit to small mario recovering, and small mario will simply die). <br/>
The different states are able to transit between each other when necessary. (small mario will transit to big mario when he touchs the mushroom, big mario will transit to small mario recovering when he touchs an ennemy). <br/>
The handling of the transition between states is in charge of the class PlayerState.

### Ennemy states
The ennemies in the game (mushroom and turtle) also possess their own states, and their are 5 of them.
* Ennemy's states:
    1. Entity idle state
    2. Entity walk state
    3. Entity roll state (unique to the turtle)
    4. Entity smash state (unique to the mushroom)
    5. Entity die state

All of the states mentionned above also implements the BaseState interface. <br/>
The core working of these states is very similar to the player states described above. <br/>
Entities can have some of the above listed states, or all of them. And it can transition between all entities that it has access to. (for example when mario jump on a given entity, the mushroom is smashed, while the turtle rolls, the mushroom can not go to roll state, neither can the turtle go to smashed state).

## Animation
The animation in the game is done by looping through a set of images of the corresponding object/entity in a well timed manner. The animation is taken care of by the class <code>./gameElements/Animation.lua</code> <br/>
Since the main character have different states, and each state have a different animation, an AnimationState is needed to change the animation whenever the state of that character changes. The corresponding class is <code>./gameElements/AnimationState.lua</code>

## Game Data
We can so far see how much data we have for all the different player states, entities, and objects. Most of the game objects and entities have a lot of properties in common : width, height, image, animation, playerState, etc... <br/>
These data are stored inside of arrays in the following way:
* There is an array for each unique object, or entity, and will group all the different properties unique to it
* All of the different array are separated into two groups each group in an array, representing an array of object data, and another one for entities data.
* Player data are stored inside the class and not in arrays.
* these arrays are located at the top of <code>./gameElements/LevelMaker.lua</code> file

During the creation of game objects and entities, the array containing the data specific to each object or entity is given to its constructor as parameter. <br/>
By grouping the data inside arrays, we can create an unlimited amount of objects and entities by using only two classes (object and entity classes), any newly added object or entity is simply represented by its data array added to the already existing data.

## Collision Detection
In order to detect collision between the main character and the entities, we iterate over all of them and check if there is a collision using a simple **Axis-Aligned-Bounding-Box** collision detection algorithm. In the case of a collision, we use an algorithm which given two objects having width and height and coordinates, return the the side of the collision with respect of the two object. In this way we are able to tell which side the collision happened, and then the game will behave accordingly. (if mario hits the ennemy from the sides he dies, if the hit is from the top the ennemy dies) <br/>
To detect collision with game objects, we find the nearest objects to the character and apply the same algorithm above.

## Level Generation
The generation of the levels is implemented in the LevelMaker file. 
After the organisation of the data inside of array, we have another array that stores the coordinate of each desired object and entity in the game's map. the algorithm will iterate over that array, will created the designated object/entites and will give it its coordinate as well as its data array. and then all these instances will be stored in another array to be returned, the final array containing the instances is then given to the play state.

## Game Control
The game is can come to an end in several ways:
* PlayState will keep track of timer and will end the game b transitioning to GameOver if the time ends
* The players reach the end of the map, then the game is transitionned to VictoryState
* The players loses all of the lifes, and the game ends by transitionning to GameOverState.

Variables such as score, and coins collected are made global to be changed by different game objects when necessary.
