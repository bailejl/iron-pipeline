namespace IronPipeline.Sim.Tests.Fixtures;

internal sealed class TempDir : IDisposable
{
    private readonly DirectoryInfo _dir = Directory.CreateTempSubdirectory("ironpipeline-");

    public string Path => _dir.FullName;

    public void Dispose() => _dir.Delete(recursive: true);
}
