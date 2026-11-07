// Headless tooling around IronPipeline.Sim. Grows into: replay runner (golden
// replays), content validator (YAML vs schema), and AI self-play balance sims.
// Each sub-command must be deterministic and exit non-zero on failure so CI can gate on it.

using System.Globalization;

if (args.Length == 0)
{
    PrintUsage();
    return 2;
}

switch (args[0])
{
    case "replay":
        Console.WriteLine("replay: not implemented yet (spec 000X). Will load a .replay file, re-run it, and compare the state hash.");
        return 0;
    case "validate-content":
        Console.WriteLine("validate-content: not implemented yet. Will validate content/**/*.yaml against content/schemas.");
        return 0;
    case "selfplay":
        Console.WriteLine("selfplay: not implemented yet. Will run N AI-vs-AI games and emit a balance report.");
        return 0;
    default:
        Console.Error.WriteLine(string.Format(CultureInfo.InvariantCulture, "Unknown command: {0}", args[0]));
        PrintUsage();
        return 2;
}

static void PrintUsage()
{
    Console.WriteLine("usage: ironpipeline-tools <replay|validate-content|selfplay> [args]");
}
