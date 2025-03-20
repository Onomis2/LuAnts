# Luants

## Overview

**Luants** is a small-scale ant colony simulation built entirely in Lua using the **LÖVE2D** engine. Ants will wander around until they run out of energy or find food, which they will bring back to their nest. The more food the nest has, the more ants populate the colony.

![Ants exploring](https://github.com/Onomis2/LuAnts/blob/main/documentation/screenshots/ants.png)
<!-- ![Ants confused in a circle as food source recently depleted](https://github.com/Onomis2/LuAnts/blob/main/documentation/screenshots/circle.png) -->
![Ants forming a highway to a food source](https://github.com/Onomis2/LuAnts/blob/main/documentation/screenshots/highway.png)

## Mechanics

### Ants
- Ants will wander around randomly until they find something of interest
- When they run out of energy, they try to return to the nest by following their own pheromone trails. Some may get lost and die.
- If an ant finds food, it returns to the nest while leaving a pheromone trail to guide other ants. These can form highways
- If ants get lost, they attempt to conserve energy and search for the nearest pheromone trail, which may lead them back to the nest or leaves them wandering in circles until they die.

### Food
- Food sources spawn at random locations on the map.
- Each food source contains a limited amount of food.
- Once depleted, a new food source spawns elsewhere.
- Food sources spoil after about **5 minutes**.

### Pheromones
- Ants leave pheromone trails to either the nest or a food source.
- Ants prioritize following stronger pheromone trails.
- Pheromones decay over time.

## Downloads

- [Download for windows](https://github.com/Onomis2/LuAnts/releases)

## Planned features

- [ ] Multithreading
- [ ] Add menu with options
- [ ] More ant types
- [x] Pheromone clustering
- [x] Performance improvement
- [x] God, please clean up your code!
- [x] Add textures
- [ ] Weather effects
- [ ] Predators
- [ ] Rival ant colonies
- [ ] Map objects
- [ ] Better nest behavior
