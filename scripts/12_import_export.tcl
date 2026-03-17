# =============================================================
# Script  : 12_import_export.tcl
# Purpose : HyperMesh Import/Export - HM file, OptiStruct FEM
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/12_import_export.tcl}
# Note    : *templatefileset and *feoutputwithdata require GUI mode
#           Parts 1-2 (writefile/readfile) work in both GUI and batch
# =============================================================

puts "=============================="
puts " Import and Export"
puts "=============================="

set proj_dir "C:/Users/13378/.qclaw/workspace"
set tpl_dir  "C:/a/Altair/2023/hwdesktop/templates"
set os_tpl   "$tpl_dir/feoutput/optistruct/optistruct"


# ============================================================
# Part 1: Build a simple model
# ============================================================
puts ""
puts "--- 1. Build Test Model ---"

*collectorcreate comps Shell_Part {}
*currentcollector comps Shell_Part

*createnode 0   0   0 0 0 0
*createnode 100 0   0 0 0 0
*createnode 100 100 0 0 0 0
*createnode 0   100 0 0 0 0

set nids [hm_entitylist nodes id]
*createlist nodes 1 [lindex $nids 0] [lindex $nids 1] [lindex $nids 2] [lindex $nids 3]
*createelement 104 1 1 1

puts "  Model: [llength [hm_entitylist nodes id]] nodes, [llength [hm_entitylist elems id]] elems"


# ============================================================
# Part 2: Save and read HM file (works in batch and GUI)
# ============================================================
puts ""
puts "--- 2. Save and Read HM File ---"

set hm_path "$proj_dir/export_test.hm"

# Save model
*writefile $hm_path 1
puts "  Saved: $hm_path ([file size $hm_path] bytes)"

# Read back
*readfile $hm_path 0 0 0
puts "  Read back: [llength [hm_entitylist nodes id]] nodes, [llength [hm_entitylist elems id]] elems"


# ============================================================
# Part 3: Export to solver format (GUI mode only)
# ============================================================
puts ""
puts "--- 3. Export to Solver Format (GUI only) ---"

# *templatefileset and *feoutputwithdata require GUI mode
# Use the following commands inside HyperMesh GUI:
puts "  Run these commands in HyperMesh GUI:"
puts "  ---"
puts "  set tpl_dir \[hm_info -appinfo SPECIFIEDPATH TEMPLATES_DIR\]"
puts "  set os_tpl \[file join \$tpl_dir feoutput optistruct optistruct\]"
puts "  *templatefileset \$os_tpl"
puts "  *feoutputwithdata \$os_tpl output.fem 0 0 1 1 0"
puts "  ---"


# ============================================================
# Part 4: Import from solver file (GUI mode only)
# ============================================================
puts ""
puts "--- 4. Import from Solver File (GUI only) ---"

puts "  Run these commands in HyperMesh GUI:"
puts "  ---"
puts "  *feinputwithdata2 \$os_tpl input.fem 0 0 0 0 0 0 0"
puts "  ---"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. hm_info -appinfo SPECIFIEDPATH TEMPLATES_DIR -> get template dir
# 2. *writefile <path> 1                  -> save as HM file (batch OK)
# 3. *readfile <path> 0 0 0               -> read HM file (batch OK)
# 4. *templatefileset <tpl_path>          -> load template (GUI only)
# 5. *feoutputwithdata <tpl> <out> 0 0 1 1 0 -> export (GUI only)
# 6. *feinputwithdata2 <tpl> <in> 0 0 0 0 0 0 0 -> import (GUI only)
# Pitfall: *templatefileset and *feoutputwithdata crash in batch mode
#          Only *writefile and *readfile work in both modes
# =============================================================
