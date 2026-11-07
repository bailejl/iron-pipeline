# Spec NNNN — <Feature name>
# Status: draft | approved | implemented
# Pillar(s): logistics tension | big maps | readable tactics | distinct factions
# Size: small (single agent + gates) | feature (full pipeline)
#
# Human-owned intent. Every scenario below becomes exactly one xUnit test named
# S<NN>_<ScenarioInPascalCase> in IronPipeline.Sim.Tests. Numbers live in the
# "Numbers" table so balance changes are data changes.

Feature: <Feature name>
  As the sim
  I need <capability>
  So that <player-facing reason tied to a pillar>

  Background:
    Given a fresh game state with seed 1

  # Numbers (single source of truth for this feature's constants)
  # | name | value | unit |
  # | ...  | ...   | ...  |

  Scenario: S01 <first concrete example>
    Given <state>
    When <command>
    Then <observable result>

  Scenario: S02 <edge case>
    ...

  # Out of scope (explicitly): ...
  # Open questions for the human: ...
