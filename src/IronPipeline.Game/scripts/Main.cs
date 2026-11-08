using Godot;
using IronPipeline.Sim.Hex;

namespace IronPipeline.Game;

/// <summary>
/// Root scene. Presentation only: renders Sim state and forwards player input as Commands.
/// Pointy-top hex layout (decided; see docs/adr/0004-pointy-top-hexes.md).
/// </summary>
public partial class Main : Node2D
{
    private const float HexSize = 32f; // center-to-corner, pixels

    public override void _Ready()
    {
        // Smoke test of the Sim reference: draw a ring so the first run shows something.
        QueueRedraw();
    }

    public override void _Draw()
    {
        foreach (HexCoord h in HexCoord.Origin.Ring(3))
        {
            DrawHex(ToPixel(h), new Color(0.25f, 0.45f, 0.25f));
        }

        DrawHex(ToPixel(HexCoord.Origin), new Color(0.6f, 0.6f, 0.2f));
    }

    /// <summary>Axial → pixel for pointy-top hexes (Red Blob Games "pointy" layout).</summary>
    private static Vector2 ToPixel(HexCoord h)
    {
        float x = HexSize * (Mathf.Sqrt(3f) * h.Q + Mathf.Sqrt(3f) / 2f * h.R);
        float y = HexSize * (1.5f * h.R);
        return new Vector2(x, y);
    }

    private void DrawHex(Vector2 center, Color fill)
    {
        var points = new Vector2[6];
        for (int i = 0; i < 6; i++)
        {
            float angle = Mathf.DegToRad(60f * i - 30f); // pointy-top: first corner at -30°
            points[i] = center + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * (HexSize - 1f);
        }

        DrawColoredPolygon(points, fill);
        DrawPolyline([.. points, points[0]], Colors.Black, 1.5f);
    }
}
