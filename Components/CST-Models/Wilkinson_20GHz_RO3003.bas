
' ============================================================
' CST Studio Suite VBA Macro
' Wilkinson Power Divider @ 20 GHz on RO3003 (h = 0.254 mm)
' Author: M365 Copilot
' Date: Auto-generated
' ============================================================
Option Explicit

Sub Main()
    ' ---------------- Parameters ----------------
    With Parameter
        .Add "f0", "20e9"                  ' Center frequency [Hz]
        .Add "er", "3.0"                   ' Relative permittivity RO3003
        .Add "tand", "0.001"               ' Loss tangent
        .Add "h", "0.254e-3"               ' Substrate thickness [m]
        .Add "tCu", "17e-6"                ' Copper thickness [m]
        .Add "W50", "0.73e-3"              ' 50 Ohm width [m]
        .Add "W70", "0.35e-3"              ' 70.7 Ohm width [m]
        .Add "Lq", "2.42e-3"               ' Quarter-wave length [m]
        .Add "Riso", "100"                  ' Isolation resistor [Ohm]
        .Add "Rbend", "1.0e-3"             ' Bend radius [m]
        .Add "FeedExt", "1.2e-3"           ' Port extension length [m]
        .Add "GapRes", "0.25e-3"           ' Gap for SMD resistor pads [m]
        .Add "PadL", "0.6e-3"              ' SMD pad length [m]
        .Add "PadW", "0.4e-3"              ' SMD pad width [m]
        .Add "BoardX", "12e-3"             ' Board size X [m]
        .Add "BoardY", "10e-3"             ' Board size Y [m]
    End With
    
    ' Units
    With Units
        .Geometry "mm"
        .Frequency "GHz"
        .Time "ns"
        .Voltage "V"
        .Resistance "Ohm"
    End With
    
    ' Grid (optional)
    With Grid
        .Reset
        .StepX "0.05"
        .StepY "0.05"
        .StepZ "0.01"
    End With

    ' -------------------------------------------------
    ' Materials: RO3003 and Copper
    ' -------------------------------------------------
    With Material
        .Reset
        .Name "RO3003"
        .Folder "Dielectrics"
        .Type "Normal"
        .Eps "er"
        .Mue "1"
        .TanD "tand"
        .Colour 0.9, 0.6, 0.2
        .Create
    End With
    
    With Material
        .Reset
        .Name "Copper"
        .Folder "Metals"
        .Type "Normal"
        .FrqType "static"
        .Eps "1"
        .Mue "1"
        .Kappa "5.8e7"
        .TanD "0.0"
        .Colour 0.72, 0.45, 0.2
        .Create
    End With

    ' -------------------------------------------------
    ' Create Substrate and Ground
    ' -------------------------------------------------
    With Brick
        .Reset
        .Name "Substrate"
        .Component "Board"
        .Material "RO3003"
        .Xrange "-BoardX/2", "BoardX/2"
        .Yrange "-BoardY/2", "BoardY/2"
        .Zrange "0", "h"
        .Create
    End With

    With Brick
        .Reset
        .Name "GND"
        .Component "Board"
        .Material "Copper"
        .Xrange "-BoardX/2", "BoardX/2"
        .Yrange "-BoardY/2", "BoardY/2"
        .Zrange "-tCu", "0"
        .Create
    End With

    ' -------------------------------------------------
    ' Signal Layer (z = h .. h+tCu)
    ' We'll build as sheets extruded to thickness tCu
    ' -------------------------------------------------
    Dim zTop As String
    zTop = "h"

    ' Helper placements
    Dim x0 As String: x0 = "0"
    Dim y0 As String: y0 = "0"

    ' Geometry layout reference:
    ' Port1 feed (50 Ohm) -> Split node -> two lambda/4 branches (70.7 Ohm) -> output pads + resistor pads

    ' ---------------- 2D Curves for copper ----------------
    ' Use curves + sweep for nice rounded bends

    ' Center feed line (50 Ohm)
    With Curve
        .Reset
        .Name "Feed50"
        .Curve "polyline"
        .Point "-FeedExt-0.6e-3", "0", ""
        .Point "0", "0", ""
        .Create
    End With

    ' Split tee: short 50->70 transition segment (keep as 50 width up to split)
    With Curve
        .Reset
        .Name "Tnode"
        .Curve "polyline"
        .Point "0", "0", ""
        .Point "0.05e-3", "0", ""
        .Create
    End With

    ' Upper branch centerline (arc with bend radius)
    With Curve
        .Reset
        .Name "ArmTop"
        .Curve "polyline"
        .Point "0.05e-3", "0", ""
        .Point "0.3e-3", "0", ""
        .Point "0.3e-3 + Lq/2", "Rbend", ""
        .Point "Lq", "Rbend", ""
        .Create
    End With
    With Curve
        .Fillet "ArmTop", 2, 3, "Rbend"
    End With

    ' Lower branch (mirrored in Y)
    With Curve
        .Reset
        .Name "ArmBot"
        .Curve "polyline"
        .Point "0.05e-3", "0", ""
        .Point "0.3e-3", "0", ""
        .Point "0.3e-3 + Lq/2", "-Rbend", ""
        .Point "Lq", "-Rbend", ""
        .Create
    End With
    With Curve
        .Fillet "ArmBot", 2, 3, "Rbend"
    End With

    ' Output feed extensions to ports (50 Ohm straight stubs)
    With Curve
        .Reset
        .Name "OutTop"
        .Curve "polyline"
        .Point "Lq", "Rbend", ""
        .Point "Lq + FeedExt", "Rbend", ""
        .Create
    End With

    With Curve
        .Reset
        .Name "OutBot"
        .Curve "polyline"
        .Point "Lq", "-Rbend", ""
        .Point "Lq + FeedExt", "-Rbend", ""
        .Create
    End With

    ' ---------------- Create copper by sweeping widths ----------------
    ' Feed 50 Ohm
    With Sweep
        .Reset
        .Name "S_Feed50"
        .SetCurve "Feed50"
        .SectionRectangle "W50", "tCu", "center"
        .Material "Copper"
        .Orientation "z"
        .AnchorPoint "0", "0", "zTop"
        .Create
    End With

    ' Short T section at node (keep W50 to the split)
    With Sweep
        .Reset
        .Name "S_Tnode"
        .SetCurve "Tnode"
        .SectionRectangle "W50", "tCu", "center"
        .Material "Copper"
        .Orientation "z"
        .AnchorPoint "0", "0", "zTop"
        .Create
    End With

    ' 70.7 Ohm branches
    With Sweep
        .Reset
        .Name "S_ArmTop"
        .SetCurve "ArmTop"
        .SectionRectangle "W70", "tCu", "center"
        .Material "Copper"
        .Orientation "z"
        .AnchorPoint "0", "0", "zTop"
        .Create
    End With

    With Sweep
        .Reset
        .Name "S_ArmBot"
        .SetCurve "ArmBot"
        .SectionRectangle "W70", "tCu", "center"
        .Material "Copper"
        .Orientation "z"
        .AnchorPoint "0", "0", "zTop"
        .Create
    End With

    ' Output 50 Ohm stubs
    With Sweep
        .Reset
        .Name "S_OutTop"
        .SetCurve "OutTop"
        .SectionRectangle "W50", "tCu", "center"
        .Material "Copper"
        .Orientation "z"
        .AnchorPoint "0", "0", "zTop"
        .Create
    End With

    With Sweep
        .Reset
        .Name "S_OutBot"
        .SetCurve "OutBot"
        .SectionRectangle "W50", "tCu", "center"
        .Material "Copper"
        .Orientation "z"
        .AnchorPoint "0", "0", "zTop"
        .Create
    End With

    ' ---------------- Output pads and resistor pads ----------------
    ' Top output pad
    With Brick
        .Reset
        .Name "PadTop"
        .Component "Signal"
        .Material "Copper"
        .Xrange "Lq + FeedExt - PadL", "Lq + FeedExt"
        .Yrange "Rbend - PadW/2", "Rbend + PadW/2"
        .Zrange "h", "h + tCu"
        .Create
    End With

    ' Bottom output pad
    With Brick
        .Reset
        .Name "PadBot"
        .Component "Signal"
        .Material "Copper"
        .Xrange "Lq + FeedExt - PadL", "Lq + FeedExt"
        .Yrange "-Rbend - PadW/2", "-Rbend + PadW/2"
        .Zrange "h", "h + tCu"
        .Create
    End With

    ' Resistor pads facing each other with a small gap
    With Brick
        .Reset
        .Name "ResPadTop"
        .Component "Signal"
        .Material "Copper"
        .Xrange "Lq - PadL", "Lq"
        .Yrange "Rbend - PadW/2", "Rbend + PadW/2"
        .Zrange "h", "h + tCu"
        .Create
    End With

    With Brick
        .Reset
        .Name "ResPadBot"
        .Component "Signal"
        .Material "Copper"
        .Xrange "Lq - PadL", "Lq"
        .Yrange "-Rbend - PadW/2", "-Rbend + PadW/2"
        .Zrange "h", "h + tCu"
        .Create
    End With

    ' Create the isolation resistor as discrete lumped element
    With DiscretePort
        .Reset
        .Label "Riso"
        .Number 10
        .SetConnection "signal", "Signal:ResPadTop", "signal", "Signal:ResPadBot"
        .PortType "Impedance"
        .Impedance "Riso"
        .Add
    End With

    ' ---------------- Ports ----------------
    ' Waveguide ports on the three edges
    ' Port 1 (input)
    With Port
        .Reset
        .PortNumber 1
        .Type "Waveguide"
        .Coordinates "-FeedExt-0.6e-3", "-W50/2", "h", "-FeedExt-0.6e-3", "W50/2", "h + tCu"
        .Orientation "x"
        .Add
    End With

    ' For ports 2 and 3, use discrete ports from pads to ground (or waveguide). We'll choose waveguide to compare S-params easily

    ' Port 2 (top)
    With Port
        .Reset
        .PortNumber 2
        .Type "Waveguide"
        .Coordinates "Lq + FeedExt", "Rbend - W50/2", "h", "Lq + FeedExt", "Rbend + W50/2", "h + tCu"
        .Orientation "x"
        .Add
    End With

    ' Port 3 (bottom)
    With Port
        .Reset
        .PortNumber 3
        .Type "Waveguide"
        .Coordinates "Lq + FeedExt", "-Rbend - W50/2", "h", "Lq + FeedExt", "-Rbend + W50/2", "h + tCu"
        .Orientation "x"
        .Add
    End With

    ' ---------------- Simulation Settings ----------------
    With Solver
        .Reset
        .FrequencyRange "18", "22"
        .Accuracy "-40"
        .Stimulation "Port"
        .SolverType "T"
        .Start
    End With

    ' Plot S-Parameters afterwards
    With ASCIIExport
        .Reset
        .FileName "Sparams_Wilkinson_20GHz.txt"
        .Mode "SParameter"
        .Execute
    End With

    MsgBox "Wilkinson 20 GHz model created. Set mesh and run simulation if not started."
End Sub
