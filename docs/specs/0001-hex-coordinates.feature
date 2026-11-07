# Spec 0001 — Hex coordinates
# Status: implemented
# Pillar(s): big maps, readable tactics
# Size: small

Feature: Hex coordinates
  As the sim
  I need axial/cube hex coordinates with neighbors, distance, rings and lines
  So that every other system can reason about the map deterministically

  Scenario: S01 Origin has six distinct neighbors at distance one
    Given the origin hex (0,0)
    When I list its neighbors
    Then there are 6 distinct hexes, each at distance 1

  Scenario: S02 Distance between known hexes matches the cube metric
    Then distance (0,0)→(3,0) is 3
    And distance (0,0)→(0,3) is 3
    And distance (0,0)→(3,-3) is 3
    And distance (0,0)→(2,2) is 4

  Scenario: S03 Ring of radius two has twelve hexes all at distance two
    Given center hex (1,-2)
    When I take the ring of radius 2
    Then it contains 12 distinct hexes, all at distance 2 from the center

  Scenario: S04 Ring of radius zero is just the center
    Given hex (4,4)
    When I take the ring of radius 0
    Then it contains only (4,4)

  Scenario: S05 Line from A to B starts at A, ends at B and steps by one
    Given A=(0,0) and B=(3,-2)
    When I take the line from A to B
    Then it has distance(A,B)+1 hexes, starts at A, ends at B, and consecutive hexes are adjacent

  Scenario: S06 Neighbor directions wrap around
    Given hex (5,-3)
    Then neighbor(0) equals neighbor(6)
    And neighbor(5) equals neighbor(-1)

  # Invariants (property tests, not scenarios): q+r+s=0; distance symmetric; triangle
  # inequality; ring(r) has 6r hexes; line length = distance+1; line is deterministic.
  # Out of scope: pixel layout (presentation), offset coordinates (add when map storage needs them).
