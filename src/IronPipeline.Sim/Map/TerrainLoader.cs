using System.Globalization;

namespace IronPipeline.Sim.Map;

/// <summary>
/// Loads terrain types from content/terrain/*.yaml, one file per type, in file-name order.
/// Reads the flat "key: value" YAML subset the terrain schema uses. Any problem fails the whole load
/// with an <see cref="InvalidDataException"/> naming the file.
/// </summary>
public static class TerrainLoader
{
    private const int MinCost = 1;
    private const int MaxCost = 9;
    private const int MinDefense = -50;
    private const int MaxDefense = 100;

    public static IReadOnlyList<TerrainType> LoadDirectory(string directory)
    {
        string[] files = Directory.GetFiles(directory, "*.yaml");
        Array.Sort(files, StringComparer.Ordinal);

        List<TerrainType> types = [];
        Dictionary<string, string> sourceById = [];
        foreach (string file in files)
        {
            TerrainType type = Parse(File.ReadAllText(file), file);
            if (sourceById.TryGetValue(type.Id, out string? first))
            {
                throw new InvalidDataException($"Duplicate terrain id '{type.Id}' in {first} and {file}.");
            }

            sourceById.Add(type.Id, file);
            types.Add(type);
        }

        return types;
    }

    public static TerrainType Parse(string yaml, string source)
    {
        Dictionary<string, string> fields = ReadFields(yaml, source);

        string id = Require(fields, "id", source);
        if (!IsValidId(id))
        {
            throw new InvalidDataException($"{source}: field 'id' must match [a-z][a-z0-9_]*, got '{id}'.");
        }

        bool passable = !fields.TryGetValue("passable", out string? passableText)
            || ParseBool(passableText, source);
        int defense = ParseInt(Require(fields, "defense_modifier", source), "defense_modifier", MinDefense, MaxDefense, source);
        int? cost = fields.TryGetValue("movement_cost", out string? costText)
            ? ParseInt(costText, "movement_cost", MinCost, MaxCost, source)
            : null;

        return passable
            ? TerrainType.Passable(id, cost ?? throw new InvalidDataException($"{source}: missing required field 'movement_cost'."), defense)
            : TerrainType.Impassable(id, defense);
    }

    private static bool IsValidId(string id) =>
        id[0] is >= 'a' and <= 'z' && id.All(c => c is (>= 'a' and <= 'z') or (>= '0' and <= '9') or '_');

    private static Dictionary<string, string> ReadFields(string yaml, string source)
    {
        string[] known = ["id", "passable", "movement_cost", "defense_modifier"];
        Dictionary<string, string> fields = [];
        string[] lines = yaml.Split('\n');
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i].Trim();
            if (line.Length == 0 || line[0] == '#')
            {
                continue;
            }

            int colon = line.IndexOf(':', StringComparison.Ordinal);
            if (colon <= 0)
            {
                throw new InvalidDataException($"{source}: line {i + 1}: expected 'key: value'.");
            }

            string key = line[..colon].Trim();
            if (Array.IndexOf(known, key) < 0)
            {
                throw new InvalidDataException($"{source}: unknown field '{key}'.");
            }

            if (!fields.TryAdd(key, line[(colon + 1)..].Trim()))
            {
                throw new InvalidDataException($"{source}: field '{key}' is set twice.");
            }
        }

        return fields;
    }

    private static string Require(Dictionary<string, string> fields, string key, string source) =>
        fields.TryGetValue(key, out string? value) && value.Length > 0
            ? value
            : throw new InvalidDataException($"{source}: missing required field '{key}'.");

    private static bool ParseBool(string text, string source) => text switch
    {
        "true" => true,
        "false" => false,
        _ => throw new InvalidDataException($"{source}: field 'passable' must be true or false, got '{text}'."),
    };

    private static int ParseInt(string text, string key, int min, int max, string source)
    {
        if (!int.TryParse(text, NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out int value)
            || value < min || value > max)
        {
            throw new InvalidDataException($"{source}: field '{key}' must be an integer in {min}..{max}, got '{text}'.");
        }

        return value;
    }
}
