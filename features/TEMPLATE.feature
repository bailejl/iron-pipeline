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

  # Invariants (property tests, not scenarios): ...
