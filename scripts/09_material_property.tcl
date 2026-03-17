# =============================================================
# Script  : 09_material_property.tcl
# Purpose : HyperMesh Material & Property - create, set values, assign
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/09_material_property.tcl}
# Note    : Requires OptiStruct template (loaded automatically)
# =============================================================

puts "=============================="
puts " Material and Property"
puts "=============================="

# Load OptiStruct template (required for MAT1/PSHELL card images)
set tpl_path "C:/a/Altair/2023/hwdesktop/templates/feoutput/optistruct/optistruct"
*templatefileset $tpl_path
puts "  Template loaded: optistruct"


# ============================================================
# Part 1: Create material (MAT1 - isotropic)
# ============================================================
puts ""
puts "--- 1. Create Material (MAT1) ---"

# *createentity mats cardimage=MAT1 name=<name>
*createentity mats cardimage=MAT1 name=Steel
set mid [hm_getvalue mats name=Steel dataname=id]
puts "  Created material: Steel (ID=$mid)"

# Set material properties using numeric field index
# MAT1 fields: 1=E, 2=G, 3=NU, 4=RHO, 5=A, 6=TREF, 7=GE
# STATUS=1 means the field is active
*setvalue mats id=$mid STATUS=1 1=210000.0   ;# E (Young's modulus)
*setvalue mats id=$mid STATUS=1 3=0.3        ;# NU (Poisson's ratio)
*setvalue mats id=$mid STATUS=1 4=7.85e-9    ;# RHO (density)
puts "  Set E=210000, NU=0.3, RHO=7.85e-9"

# Verify E value only (NU dataname not supported in hm_getvalue for mats)
set E  [hm_getvalue mats id=$mid dataname=E]
puts "  Verified: E=$E"


# ============================================================
# Part 2: Create property (PSHELL - shell element property)
# ============================================================
puts ""
puts "--- 2. Create Property (PSHELL) ---"

*createentity props cardimage=PSHELL name=Shell_2mm
set pid [hm_getvalue props name=Shell_2mm dataname=id]
puts "  Created property: Shell_2mm (ID=$pid)"

# PSHELL fields: 1=MID1, 3=T (thickness), 5=MID2, 7=MID3
*setvalue props id=$pid STATUS=1 3=2.0       ;# T (thickness = 2mm)
*setvalue props id=$pid STATUS=1 1=$mid      ;# MID1 (material reference)
puts "  Set T=2.0, MID1=$mid"


# ============================================================
# Part 3: Assign property to component
# ============================================================
puts ""
puts "--- 3. Assign Property to Component ---"

*collectorcreate comps Shell_Part {}
set cid [hm_getvalue comp name=Shell_Part dataname=id]

# Assign property: set propertyid field of component
*setvalue comps id=$cid propertyid={props $pid}
puts "  Assigned Shell_2mm to Shell_Part"

# Verify
set assigned_pid [hm_getvalue comp id=$cid dataname=propertyid]
puts "  Verified property ID: $assigned_pid"


# ============================================================
# Part 4: Create multiple materials and properties
# ============================================================
puts ""
puts "--- 4. Multiple Materials ---"

*createentity mats cardimage=MAT1 name=Aluminum
set mid2 [hm_getvalue mats name=Aluminum dataname=id]
*setvalue mats id=$mid2 STATUS=1 1=70000.0
*setvalue mats id=$mid2 STATUS=1 3=0.33
puts "  Created Aluminum (ID=$mid2): E=70000, NU=0.33"

# List all materials
set mat_ids [hm_entitylist mats id]
puts "  Total materials: [llength $mat_ids]"
foreach matid $mat_ids {
    set mname [hm_getvalue mats id=$matid dataname=name]
    puts "    ID=$matid  Name=$mname"
}


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *templatefileset <path>               -> load solver template
# 2. *createentity mats cardimage=MAT1 name=X -> create material
# 3. *setvalue mats id=N STATUS=1 1=<E>    -> set E (field index 1)
# 4. *setvalue mats id=N STATUS=1 3=<NU>   -> set NU (field index 3)
# 5. *setvalue mats id=N STATUS=1 4=<RHO>  -> set RHO (field index 4)
# 6. *createentity props cardimage=PSHELL name=X -> create property
# 7. *setvalue props id=N STATUS=1 3=<T>   -> set thickness
# 8. *setvalue props id=N STATUS=1 1=<mid> -> set material reference
# 9. *setvalue comps id=N propertyid={props pid} -> assign prop to comp
# MAT1 field index: 1=E 2=G 3=NU 4=RHO 5=A 6=TREF 7=GE
# PSHELL field index: 1=MID1 3=T 5=MID2 7=MID3
# Pitfall: *setvalue uses numeric field index, NOT attribute name
#          e.g. *setvalue mats id=1 STATUS=1 1=210000 (not E=210000)
# Pitfall: template must be loaded before creating MAT/PROP entities
# =============================================================
