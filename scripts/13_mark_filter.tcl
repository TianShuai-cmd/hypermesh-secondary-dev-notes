# =============================================================
# Script  : 13_mark_filter.tcl
# Purpose : HyperMesh Mark & Filter - advanced entity selection
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/13_mark_filter.tcl}
# =============================================================

puts "=============================="
puts " Mark and Filter"
puts "=============================="


# ============================================================
# Part 1: Setup test model
# ============================================================
puts ""
puts "--- 1. Setup Test Model ---"

*collectorcreate comps Comp_A {}
*collectorcreate comps Comp_B {}
*currentcollector comps Comp_A

*createnode 0   0   0 0 0 0
*createnode 10  0   0 0 0 0
*createnode 10  10  0 0 0 0
*createnode 0   10  0 0 0 0
*createnode 20  0   0 0 0 0
*createnode 30  0   0 0 0 0
*createnode 30  10  0 0 0 0
*createnode 20  10  0 0 0 0

set nids [hm_entitylist nodes id]
set n1 [lindex $nids 0]; set n2 [lindex $nids 1]
set n3 [lindex $nids 2]; set n4 [lindex $nids 3]
set n5 [lindex $nids 4]; set n6 [lindex $nids 5]
set n7 [lindex $nids 6]; set n8 [lindex $nids 7]

*createlist nodes 1 $n1 $n2 $n3 $n4
*createelement 104 1 1 1

*createlist nodes 1 $n5 $n6 $n7 $n8
*createelement 104 1 1 1

*currentcollector comps Comp_B
*createnode 40  0   0 0 0 0
*createnode 50  0   0 0 0 0
*createnode 50  10  0 0 0 0
*createnode 40  10  0 0 0 0
set nids2 [hm_entitylist nodes id]
set n9  [lindex $nids2 8]; set n10 [lindex $nids2 9]
set n11 [lindex $nids2 10]; set n12 [lindex $nids2 11]
*createlist nodes 1 $n9 $n10 $n11 $n12
*createelement 104 1 1 1

puts "  Nodes: [llength [hm_entitylist nodes id]]"
puts "  Elems: [llength [hm_entitylist elems id]]"
puts "  Comps: [llength [hm_entitylist comps id]]"


# ============================================================
# Part 2: Basic mark operations
# ============================================================
puts ""
puts "--- 2. Basic Mark Operations ---"

# Mark all nodes
*createmark nodes 1 "all"
puts "  All nodes: [llength [hm_getmark nodes 1]]"
*clearmark nodes 1

# Mark by ID list
*createmark nodes 1 1 2 3 4
puts "  Nodes 1-4: [hm_getmark nodes 1]"
*clearmark nodes 1

# Mark by ID range
*createmark nodes 1 "by id" 1 4
puts "  Nodes by range 1-4: [hm_getmark nodes 1]"
*clearmark nodes 1

# Mark by sphere (proximity)
*createmark nodes 1 "by sphere" 5.0 5.0 0.0 8.0
puts "  Nodes near (5,5,0) r=8: [hm_getmark nodes 1]"
*clearmark nodes 1


# ============================================================
# Part 3: Mark elements by various criteria
# ============================================================
puts ""
puts "--- 3. Mark Elements by Criteria ---"

# Mark all elements
*createmark elems 1 "all"
puts "  All elems: [hm_getmark elems 1]"
*clearmark elems 1

# Mark by config type
*createmark elems 1 "by config" 104
puts "  Quad4 elems: [hm_getmark elems 1]"
*clearmark elems 1

# Mark elements by component
set cid_a [hm_getvalue comp name=Comp_A dataname=id]
*createmark elems 1 "by collector" $cid_a
puts "  Elems in Comp_A: [hm_getmark elems 1]"
*clearmark elems 1


# ============================================================
# Part 4: Mark nodes connected to elements
# ============================================================
puts ""
puts "--- 4. Mark Connected Entities ---"

# Mark elements first, then get their nodes
*createmark elems 1 1
set eid_nodes [hm_getvalue elem id=1 dataname=nodes]
puts "  Elem 1 nodes: $eid_nodes"

# Mark nodes attached to marked elements
*createmark elems 1 "all"
*createmark nodes 1 "by elems" 1
puts "  Nodes attached to all elems: [llength [hm_getmark nodes 1]]"
*clearmark nodes 1
*clearmark elems 1


# ============================================================
# Part 5: Boolean mark operations (add/subtract)
# ============================================================
puts ""
puts "--- 5. Boolean Mark Operations ---"

# Mark set 1: nodes 1-4
*createmark nodes 1 1 2 3 4
puts "  Mark1 (nodes 1-4): [hm_getmark nodes 1]"

# Mark set 2: nodes 3-6
*createmark nodes 2 3 4 5 6
puts "  Mark2 (nodes 3-6): [hm_getmark nodes 2]"

# Subtract mark2 from mark1 (mark1 - mark2)
# *markdifference syntax: *markdifference <type> <mark1> <type> <mark2>
*markdifference nodes 1 nodes 2
puts "  Mark1 - Mark2: [hm_getmark nodes 1]"

*clearmark nodes 1
*clearmark nodes 2

# Union: simply mark both sets into mark1 (append)
# *markunion does not exist - use two *createmark calls to same mark set
*createmark nodes 1 1 2 3
*createmark nodes 1 4 5 6   ;# appends to existing mark1
puts "  Mark1 union (1-6): [hm_getmark nodes 1]"
*clearmark nodes 1


# ============================================================
# Part 6: Practical - filter elements by quality
# ============================================================
puts ""
puts "--- 6. Filter Elements by Quality ---"

*createmark elems 2 "all"
set asp_results [hm_getelemcheckvalues 2 2 aspect]

set bad_ids {}
foreach {eid val} $asp_results {
    if {$val > 2.0} {
        lappend bad_ids $eid
    }
}

if {[llength $bad_ids] > 0} {
    puts "  Elements with aspect > 2.0: $bad_ids"
    # Mark bad elements for review
    eval *createmark elems 1 $bad_ids
    puts "  Marked [llength [hm_getmark elems 1]] bad elements"
} else {
    puts "  All elements pass aspect ratio check (threshold=2.0)"
}
*clearmark elems 1
*clearmark elems 2


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *createmark nodes 1 "all"              -> mark all nodes
# 2. *createmark nodes 1 1 2 3             -> mark by ID
# 3. *createmark nodes 1 "by id" 1 4       -> mark by ID range
# 4. *createmark nodes 1 "by sphere" x y z r -> mark by proximity
# 5. *createmark elems 1 "by config" 104   -> mark by element type
# 6. *createmark elems 1 "by collector" id -> mark by component
# 7. *createmark nodes 1 "by elems" 1      -> mark nodes of marked elems
# 8. *markdifference nodes 1 2             -> mark1 = mark1 - mark2
# 9. *markunion nodes 1 2                  -> mark1 = mark1 + mark2
# 10.hm_getmark nodes 1                   -> get marked ID list
# 11.*clearmark nodes 1                   -> clear mark set
# =============================================================
