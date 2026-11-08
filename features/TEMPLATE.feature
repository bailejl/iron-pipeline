# Features NNNN — <name>   (Gherkin only; decisions and numbers live in docs/specs/NNNN-<name>.md)
# Spec: docs/specs/NNNN-<name>.md
# Status: draft | approved | implemented
#
#
# Human-owned behavior contract. Every scenario below becomes exactly one xUnit test
# named S<NN>_<ScenarioInPascalCase> in IronPipeline.Sim.Tests. Numbers, decisions,
# ambiguity log, size and budget are in the Spec (docs/specs/), never here.

Feature: <Feature name>
  As the sim
  I need <capability>
  So that <player-facing reason tied to a pillar>

  Background:
    Given a fresh game state with seed 1

  Scenario: S01 <first concrete example>
    Given <state>
    When <command>
    Then <observable result>

  Scenario: S02 <edge case>
    ...

  # Schema'd content: one scenario per schema rule ("the loader enforces every schema rule").
  # Geometry/layout decisions (offset parity, neighbor order, ...): a scenario with literal coordinates, e.g.
  #   Then the neighbors of (2,1) are exactly [(3,1), (2,0), (1,0), (1,1), (1,2), (2,2)]

  # Invariants (property tests, not scenarios): ... each must be implementable from the API the Spec states.
