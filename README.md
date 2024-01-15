# Mario Game
## Video Demo:  [Watch Demo](https://youtu.be/4XLXpPgF0PQ?si=JpGuBXB7r9Y8M1Wu)
## Description:

This is an implementation of Super Mario game. The game is part of CS50 Game Development and I have added the specified features in the Problem Set.

## Table of Contents

- [Player Placement](#player-placement)
- [Generates Key and Lock Blocks](#generates-key-and-lock-blocks)
- [Unlocking the Block](#unlocking-the-block)
- [Spawning the Goal Post](#spawning-the-goal-post)
- [Regenerating the Level](#regenerating-the-level)

## Features Added:

### Player Placement
- Ensured the player is dropped onto solid ground when the level is generated.

### Generates Key and Lock Blocks
- Implemented a mechanism to ensure the generation of random-colored key and lock blocks in LevelMaker.lua.
- The key unlocks the block when the player collides with it, triggering the block to disappear.
- Maintained a flag for whether the key and lock have been spawned and placed.
- Randomly chose to place them during level generation.

### Unlocking the Block
- Implemented the mechanism for picking up the key.
- Implemented the key blocks using the code for spawning blocks and the onCollide function.

### Spawning the Goal Post
- Triggers a goal post to spawn at the end of the level when the lock has disappeared.

### Regenerating the Level
- When the player touches the goal post, the level is regenerated and the player spawns at the beginning again.
- Introduced params to the PlayState:enter function to keep track of the current level and persist the player’s score.

