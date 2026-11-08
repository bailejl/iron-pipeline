namespace IronPipeline.Sim.Map;

/// <summary>A kind of ground: what it costs to enter and how much it helps a defender. Loaded from content/terrain.</summary>
public sealed class TerrainType
{
    private readonly int _movementCost;

    private TerrainType(string id, bool isPassable, int movementCost, int defenseModifierPct)
    {
        Id = id;
        IsPassable = isPassable;
        _movementCost = movementCost;
        DefenseModifierPct = defenseModifierPct;
    }

    public string Id { get; }

    public bool IsPassable { get; }

    /// <summary>Defense modifier in whole percent.</summary>
    public int DefenseModifierPct { get; }

    /// <summary>MP to enter. Throws for impassable terrain.</summary>
    public int MovementCost => IsPassable
        ? _movementCost
        : throw new InvalidOperationException($"Terrain '{Id}' is impassable and has no movement cost.");

    public static TerrainType Passable(string id, int movementCost, int defenseModifierPct) =>
        new(id, true, movementCost, defenseModifierPct);

    public static TerrainType Impassable(string id, int defenseModifierPct) =>
        new(id, false, 0, defenseModifierPct);
}
