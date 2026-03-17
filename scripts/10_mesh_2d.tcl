# =============================================================
# Script  : 10_mesh_2d.tcl
# Purpose : HyperMesh 2D Mesh - create surface and auto mesh
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/10_mesh_2d.tcl}
# Note    : *automesh requires GUI mode - run in HyperMesh, not hmbatch
# =============================================================

puts "=============================="
puts " HyperMesh 2D Mesh"
puts "=============================="


# ============================================================
# Part 1: Create a surface from nodes
# ============================================================
puts ""
puts "--- 1. Create Surface ---"

*collectorcreate comps Shell_Part {}
*currentcollector comps Shell_Part

# Create boundary nodes for a 200x100 rectangle
*createnode 0   0   0 0 0 0
*createnode 200 0   0 0 0 0
*createnode 200 100 0 0 0 0
*createnode 0   100 0 0 0 0

set nids [hm_entitylist nodes id]
puts "  Created [llength $nids] boundary nodes"

# Create surface using spline through nodes
# *surfacesplineonnodesloop: creates surface from closed node loop
*createlist nodes 1 [lindex $nids 0] [lindex $nids 1] [lindex $nids 2] [lindex $nids 3]
*surfacesplineonnodesloop 1 0 0

set surf_ids [hm_entitylist surfs id]
puts "  Created [llength $surf_ids] surface(s)"


# ============================================================
# Part 2: Auto mesh the surface
# ============================================================
puts ""
puts "--- 2. Auto Mesh ---"

# *automesh syntax: *automesh <surf_mark_id> <mesh_size> <mesh_type>
# mesh_type: 1=mixed, 2=quads only, 3=trias only
# Must run in GUI mode (not hmbatch)

*createmark surfs 1 "all"
set surf_count [llength [hm_getmark surfs 1]]
puts "  Surfaces to mesh: $surf_count"
puts "  Mesh size: 10"
puts "  Mesh type: 1 (mixed quad/tria)"

# Execute automesh
*automesh 1 10 1

set elem_count [llength [hm_entitylist elems id]]
set node_count [llength [hm_entitylist nodes id]]
puts "  After mesh: $elem_count elements, $node_count nodes"


# ============================================================
# Part 3: Check mesh quality after meshing
# ============================================================
puts ""
puts "--- 3. Mesh Quality ---"

*createmark elems 2 "all"
set asp [hm_getelemcheckvalues 2 2 aspect]
puts "  Aspect ratio results (id value ...): $asp"

set skw [hm_getelemcheckvalues 2 2 skew]
puts "  Skew results (id value ...): $skw"


# ============================================================
# Part 4: Mesh size control
# ============================================================
puts ""
puts "--- 4. Mesh with Different Size ---"

# Delete existing mesh first
*createmark elems 1 "all"
*deletemark elems 1

# Re-mesh with finer size
*createmark surfs 1 "all"
*automesh 1 5 2   ;# size=5, quads only

set elem_count2 [llength [hm_entitylist elems id]]
puts "  After fine mesh (size=5): $elem_count2 elements"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *surfacesplineonnodesloop 1 0 0  -> create surface from node loop
# 2. *createmark surfs 1 "all"        -> mark all surfaces
# 3. *automesh 1 <size> <type>        -> auto mesh marked surfaces
#    type: 1=mixed  2=quads  3=trias
# 4. hm_getelemcheckvalues 2 2 aspect -> quality check (mark2, 2D)
# 5. *deletemark elems 1              -> delete all elements
# Pitfall: *automesh requires GUI mode, will crash in hmbatch
#          Always run mesh scripts inside HyperMesh GUI
# =============================================================
