using IronPipeline.Sim.Hex;

namespace IronPipeline.Sim.Map;

/// <summary>
/// Rectangular hex map stored as a flat byte array of indices into a terrain table.
/// Rectangular means odd-r offset: row r in [0, Height), column c in [0, Width), pointy-top friendly.
/// Axial hex (q, r) has column c = q + (r - (r &amp; 1)) / 2. Index = row * Width + column.
/// </summary>
public sealed class HexMap
{
    public const int MinSide = 1;
    public const int MaxSide = 512;
    public const int MaxTerrainTypes = 256;

    private readonly byte[] _cells;

    private HexMap(int width, int height, IReadOnlyList<TerrainType> terrainTypes, byte[] cells)
    {
        Width = width;
        Height = height;
        TerrainTypes = terrainTypes;
        _cells = cells;
    }

    public int Width { get; }

    public int Height { get; }

    public int CellCount => _cells.Length;

    public IReadOnlyList<TerrainType> TerrainTypes { get; }

    /// <summary>A map where every cell is <paramref name="fill"/>, which must be one of <paramref name="terrainTypes"/>.</summary>
    public static HexMap Filled(int width, int height, IReadOnlyList<TerrainType> terrainTypes, TerrainType fill)
    {
        ArgumentNullException.ThrowIfNull(terrainTypes);
        ArgumentNullException.ThrowIfNull(fill);
        ArgumentOutOfRangeException.ThrowIfLessThan(width, MinSide);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(width, MaxSide);
        ArgumentOutOfRangeException.ThrowIfLessThan(height, MinSide);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(height, MaxSide);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(terrainTypes.Count, MaxTerrainTypes);

        IReadOnlyList<TerrainType> table = Array.AsReadOnly(terrainTypes.ToArray());
        int fillIndex = IndexOfType(table, fill);
        byte[] cells = new byte[width * height];
        Array.Fill(cells, (byte)fillIndex);
        return new HexMap(width, height, table, cells);
    }

    /// <summary>The axial hex at offset column <paramref name="column"/>, row <paramref name="row"/> (no bounds check).</summary>
    public static HexCoord HexAt(int column, int row) => new(column - ((row - (row & 1)) / 2), row);

    /// <summary>The terrain at <paramref name="hex"/>. Throws <see cref="ArgumentOutOfRangeException"/> outside the map.</summary>
    public TerrainType TerrainAt(HexCoord hex) => TerrainTypes[_cells[IndexOf(hex)]];

    /// <summary>A copy of this map with <paramref name="hex"/> set to <paramref name="terrain"/>.</summary>
    public HexMap WithTerrain(HexCoord hex, TerrainType terrain)
    {
        ArgumentNullException.ThrowIfNull(terrain);
        int index = IndexOf(hex);
        byte[] cells = (byte[])_cells.Clone();
        cells[index] = (byte)IndexOfType(TerrainTypes, terrain);
        return new HexMap(Width, Height, TerrainTypes, cells);
    }

    public bool InBounds(HexCoord hex) => TryGetIndex(hex, out _);

    /// <summary>Flat-array index of <paramref name="hex"/> (row-major). Throws <see cref="ArgumentOutOfRangeException"/> outside the map.</summary>
    public int IndexOf(HexCoord hex) =>
        TryGetIndex(hex, out int index)
            ? index
            : throw new ArgumentOutOfRangeException(nameof(hex), hex, $"Hex is outside the {Width}x{Height} map.");

    private bool TryGetIndex(HexCoord hex, out int index)
    {
        index = -1;
        if (hex.R < 0 || hex.R >= Height)
        {
            return false;
        }

        int column = hex.Q + ((hex.R - (hex.R & 1)) / 2);
        if (column < 0 || column >= Width)
        {
            return false;
        }

        index = (hex.R * Width) + column;
        return true;
    }

    private static int IndexOfType(IReadOnlyList<TerrainType> terrainTypes, TerrainType type)
    {
        for (int i = 0; i < terrainTypes.Count; i++)
        {
            if (ReferenceEquals(terrainTypes[i], type))
            {
                return i;
            }
        }

        throw new ArgumentException($"Terrain '{type.Id}' is not in the map's terrain table.", nameof(type));
    }
}
