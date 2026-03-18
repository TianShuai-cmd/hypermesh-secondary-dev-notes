# =============================================================
# Script  : 10_mesh_2d.tcl
# Purpose : HyperMesh 2D Mesh - create surface and manual mesh
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/10_mesh_2d.tcl}
# =============================================================

*deletemodel

puts "=============================="
puts " HyperMesh 2D Mesh"
puts "=============================="


# ============================================================
# Part 1: Create component and nodes
# ============================================================
puts ""
puts "--- 1. Create Nodes ---"

*collectorcreate comps Mesh_Test {}
*currentcollector comps Mesh_Test

# Create 4 corner nodes of a 100x100 square
*createnode 0   0   0 0 0 0
*createnode 100 0   0 0 0 0
*createnode 100 100 0 0 0 0
*createnode 0   100 0 0 0 0

set nids [hm_entitylist nodes id]
puts "  Created [llength $nids] boundary nodes: $nids"


# ============================================================
# Part 2: Create surface from node loop
# ============================================================
puts ""
puts "--- 2. Create Surface ---"

# Create surface from 4 corner nodes
set n1 [lindex $nids 0]
set n2 [lindex $nids 1]
set n3 [lindex $nids 2]
set n4 [lindex $nids 3]

*createlist nodes 1 $n1 $n2 $n3 $n4
*surfacesplineonnodesloop 1 0 0

set surfs [hm_entitylist surfs id]
puts "  Created surface: $surfs"


# ============================================================
# Part 3: Manual mesh - create quad elements
# ============================================================
puts ""
puts "--- 3. Manual Mesh ---"

# Get fresh node list after surface creation
set node_list [hm_entitylist nodes id]
puts "  Current nodes: $node_list"

# Need at least 4 nodes for a single quad, or create more for mesh
if {[llength $node_list] >= 4} {
    set n1 [lindex $node_list 0]
    set n2 [lindex $node_list 1]
    set n3 [lindex $node_list 2]
    set n4 [lindex $node_list 3]
    
    # Create one quad element using first 4 nodes
    *createlist nodes 1 $n1 $n2 $n3 $n4
    *createelement 104 1 1 1
    
    puts "  Created 1 quad element"
}

set elem_count [llength [hm_entitylist elems id]]
set node_count [llength [hm_entitylist nodes id]]
puts "  Total nodes: $node_count"
puts "  Total elems: $elem_count"


# ============================================================
# Part 4: Mesh quality check
# ============================================================
puts ""
puts "--- 4. Mesh Quality ---"

if {$elem_count > 0} {
    *createmark elems 2 "all"
    set asp [hm_getelemcheckvalues 2 2 aspect]
    set skw [hm_getelemcheckvalues 2 2 skew]
    puts "  Aspect ratio: $asp"
    puts "  Skew: $skw"
}


puts ""
puts "=============================="
puts " Done."
puts "=============================="
