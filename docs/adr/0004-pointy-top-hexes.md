# ADR 0004 — Pointy-top hex orientation

**Status:** accepted · **Date:** 2026-11-07

## Decision
Pointy-top hexes in the presentation layer. `IronPipeline.Sim` uses axial/cube coordinates and is orientation-agnostic.

## Why
Rows run horizontally, so east–west front lines advance in straight lines and wide operational maps fit 16:9 displays. Flat-top would favour north–south fronts.

## Consequence
Terrain tile art is orientation-specific; generate none until this ADR is final (it is).
