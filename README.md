# Boids

An implementation of [Craig Reynolds boids simulation](https://www.red3d.com/cwr/boids/) written in Odin rendered in raylib

## Quick Start

1. Install Odin on your computer
2. Navigate to src directory
   `cd path/to/project`
3. Run the program
   `odin run src/simulation`

## Future Additions

- Obstacle avoidance
- UI for controling behavior

## TODO

- Fix bugs
- Make sprites a map that is addressable by path
- Move functions into more general functions?

## Bugs

- Predators will sometimes be pushed against walls. This is likely caused by predators moving in same direction as boid group while at edge of board
