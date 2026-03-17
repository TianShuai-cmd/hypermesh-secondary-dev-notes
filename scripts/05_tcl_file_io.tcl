# =============================================================
# Script  : 05_tcl_file_io.tcl
# Purpose : TCL File I/O - read, write, append, file operations
# Date    : 2026-03-17
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {<your_path>/HyperMesh-Dev/scripts/05_tcl_file_io.tcl}
# =============================================================

puts "=============================="
puts " TCL File I/O"
puts "=============================="

# Define working directory for test files
set work_dir [file dirname [info script]]
set test_dir "$work_dir/../projects"


# ============================================================
# Part 1: Write a file
# ============================================================
puts ""
puts "--- 1. Write File ---"

# open syntax: open <path> <mode>
# Modes: w=write(overwrite), r=read, a=append
set fpath "$test_dir/test_output.txt"
set fid [open $fpath w]

# puts to file handle instead of stdout
puts $fid "HyperMesh File I/O Test"
puts $fid "Created by TCL script"
puts $fid "Line 3: some data"

close $fid
puts "  Written to: $fpath"


# ============================================================
# Part 2: Read entire file at once
# ============================================================
puts ""
puts "--- 2. Read Entire File ---"

set fid [open $fpath r]
set content [read $fid]   ;# read entire file into string
close $fid

puts "  File content:"
puts $content


# ============================================================
# Part 3: Read file line by line
# ============================================================
puts ""
puts "--- 3. Read Line by Line ---"

set fid [open $fpath r]
set line_num 0

# gets returns number of chars read, -1 at EOF
while {[gets $fid line] >= 0} {
    incr line_num
    puts "  Line $line_num: $line"
}
close $fid


# ============================================================
# Part 4: Append to file
# ============================================================
puts ""
puts "--- 4. Append to File ---"

# mode "a" appends without overwriting
set fid [open $fpath a]
puts $fid "Line 4: appended line"
puts $fid "Line 5: another appended line"
close $fid

# Verify append
set fid [open $fpath r]
set lines [split [read $fid] "\n"]
close $fid
puts "  Total lines after append: [llength $lines]"


# ============================================================
# Part 5: File and directory operations
# ============================================================
puts ""
puts "--- 5. File Operations ---"

# Check if file exists
if {[file exists $fpath]} {
    puts "  File exists: $fpath"
}

# Check if it is a file or directory
puts "  Is file      : [file isfile $fpath]"
puts "  Is directory : [file isdirectory $fpath]"

# Get file size in bytes
puts "  File size    : [file size $fpath] bytes"

# Get file name and directory from path
puts "  File name    : [file tail $fpath]"
puts "  Directory    : [file dirname $fpath]"

# Get file extension
puts "  Extension    : [file extension $fpath]"

# Rename file
set new_path "$test_dir/test_output_renamed.txt"
file rename $fpath $new_path
puts "  Renamed to   : [file tail $new_path]"

# Delete file
file delete $new_path
puts "  File deleted"


# ============================================================
# Part 6: Practical example - Write node coords to CSV
# ============================================================
puts ""
puts "--- 6. Practical: Export Node Coords to CSV ---"

# Get all nodes from current model
set node_ids [hm_entitylist nodes id]
set csv_path "$test_dir/node_coords.csv"

set fid [open $csv_path w]
puts $fid "ID,X,Y,Z"   ;# CSV header

foreach nid $node_ids {
    set x [hm_getvalue node id=$nid dataname=x]
    set y [hm_getvalue node id=$nid dataname=y]
    set z [hm_getvalue node id=$nid dataname=z]
    puts $fid "$nid,$x,$y,$z"
}
close $fid

puts "  Exported [llength $node_ids] nodes to: $csv_path"


# ============================================================
# Part 7: Practical example - Import node coords from CSV
# ============================================================
puts ""
puts "--- 7. Practical: Import Nodes from CSV ---"

# Create a sample CSV first
set import_csv "$test_dir/import_nodes.csv"
set fid [open $import_csv w]
puts $fid "ID,X,Y,Z"
puts $fid "1,0,0,0"
puts $fid "2,200,0,0"
puts $fid "3,200,200,0"
puts $fid "4,0,200,0"
puts $fid "5,100,100,50"
close $fid

# Read CSV and create nodes
set fid [open $import_csv r]
gets $fid   ;# skip header line

set count 0
while {[gets $fid line] >= 0} {
    if {[string trim $line] eq ""} { continue }   ;# skip empty lines
    set parts [split $line ","]
    set x [lindex $parts 1]
    set y [lindex $parts 2]
    set z [lindex $parts 3]
    if {[catch {*createnode $x $y $z 0 0 0} err]} {
        puts "  Failed at line: $line"
    } else {
        incr count
    }
}
close $fid

puts "  Imported $count nodes from CSV"
puts "  Total nodes in model: [llength [hm_entitylist nodes id]]"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. open <path> w/r/a    -> open file (write/read/append)
# 2. close $fid           -> always close after use
# 3. puts $fid "text"     -> write line to file
# 4. read $fid            -> read entire file as string
# 5. gets $fid line       -> read one line, returns char count (-1=EOF)
# 6. split $str ","       -> split string by delimiter
# 7. file exists/isfile/isdirectory/size/tail/dirname/extension
# 8. file rename/delete   -> file management
# Tip: use [file dirname [info script]] to get script directory
# =============================================================
