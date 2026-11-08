# Features 0002 — Map and terrain
# Spec: docs/specs/0002-map-and-terrain.md
# Status: implemented
#
# Human-owned behavior contract. Every scenario below becomes exactly one xUnit test
# named S<NN>_<ScenarioInPascalCase> in IronPipeline.Sim.Tests. Numbers, decisions,
# ambiguity log, size and budget are in the Spec (docs/specs/), never here.

Feature: Map and terrain
  As the sim
  I need a rectangular hex map with typed terrain and bounds-checked lookup
  So that movement and combat can depend on the ground (big maps, readable tactics)

  Scenario: S01 Map has width times height cells
    Given terrain types plains, forest and hills loaded from content/terrain
    When I create a 5 by 3 map filled with plains
    Then the map has width 5, height 3 and 15 cells

  Scenario: S02 Zero or negative dimensions are rejected
    When I create a map of width 0 and height 3
    Then creation fails with an out-of-range error
    And creating a map of width 4 and height -1 fails the same way

  Scenario: S03 Every cell of the map is in bounds
    Given a 5 by 3 map
    Then all 15 cells are in bounds
    And the first cell and the last cell are in bounds

  Scenario: S04 Hexes just outside the map are out of bounds
    Given a 5 by 3 map
    Then axial (-1,0), (5,0), (0,-1) and (0,3) are out of bounds
    And (100,100) is out of bounds

  Scenario: S05 Terrain query returns the terrain stored at a hex
    Given a 5 by 3 map filled with plains with forest at the first cell and hills at the last cell
    When I query the terrain at each of those cells and at the center cell
    Then they are forest, hills and plains, with movement cost 2, 3 and 1 and defense modifier 25, 40 and 0

  Scenario: S06 Terrain query outside the map is an error
    Given a 5 by 3 map
    When I query the terrain at (100,100)
    Then the query fails with an out-of-range error

  Scenario: S07 Terrain types load from content with cost and defense
    Given content/terrain contains plains.yaml, forest.yaml and hills.yaml
    When the terrain types are loaded
    Then there are 3 types
    And forest has movement cost 2 MP and defense modifier 25
    And hills has movement cost 3 MP and defense modifier 40

Scenario: S08 A terrain file missing a required field is rejected
    Given a passable terrain file with no movement cost
    When the terrain types are loaded
    Then loading fails with an error naming that file and the missing field

  Scenario: S09 A duplicate terrain id across files is rejected
    Given two terrain files that both declare the id "forest"
    When the terrain types are loaded
    Then loading fails with an error naming the duplicate id and both files

  # Invariants (property tests, not scenarios): for any W,H in 1..64, the number of in-bounds hexes
  # equals W*H; hex→index→hex round-trips for every in-bounds hex; indices are unique and cover
  # 0..W*H-1; InBounds is true iff TerrainAt does not throw; TerrainAt is deterministic.
  # Out of scope: pathfinding (0003), units (0004), rendering.
