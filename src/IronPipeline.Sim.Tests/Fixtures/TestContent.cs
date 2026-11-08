using IronPipeline.Sim.Map;

namespace IronPipeline.Sim.Tests.Fixtures;

/// <summary>Locates the repo's content/ directory and loads real terrain from it.</summary>
internal static class TestContent
{
    public static string TerrainDirectory { get; } = FindTerrainDirectory();

    public static IReadOnlyList<TerrainType> LoadTerrain() => TerrainLoader.LoadDirectory(TerrainDirectory);

    private static string FindTerrainDirectory()
    {
        DirectoryInfo? dir = new(AppContext.BaseDirectory);
        while (dir is not null)
        {
            string candidate = Path.Combine(dir.FullName, "content", "terrain");
            if (Directory.Exists(candidate))
            {
                return candidate;
            }

            dir = dir.Parent;
        }

        throw new DirectoryNotFoundException("content/terrain not found above " + AppContext.BaseDirectory);
    }
}
