# =============================================================
# Script  : 11_mesh_quality.tcl
# Purpose : HyperMesh Mesh Quality Check - aspect, skew, jacobian, warpage
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/11_mesh_quality.tcl}
# =============================================================

puts "=============================="
puts " Mesh Quality Check"
puts "=============================="


# ============================================================
# Part 1: Setup - create a mesh to check
# ============================================================
puts ""
puts "--- 1. Setup: Create Test Mesh ---"

*collectorcreate comps Part1 {}
*currentcollector comps Part1

# Create a good quad element (square)
*createnode 0   0   0 0 0 0
*createnode 10  0   0 0 0 0
*createnode 10  10  0 0 0 0
*createnode 0   10  0 0 0 0

# Create a distorted quad element (poor quality)
*createnode 20  0   0 0 0 0
*createnode 35  0   0 0 0 0
*createnode 32  10  0 0 0 0
*createnode 21  8   0 0 0 0

set nids [hm_entitylist nodes id]
set n1 [lindex $nids 0]; set n2 [lindex $nids 1]
set n3 [lindex $nids 2]; set n4 [lindex $nids 3]
set n5 [lindex $nids 4]; set n6 [lindex $nids 5]
set n7 [lindex $nids 6]; set n8 [lindex $nids 7]

*createlist nodes 1 $n1 $n2 $n3 $n4
*createelement 104 1 1 1

*createlist nodes 1 $n5 $n6 $n7 $n8
*createelement 104 1 1 1

set elem_ids [hm_entitylist elems id]
puts "  Created [llength $elem_ids] elements (1 good, 1 distorted)"


# ============================================================
# Part 2: Individual element quality checks
# ============================================================
puts ""
puts "--- 2. Quality Checks ---"

# hm_getelemcheckvalues syntax:
# hm_getelemcheckvalues <mark_id> <dimension> <check_name>
# Returns: elem_id value elem_id value ...
# dimension: 2=2D, 3=3D

*createmark elems 2 "all"

# Aspect ratio (ideal=1.0, threshold typically <5)
set asp [hm_getelemcheckvalues 2 2 aspect]
puts "  Aspect ratio  : $asp"

# Skew angle in degrees (ideal=0, threshold typically <60)
set skw [hm_getelemcheckvalues 2 2 skew]
puts "  Skew          : $skw"

# Warpage (ideal=0, threshold typically <15 degrees)
set wrp [hm_getelemcheckvalues 2 2 warpage]
puts "  Warpage       : $wrp"

# Jacobian (ideal=1.0, threshold typically >0.6)
set jac [hm_getelemcheckvalues 2 2 jacobian]
puts "  Jacobian      : $jac"

# Taper (ideal=0, threshold typically <0.5)
set tap [hm_getelemcheckvalues 2 2 taper]
puts "  Taper         : $tap"


# ============================================================
# Part 3: Parse quality results and flag bad elements
# ============================================================
puts ""
puts "--- 3. Flag Bad Elements ---"

# Parse aspect ratio results (format: id1 val1 id2 val2 ...)
set asp_threshold 3.0
set bad_elems {}

foreach {eid val} $asp {
    if {$val > $asp_threshold} {
        lappend bad_elems $eid
        puts "  WARN: Elem $eid aspect=$val (threshold=$asp_threshold)"
    } else {
        puts "  OK  : Elem $eid aspect=$val"
    }
}

if {[llength $bad_elems] == 0} {
    puts "  All elements pass aspect ratio check"
} else {
    puts "  [llength $bad_elems] element(s) failed: $bad_elems"
}


# ============================================================
# Part 4: Write quality report to file
# ============================================================
puts ""
puts "--- 4. Write Quality Report ---"

set report_path "[file dirname [info script]]/../projects/quality_report.txt"
set fid [open $report_path w]
puts $fid "Mesh Quality Report"
puts $fid "Generated: [clock format [clock seconds]]"
puts $fid "=========================="
puts $fid "Total elements: [llength $elem_ids]"
puts $fid ""
puts $fid "Aspect Ratio:"
foreach {eid val} $asp {
    set status [expr {$val > $asp_threshold ? "FAIL" : "PASS"}]
    puts $fid "  Elem $eid : $val ($status)"
}
puts $fid ""
puts $fid "Skew:"
foreach {eid val} $skw {
    set status [expr {$val > 60 ? "FAIL" : "PASS"}]
    puts $fid "  Elem $eid : $val ($status)"
}
close $fid
puts "  Report saved: $report_path"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. *createmark elems 2 "all"              -> mark all elems to set 2
# 2. hm_getelemcheckvalues 2 2 aspect       -> aspect ratio check
# 3. hm_getelemcheckvalues 2 2 skew         -> skew angle check
# 4. hm_getelemcheckvalues 2 2 warpage      -> warpage check
# 5. hm_getelemcheckvalues 2 2 jacobian     -> jacobian check
# 6. hm_getelemcheckvalues 2 2 taper        -> taper check
# Returns: "id1 val1 id2 val2 ..." string - use foreach {id val} to parse
# Quality thresholds (typical):
#   aspect < 5    skew < 60    warpage < 15
#   jacobian > 0.6   taper < 0.5
# =============================================================
