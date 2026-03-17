# =============================================================
# Script  : 08_components.tcl
# Purpose : HyperMesh Component Operations - create, query, rename, delete
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/08_components.tcl}
# =============================================================

puts "=============================="
puts " HyperMesh Component Operations"
puts "=============================="


# ============================================================
# Part 1: Create components
# ============================================================
puts ""
puts "--- 1. Create Components ---"

# *collectorcreate syntax: *collectorcreate comps <name> {}
*collectorcreate comps Shell_Top {}
*collectorcreate comps Shell_Bottom {}
*collectorcreate comps Rib_Left {}
*collectorcreate comps Rib_Right {}

set comp_ids [hm_entitylist comps id]
puts "  Created [llength $comp_ids] components"


# ============================================================
# Part 2: Query component properties
# ============================================================
puts ""
puts "--- 2. Query Components ---"

foreach cid $comp_ids {
    set cname [hm_getvalue comp id=$cid dataname=name]
    puts "  ID=$cid  Name=$cname"
}

# Get component ID by name
set cid [hm_getvalue comp name=Shell_Top dataname=id]
puts "  Shell_Top ID: $cid"


# ============================================================
# Part 3: Set current component and create nodes in it
# ============================================================
puts ""
puts "--- 3. Set Current Component ---"

# *currentcollector: set the active component for new entities
*currentcollector comps Shell_Top
puts "  Current collector set to: Shell_Top"

# Nodes created now belong to Shell_Top
*createnode 0   0   0 0 0 0
*createnode 100 0   0 0 0 0
*createnode 100 100 0 0 0 0
*createnode 0   100 0 0 0 0
puts "  Created 4 nodes in Shell_Top"


# ============================================================
# Part 4: Rename component
# ============================================================
puts ""
puts "--- 4. Rename Component ---"

# *renamecollector syntax: *renamecollector comps <old_name> <new_name>
set old_name "Rib_Left"
set new_name "Rib_Left_Renamed"
*renamecollector comps $old_name $new_name
puts "  Renamed: $old_name -> $new_name"

# Verify
set comp_ids [hm_entitylist comps id]
foreach cid $comp_ids {
    set cname [hm_getvalue comp id=$cid dataname=name]
    puts "  ID=$cid  Name=$cname"
}


# ============================================================
# Part 5: Move elements between components
# ============================================================
puts ""
puts "--- 5. Move Entities Between Components ---"

# Create elements in Shell_Top
*currentcollector comps Shell_Top
set nids [hm_entitylist nodes id]
set n1 [lindex $nids 0]
set n2 [lindex $nids 1]
set n3 [lindex $nids 2]
set n4 [lindex $nids 3]
*createlist nodes 1 $n1 $n2 $n3 $n4
*createelement 104 1 1 1
set eid [lindex [hm_entitylist elems id] 0]
puts "  Created elem $eid in Shell_Top"

# Move element to Shell_Bottom using *movemark
*createmark elems 1 $eid
set target_id [hm_getvalue comp name=Shell_Bottom dataname=id]
*movemark elems 1 comps $target_id
puts "  Moved elem $eid to Shell_Bottom"


# ============================================================
# Part 6: Delete component
# ============================================================
puts ""
puts "--- 6. Delete Component ---"

set before [llength [hm_entitylist comps id]]

# Mark and delete Rib_Right
*createmark comps 1 [hm_getvalue comp name=Rib_Right dataname=id]
*deletemark comps 1

set after [llength [hm_entitylist comps id]]
puts "  Deleted Rib_Right. Count: $before -> $after"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *collectorcreate comps name {}      -> create component
# 2. *currentcollector comps name        -> set active component
# 3. hm_getvalue comp id=N dataname=name -> get component name
# 4. hm_getvalue comp name=X dataname=id -> get component ID by name
# 5. *renamecollector comps old new      -> rename component
# 6. *collectormarkmove elems 1 comps id -> NOT valid for elements
#    Use *movemark elems 1 comps id instead
# 7. *createmark comps 1 <id>            -> mark component
# 8. *deletemark comps 1                 -> delete marked component
# =============================================================
