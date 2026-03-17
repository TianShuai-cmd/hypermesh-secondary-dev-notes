# =============================================================
# Script  : 06_nodes.tcl
# Purpose : HyperMesh Node Operations - create, query, move, delete
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/06_nodes.tcl}
# =============================================================

puts "=============================="
puts " HyperMesh Node Operations"
puts "=============================="


# ============================================================
# Part 1: Create nodes
# ============================================================
puts ""
puts "--- 1. Create Nodes ---"

# *createnode syntax: x y z system_id output_id config_id
# system_id=0: global coordinate system
*createnode 0.0   0.0   0.0  0 0 0
*createnode 100.0 0.0   0.0  0 0 0
*createnode 100.0 100.0 0.0  0 0 0
*createnode 0.0   100.0 0.0  0 0 0
*createnode 50.0  50.0  50.0 0 0 0

set all_ids [hm_entitylist nodes id]
puts "  Created 5 nodes. Total: [llength $all_ids]"


# ============================================================
# Part 2: Query node properties
# ============================================================
puts ""
puts "--- 2. Query Node Properties ---"

# hm_getvalue: read a single attribute of an entity
foreach nid $all_ids {
    set x [hm_getvalue node id=$nid dataname=x]
    set y [hm_getvalue node id=$nid dataname=y]
    set z [hm_getvalue node id=$nid dataname=z]
    puts "  Node $nid : ($x, $y, $z)"
}


# ============================================================
# Part 3: Mark nodes (selection mechanism)
# ============================================================
puts ""
puts "--- 3. Mark Nodes ---"

# *createmark: mark entities into a mark set (1 or 2)
# Mark set is like a selection buffer

# Mark all nodes
*createmark nodes 1 "all"
set cnt [llength [hm_getmark nodes 1]]
puts "  Marked all nodes: $cnt"

# Clear mark
*clearmark nodes 1

# Mark specific nodes by ID
*createmark nodes 1 1 2 3
set marked [hm_getmark nodes 1]
puts "  Marked nodes 1,2,3: $marked"

# Mark nodes by ID range
*clearmark nodes 1
*createmark nodes 1 "by id" 1 3   ;# mark IDs 1 to 3
puts "  Marked by range 1-3: [hm_getmark nodes 1]"


# ============================================================
# Part 4: Move nodes (workaround: delete + recreate)
# ============================================================
puts ""
puts "--- 4. Move Nodes ---"

# HyperMesh 2023 TCL has no direct move command for free nodes
# Workaround: read coords, delete node, recreate at new position
# Note: *deleteidrange is the correct delete command (not *deletemark)
set x_before [hm_getvalue node id=5 dataname=x]
set y_before [hm_getvalue node id=5 dataname=y]
set z_before [hm_getvalue node id=5 dataname=z]
puts "  Node 5 before: ($x_before, $y_before, $z_before)"

*clearmark nodes 1
*createmark nodes 1 5
set check [hm_getmark nodes 1]
puts "  Marked for delete: $check"

if {[llength $check] > 0} {
    *deleteidrange nodes 1
    set new_z [expr {$z_before + 10.0}]
    *createnode $x_before $y_before $new_z 0 0 0
    set all_ids [hm_entitylist nodes id]
    set new_id  [lindex $all_ids end]
    set z_after [hm_getvalue node id=$new_id dataname=z]
    puts "  Node $new_id after : ($x_before, $y_before, $z_after)"
} else {
    puts "  Node 5 not found, skipping"
}


# ============================================================
# Part 5: Find nodes by coordinate (proximity search)
# ============================================================
puts ""
puts "--- 5. Find Nodes by Proximity ---"

# Find nodes within a radius of a point
# *createmark nodes 1 "by sphere" cx cy cz radius
*clearmark nodes 1
*createmark nodes 1 "by sphere" 0.0 0.0 0.0 10.0
set near_nodes [hm_getmark nodes 1]
puts "  Nodes within radius 10 of origin: $near_nodes"


# ============================================================
# Part 6: Merge duplicate nodes
# ============================================================
puts ""
puts "--- 6. Merge Duplicate Nodes ---"

# Create a duplicate node to test merge
*createnode 0.0 0.0 0.0 0 0 0
set before_count [llength [hm_entitylist nodes id]]
puts "  Nodes before merge: $before_count"

# *equivalence nodes: merge nodes within tolerance
# syntax: *equivalence nodes <mark_id> <tolerance>
*createmark nodes 1 "all"
*equivalence nodes 1 0.01

set after_count [llength [hm_entitylist nodes id]]
puts "  Nodes after merge : $after_count"
puts "  Merged: [expr {$before_count - $after_count}] duplicate(s)"


# ============================================================
# Part 7: Delete nodes
# ============================================================
puts ""
puts "--- 7. Delete Nodes ---"

set before [llength [hm_entitylist nodes id]]

# *deleteidrange: correct delete command in HyperMesh 2023
# Mark first, then delete
*clearmark nodes 1
*createmark nodes 1 4
*deleteidrange nodes 1

set after [llength [hm_entitylist nodes id]]
puts "  Deleted node 4. Count: $before -> $after"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *createnode x y z 0 0 0               -> create node at (x,y,z)
# 2. hm_getvalue node id=N dataname=x      -> get node coordinate
# 3. *createmark nodes 1 "all"             -> mark all nodes
# 4. *createmark nodes 1 1 2 3             -> mark by ID list
# 5. *createmark nodes 1 "by id" 1 3       -> mark by ID range
# 6. *createmark nodes 1 "by sphere" cx cy cz r -> mark by proximity
# 7. hm_getmark nodes 1                    -> get list of marked node IDs
# 8. *clearmark nodes 1                    -> clear mark set
# 9. *deleteidrange nodes 1                -> delete marked nodes (CORRECT)
# 10.*equivalence nodes 1 tolerance        -> merge duplicate nodes (CORRECT)
# 11.*collectorcreate comps name {}        -> create component
# 12.*currentcollector comps name          -> set current component
# Pitfall: *deletemark/*modent_deletebymark -> use *deleteidrange instead
# Pitfall: *nodesmove does NOT exist       -> move = delete + recreate
# Pitfall: *mergenodes does NOT exist      -> use *equivalence nodes 1 tol
# Pitfall: *createentity syntax error      -> use *collectorcreate instead
# =============================================================
