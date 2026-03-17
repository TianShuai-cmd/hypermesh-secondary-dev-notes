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
│   ├── 05_tcl_file_io.tcl
│   ├── 06_nodes.tcl
│   ├── 07_elements.tcl
│   ├── 08_components.tcl
│   ├── 09_material_property.tcl
│   ├── 10_mesh_2d.tcl
│   ├── 11_mesh_quality.tcl
│   ├── 12_import_export.tcl
│   ├── 13_mark_filter.tcl
│   └── comments/                 # Chinese notes for each script
│       ├── 01~13 *_notes.md
└── projects/                     # Practical projects (coming soon)
```

## Progress

| Script | Topic | Status | Date | Mode |
|--------|-------|--------|------|------|
| 01_hello_hypermesh.tcl | Model info & create nodes | ✅ | 2026-03-16 | GUI |
| 02_tcl_basics.tcl | Variables, list, string, dict, math | ✅ | 2026-03-16 | GUI |
| 03_tcl_control_flow.tcl | if/switch/for/foreach/while/break | ✅ | 2026-03-16 | GUI |
| 04_tcl_proc.tcl | proc, args, scope, catch/error | ✅ | 2026-03-16 | GUI |
| 05_tcl_file_io.tcl | File read/write/append | ✅ | 2026-03-17 | GUI |
| 06_nodes.tcl | Node operations | ✅ | 2026-03-17 | GUI |
| 07_elements.tcl | Element create/query/delete | ✅ | 2026-03-17 | Batch |
| 08_components.tcl | Component operations | ✅ | 2026-03-17 | Batch |
| 09_material_property.tcl | Material & property | ✅ | 2026-03-17 | Batch |
| 10_mesh_2d.tcl | 2D auto mesh | ✅ | 2026-03-17 | GUI only |
| 11_mesh_quality.tcl | Mesh quality check | ✅ | 2026-03-17 | Batch |
| 12_import_export.tcl | HM file save/read, FEM export | ✅ | 2026-03-17 | Mixed |
| 13_mark_filter.tcl | Mark & filter advanced | ✅ | 2026-03-17 | Batch |
| 14_python_basics.py | Python hm module | ⬜ | | |
| 15_python_csv_import.py | CSV data import | ⬜ | | |
| 16_python_export_report.py | Export report | ⬜ | | |
| 17_python_gui.py | Tkinter GUI | ⬜ | | |
| 18_quality_report.tcl | Project: quality report | ⬜ | | |
| 19_parametric_plate.tcl | Project: parametric modeling | ⬜ | | |
| 20_model_info_tool.py | Project: model info tool | ⬜ | | |

## Key Pitfalls (HyperMesh 2023 TCL 8.5.9)

| Wrong | Correct |
|-------|---------|
| `hm_entityinfo count nodes 0` | `llength [hm_entitylist nodes id]` |
| `puts "[ title ]"` | `puts "--- title ---"` |
| Chinese comments in scripts | English only (GBK/UTF-8 encoding issue) |
| `*deletemark nodes 1` | `*deleteidrange nodes 1` |
| `*deleteidrange elems 1` | `*deletemark elems 1` |
| `*mergenodes 1 0.01` | `*equivalence nodes 1 0.01` |
| `*nodesmove` (not exist) | delete + recreate at new position |
| `*createentity comps name="x"` | `*collectorcreate comps name {}` |
| `*setcurrentcollector` (not exist) | `*currentcollector comps name` |
| `*createelement 104 1 n1 n2 n3 n4` | `*createlist nodes 1 n1...; *createelement 104 1 1 1` |
| `*collectormarkmove elems 1 comps id` | `*movemark elems 1 comps id` |
| `*setvalue mats id=1 E=210000` | `*setvalue mats id=1 STATUS=1 1=210000` |
| `*markdifference nodes 1 2` | `*markdifference nodes 1 nodes 2` |
| `*markunion` (not exist) | append to same mark set with `*createmark` |

## Batch vs GUI Commands

| Command | Batch | GUI |
|---------|-------|-----|
| `*writefile` / `*readfile` | ✅ | ✅ |
| `*createnode` / `*createelement` | ✅ | ✅ |
| `*collectorcreate` / `*currentcollector` | ✅ | ✅ |
| `*templatefileset` | ❌ | ✅ |
| `*feoutputwithdata` | ❌ | ✅ |
| `*automesh` | ❌ | ✅ |
| `hm_info -appinfo SPECIFIEDPATH` | ❌ | ✅ |

## How to Run

Open HyperMesh 2023 Command Window and type:
```tcl
source {<your_path>/HyperMesh-Dev/scripts/01_hello_hypermesh.tcl}
```

Replace `<your_path>` with the actual folder path on your machine.

## Study Plan

Full 14-week plan: see `docs/Learning-Plan.md`
