--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    --print the width
    print(width)
    math.randomseed(os.time()) -- Use the current time as a seed
    
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- whether the lock and the key has been spawn
    local keySpawn = true
    local keyFound = false
    local lockSpawn = true

    -- whether block is spawn in the column
    local blockSpawn = false
    local keyFrame = 0

    -- x location of lock and key
    local keyX = 16
    local lockX = 7 * 16

    -- x location of the pole
    local poleX

    -- width of the current level
    local currentWidth = width

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(5) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end


            -- chance to spawn a block
            if math.random(10) == 1 then
                blockSpawn = true
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
            
            --Chance to spawn a key and a lock
            -- variable to store keyframe so that lock could be of same type
            if (keySpawn == true) and blockSpawn == false then
                keyFrame = math.random(4)
                keyX = math.random((width/100) * 10, (width/100) * 35) * TILE_SIZE
                table.insert(objects,

                    -- Key
                    GameObject{
                        texture = 'keys_and_locks',
                        --put key closer to the beginning in the world
                        x = keyX,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16, 
                        frame = keyFrame,
                        collidable = true,
                        consumable = true,
                        solid = false,

                        onConsume = function()
                            gSounds['pickup']:play()
                            keyFound = true
                        end     
                    }
                )
                keySpawn = false
            end

            if (lockSpawn == true) and keySpawn == false then
                lockX= math.random((width/100) * 60, (width/100) * 90) * TILE_SIZE
                table.insert(objects,
                    -- lock
                    GameObject{
                        texture = 'keys_and_locks',
                        --put lock far later in the world
                        x = lockX,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16, 
                        frame = keyFrame + 4,
                        collidable = true,
                        hit = false,
                        solid = true,
                        
                        -- collision function takes itself
                        onCollide = function(obj)
                            -- disappear if we have the key
                            if keyFound then
                                for i = 1, #objects do
                                    if objects[i] == obj then
                                        table.remove(objects, i)
                                        gSounds['unlocked']:play()
                                        -- spawn the flag at the end of the level
                                        -- make sure that the pole is spawn on the solid ground
                                        poleX = (width - 2) * TILE_SIZE              

                                        table.insert(objects,
                                            --pole
                                            GameObject{
                                                texture = 'pole',
                                                -- put at the end in the world
                                                x = poleX,
                                                y = 3 * TILE_SIZE,
                                                width = 16, 
                                                height = 16 * 3,
                                                frame = 4,
                                                collidable = true,
                                                consumable = true,
                                                solid = false,

                                                onConsume = function(player)
                                                    gSounds['victory']:play()
                                                    -- change to begin game state with new width (incremented)
                                                    gStateMachine:change('play', {
                                                        width = currentWidth + 30,
                                                        score = player.score + 500
                                                    })
                                                end
                                            }
                                        )
                                        -- insert the flag over the pole so as to look like one unit
                                        table.insert(objects,
                                            --flag
                                            GameObject{
                                                texture = 'flag',
                                                -- put at the end in the world
                                                x = poleX + TILE_SIZE / 2,
                                                y = 3.2 * TILE_SIZE,
                                                width = 16, 
                                                height = 16,
                                                frame = 16,
                                                collidable = true,
                                                consumable = true,
                                                solid = false,
                                                
                                                onConsume = function(player)
                                                    gSounds['victory']:play()
                                                    -- change to begin game state with new width (incremented)
                                                    gStateMachine:change('play', {
                                                        width = currentWidth + 30,
                                                        score = player.score + 500
                                                    })
                                                end
                                            }
                                        )
                                    end
                                end
                            end
                        end
                    }
                )
                lockSpawn = false
            end
        end
        blockSpawn = false
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end