# Faction generation prompt

Output goes to `content/factions/<name>.yaml`. Run with N=3 or 4. Review each faction against the GDD pillars before committing.

```
You are a military historian and game designer creating fictional factions for a
turn-based hex wargame set on a fictional Earth-like world with roughly 1980s–2020s
technology (no sci-fi). Logistics (fuel, ammunition, supply lines) is a core mechanic.

Create {N} factions. Each must be plausible, internally consistent, and clearly
distinct from the others in how it fights. Avoid naming, insignia, or thinly-veiled
copies of real nations, alliances or armed forces; original names only. No
real-world ideologies named directly; describe them in your own terms.

For each faction output:

1. identity: name, demonym, short epithet, flag/color scheme in words (two colors,
   one simple geometric symbol — no real-world symbols).
2. geography_and_economy: terrain they come from, population scale, industrial base,
   key resource strengths and shortages (shortages must show up in doctrine).
3. society_and_culture: how authority works, how status is earned, attitude toward
   casualties, attitude toward technology, one defining historical trauma or triumph
   that shaped the military.
4. military_doctrine: how they prefer to win; offensive vs defensive posture;
   centralized vs mission-command; attitude to logistics (lavish/austere/improvised);
   signature tactic; known blind spot an opponent can exploit.
5. force_structure: preferred mix across infantry, armor, artillery, recon, engineers,
   logistics/trucks, air support (as rough percentages that sum to 100); one or two
   "signature" unit types with a one-line description and why they exist.
6. ai_profile (YAML, numeric 0.0–1.0 unless stated), derived directly from 3–5:
     aggression:                 # willingness to attack at unfavorable odds
     risk_tolerance:             # acceptable casualty rate before withdrawing
     logistics_discipline:       # how far beyond supply range it will operate (higher = stays closer)
     concentration:              # mass vs dispersion of forces
     tempo:                      # preference for continuous pressure vs pauses to resupply
     flank_preference:           # frontal vs flanking maneuvers
     reserve_ratio:              # fraction of force held back
     artillery_reliance:
     recon_emphasis:
     attrition_vs_maneuver:      # 0 = pure attrition, 1 = pure maneuver
     retreat_threshold:          # strength fraction at which units pull back
     doctrine_rules:             # 3–5 if/then rules in plain English the AI follows,
                                 # e.g. "if a unit's supply line is cut, prioritize reopening it over attacking"
     exploitable_weakness:       # one sentence, for scenario design and difficulty tuning
7. voice: 3 sample lines of radio chatter or briefing text in the faction's tone
   (for UI flavor), and 5 words that should never appear in their dialogue.

Constraints: no two factions may share the same top-two values in ai_profile; at
least one faction must be logistics-austere and one logistics-lavish; every stated
cultural trait must be traceable to at least one ai_profile value or doctrine rule.
Output as one YAML document per faction.
```
