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
- Move functions into more general functions?

## Bugs

- Predator velocity can be 0, resulting in a non-existant angle, leading to predators sitting around and sudden changes in velocity. Possible fix is increasing search range if resulting velocity is 0, or increasing/decreasing angle of search
- Predators will sometimes be pushed against walls. This is likely caused by predators moving in same direction as boid group
