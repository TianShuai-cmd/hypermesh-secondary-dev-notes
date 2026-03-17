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
# Part 4: Move nodes
# ============================================================
puts ""
puts "--- 4. Move Nodes ---"

# Check position of node 5 before move
set x_before [hm_getvalue node id=5 dataname=x]
set y_before [hm_getvalue node id=5 dataname=y]
set z_before [hm_getvalue node id=5 dataname=z]
puts "  Node 5 before: ($x_before, $y_before, $z_before)"

# *nodesmove syntax: mark_id system_id dx dy dz
# Moves all nodes in mark set by (dx, dy, dz)
*createmark nodes 1 5
*nodesmove 1 0 0.0 0.0 10.0   ;# move node 5 by dz=10

set x_after [hm_getvalue node id=5 dataname=x]
set y_after [hm_getvalue node id=5 dataname=y]
set z_after [hm_getvalue node id=5 dataname=z]
puts "  Node 5 after : ($x_after, $y_after, $z_after)"


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

# Create two overlapping nodes to test merge
*createnode 0.0 0.0 0.0 0 0 0   ;# duplicate of node 1
set before_count [llength [hm_entitylist nodes id]]
puts "  Nodes before merge: $before_count"

# *mergenodes: merge nodes in mark set within tolerance
*createmark nodes 1 "all"
*mergenodes 1 0.01   ;# tolerance = 0.01

set after_count [llength [hm_entitylist nodes id]]
puts "  Nodes after merge : $after_count"
puts "  Merged: [expr {$before_count - $after_count}] duplicate(s)"


# ============================================================
# Part 7: Delete nodes
# ============================================================
puts ""
puts "--- 7. Delete Nodes ---"

set before [llength [hm_entitylist nodes id]]

# Mark node 5 and delete it
*createmark nodes 1 5
*deletemark nodes 1

set after [llength [hm_entitylist nodes id]]
puts "  Deleted node 5. Count: $before -> $after"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *createnode x y z 0 0 0          -> create node at (x,y,z)
# 2. hm_getvalue node id=N dataname=x -> get node coordinate
# 3. *createmark nodes 1 "all"        -> mark all nodes
# 4. *createmark nodes 1 1 2 3        -> mark by ID list
# 5. *createmark nodes 1 "by id" 1 3  -> mark by ID range
# 6. *createmark nodes 1 "by sphere" cx cy cz r -> mark by proximity
# 7. hm_getmark nodes 1               -> get list of marked node IDs
# 8. *clearmark nodes 1               -> clear mark set
# 9. *nodesmove 1 0 dx dy dz          -> move marked nodes
# 10.*mergenodes 1 tolerance          -> merge duplicate nodes
# 11.*deletemark nodes 1              -> delete marked nodes
# =============================================================
