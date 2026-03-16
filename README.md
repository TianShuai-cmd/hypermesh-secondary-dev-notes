# HyperMesh Secondary Development Learning Notes

> HyperMesh 2023 TCL/Python secondary development learning documentation.
> Environment: HyperMesh 2023 / TCL 8.5.9 / Python 3.9

## Structure

```
HyperMesh-Dev/
├── docs/
│   ├── HyperMesh-Dev-Notes.md    # Learning notes
│   └── Learning-Plan.md          # Full 14-week study plan
├── scripts/
│   ├── 01_hello_hypermesh.tcl
│   ├── 02_tcl_basics.tcl
│   ├── 03_tcl_control_flow.tcl
│   ├── 04_tcl_proc.tcl
│   └── comments/                 # Chinese notes for each script
│       ├── 01_hello_hypermesh_notes.md
│       ├── 02_tcl_basics_notes.md
│       ├── 03_tcl_control_flow_notes.md
│       └── 04_tcl_proc_notes.md
└── projects/                     # Practical projects (coming soon)
```

## Progress

| Script | Topic | Status | Date |
|--------|-------|--------|------|
| 01_hello_hypermesh.tcl | Model info & create nodes | ✅ | 2026-03-16 |
| 02_tcl_basics.tcl | Variables, list, string, dict, math | ✅ | 2026-03-16 |
| 03_tcl_control_flow.tcl | if/switch/for/foreach/while/break | ✅ | 2026-03-16 |
| 04_tcl_proc.tcl | proc, args, scope, catch/error | ✅ | 2026-03-16 |
| 05_tcl_file_io.tcl | File read/write | ⬜ | |
| 06_nodes.tcl | Node operations | ⬜ | |
| 07_elements.tcl | Element operations | ⬜ | |
| 08_components.tcl | Component operations | ⬜ | |
| 09_material_property.tcl | Material & property | ⬜ | |
| 10_mesh_2d.tcl | 2D mesh | ⬜ | |
| 11_mesh_quality.tcl | Mesh quality check | ⬜ | |
| 12_import_export.tcl | Import / export | ⬜ | |
| 13_mark_filter.tcl | Mark & filter | ⬜ | |
| 14_python_basics.py | Python hm module | ⬜ | |
| 15_python_csv_import.py | CSV data import | ⬜ | |
| 16_python_export_report.py | Export report | ⬜ | |
| 17_python_gui.py | Tkinter GUI | ⬜ | |
| 18_quality_report.tcl | Project: quality report | ⬜ | |
| 19_parametric_plate.tcl | Project: parametric modeling | ⬜ | |
| 20_model_info_tool.py | Project: model info tool | ⬜ | |

## Key Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `hm_entityinfo count nodes 0` error | Invalid syntax in TCL 8.5.9 | Use `llength [hm_entitylist nodes id]` |
| `puts "[ title ]"` error | `[]` is command substitution in TCL | Use `puts "--- title ---"` |
| Chinese comments break proc parsing | HyperMesh reads UTF-8 files as GBK | English comments only in script files |
| Stale proc on re-source | Old proc definition stays in memory | Use `rename proc {}` at script top |

## How to Run

Open HyperMesh 2023 Command Window and type:
```tcl
source {C:/Users/13378/Desktop/HyperMesh-Dev/scripts/01_hello_hypermesh.tcl}
```

## Study Plan

Full 14-week plan: see `docs/Learning-Plan.md`
