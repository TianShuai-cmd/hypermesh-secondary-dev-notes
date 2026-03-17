# =============================================================
# Script  : 07_elements.tcl
# Purpose : HyperMesh Element Operations - create, query, delete
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/07_elements.tcl}
# Note    : Run on a clean model (no existing nodes/elements)
# =============================================================

puts "=============================="
puts " HyperMesh Element Operations"
puts "=============================="


# ============================================================
# Part 1: Setup - create a component and nodes
# ============================================================
puts ""
puts "--- 1. Setup: Component + Nodes ---"

# Create a component to hold elements
*collectorcreate comps Shell_Part {}
*currentcollector comps Shell_Part

# Create 6 nodes for elements
*createnode 0.0   0.0   0.0  0 0 0
*createnode 100.0 0.0   0.0  0 0 0
*createnode 100.0 100.0 0.0  0 0 0
*createnode 0.0   100.0 0.0  0 0 0
*createnode 200.0 0.0   0.0  0 0 0
*createnode 200.0 100.0 0.0  0 0 0

set node_ids [hm_entitylist nodes id]
puts "  Component: Shell_Part"
puts "  Nodes created: [llength $node_ids]"


# ============================================================
# Part 2: Create elements
# ============================================================
puts ""
puts "--- 2. Create Elements ---"

# Correct way to create elements in HyperMesh 2023:
# Step 1: load node IDs into list via *createlist nodes 1
# Step 2: call *createelement <config> 1 1 1
# Config: 104=quad4  103=tria3  (verified in HyperMesh 2023)

set n1 [lindex $node_ids 0]
set n2 [lindex $node_ids 1]
set n3 [lindex $node_ids 2]
set n4 [lindex $node_ids 3]
set n5 [lindex $node_ids 4]
set n6 [lindex $node_ids 5]

# Create quad4 element
*createlist nodes 1 $n1 $n2 $n3 $n4
*createelement 104 1 1 1
puts "  Created quad4 (nodes: $n1 $n2 $n3 $n4)"

# Create tria3 element
*createlist nodes 1 $n2 $n5 $n6
*createelement 103 1 1 1
puts "  Created tria3 (nodes: $n2 $n5 $n6)"

# Create another tria3
*createlist nodes 1 $n2 $n6 $n3
*createelement 103 1 1 1
puts "  Created tria3 (nodes: $n2 $n6 $n3)"

set elem_ids [hm_entitylist elems id]
puts "  Total elements: [llength $elem_ids]"


# ============================================================
# Part 3: Query element properties
# ============================================================
puts ""
puts "--- 3. Query Element Properties ---"

foreach eid $elem_ids {
    set cfg    [hm_getvalue elem id=$eid dataname=config]
    set enodes [hm_getvalue elem id=$eid dataname=nodes]
    puts "  Elem $eid : config=$cfg  nodes=$enodes"
}

# Get element size
set eid1 [lindex $elem_ids 0]
set size [hm_getelementsize $eid1]
puts "  Elem $eid1 size: $size"


# ============================================================
# Part 4: Mark elements
# ============================================================
puts ""
puts "--- 4. Mark Elements ---"

# Mark all elements
*createmark elems 1 "all"
puts "  Marked all: [llength [hm_getmark elems 1]]"
*clearmark elems 1

# Mark by ID
*createmark elems 1 [lindex $elem_ids 0]
puts "  Marked elem [lindex $elem_ids 0]: [hm_getmark elems 1]"
*clearmark elems 1

# Mark by config type (104=quad4)
*createmark elems 1 "by config" 104
puts "  Marked quad4: [hm_getmark elems 1]"
*clearmark elems 1


# ============================================================
# Part 5: Element quality check
# ============================================================
puts ""
puts "--- 5. Element Quality Check ---"

# hm_getelemcheckvalues syntax: hm_getelemcheckvalues <mark_id> <dimension> <check>
# dimension: 2=2D elements, 3=3D elements
# Returns: elem_id value pairs
*createmark elems 2 "all"
set asp_result [hm_getelemcheckvalues 2 2 aspect]
puts "  Aspect ratio (id value pairs): $asp_result"

set skw_result [hm_getelemcheckvalues 2 2 skew]
puts "  Skew (id value pairs)        : $skw_result"


# ============================================================
# Part 6: Delete elements
# ============================================================
puts ""
puts "--- 6. Delete Elements ---"

set before [llength [hm_entitylist elems id]]

# For elements: *deletemark elems 1 works (unlike nodes)
set last_eid [lindex $elem_ids end]
*clearmark elems 1
*createmark elems 1 $last_eid
*deletemark elems 1

set after [llength [hm_entitylist elems id]]
puts "  Deleted elem $last_eid. Count: $before -> $after"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *collectorcreate comps name {}       -> create component
# 2. *currentcollector comps name         -> set active component
# 3. *createlist nodes 1 n1 n2 n3 n4     -> load nodes into list
#    *createelement 104 1 1 1             -> create quad4 from list
#    *createelement 103 1 1 1             -> create tria3 from list
# 4. hm_getvalue elem id=N dataname=config -> get element type number
# 5. hm_getvalue elem id=N dataname=nodes  -> get connected node IDs
# 6. hm_getelementsize <eid>              -> get element size
# 7. *createmark elems 1 "by config" 104  -> mark by element type
# 8. hm_getelemcheckvalues 2 2 aspect     -> quality check (mark2, 2D)
# 9. *deletemark elems 1                  -> delete marked elements
# Config numbers (HyperMesh 2023 verified):
#   103=tria3  104=quad4
# Pitfall: *createelement does NOT take node IDs as direct arguments
#          Must use *createlist nodes 1 <ids> first
# Pitfall: *deleteidrange works for nodes but NOT for elements
#          Use *deletemark elems 1 for elements
# Pitfall: hm_getelemcheckvalues uses mark set 2 (not 1) by convention
#          syntax: hm_getelemcheckvalues <mark_id> <dimension> <check>
# =============================================================
