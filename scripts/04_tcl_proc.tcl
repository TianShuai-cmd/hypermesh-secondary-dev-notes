# =============================================================
# Script  : 04_tcl_proc.tcl
# Purpose : TCL Proc - definition, parameters, scope, error handling
# Date    : 2026-03-16
# Version : HyperMesh 2023 (TCL 8.5.9)
# Usage   : source {C:/Users/13378/Desktop/HyperMesh-Dev/scripts/04_tcl_proc.tcl}
# =============================================================

# Clear all procs defined in this script to avoid stale definitions on re-source
foreach p {greet add create_node sum_all log_msg scope_test double_value
           safe_divide get_model_stats safe_create_node batch_create_nodes} {
    catch {rename $p {}}
}

puts "=============================="
puts " TCL Proc (Functions)"
puts "=============================="


# ============================================================
# Part 1: Basic proc definition and call
# ============================================================
puts ""
puts "--- 1. Basic Proc ---"

# proc syntax: proc name {param_list} {body}
proc greet {name} {
    puts "  Hello, $name!"
}

greet "HyperMesh"
greet "Engineer"

# proc with return value
proc add {a b} {
    return [expr {$a + $b}]
}

set result [add 10 20]
puts "  10 + 20 = $result"


# ============================================================
# Part 2: Default parameters
# ============================================================
puts ""
puts "--- 2. Default Parameters ---"

# Use {param default} to set default value
# Params with defaults must come last in the list
proc create_node {x y {z 0.0}} {
    puts "  Creating node at ($x, $y, $z)"
}

create_node 100 200
create_node 100 200 50.0


# ============================================================
# Part 3: Variable arguments (args)
# ============================================================
puts ""
puts "--- 3. Variable Arguments (args) ---"

# args receives all remaining arguments as a list
proc sum_all {args} {
    set total 0
    foreach n $args {
        set total [expr {$total + $n}]
    }
    return $total
}

puts "  sum(1,2,3)       = [sum_all 1 2 3]"
puts "  sum(10,20,30,40) = [sum_all 10 20 30 40]"

# Mix fixed and variable params
proc log_msg {level args} {
    set msg [join $args " "]
    puts "  \[$level\] $msg"
}

log_msg "INFO"  "Model loaded successfully"
log_msg "WARN"  "Node count is" 0 "check your model"
log_msg "ERROR" "File not found:" "model.hm"


# ============================================================
# Part 4: Variable scope
# ============================================================
puts ""
puts "--- 4. Variable Scope ---"

set global_var "I am global"

proc scope_test {} {
    set local_var "I am local"
    puts "  Inside proc: local_var = $local_var"
    global global_var
    puts "  Inside proc: global_var = $global_var"
    set global_var "Modified by proc"
}

scope_test
puts "  Outside proc: global_var = $global_var"

# upvar: pass variable by reference
proc double_value {varName} {
    upvar 1 $varName local
    set local [expr {$local * 2}]
}

set myNum 5
double_value myNum
puts "  After double_value: myNum = $myNum"


# ============================================================
# Part 5: Error handling (catch / error)
# ============================================================
puts ""
puts "--- 5. Error Handling ---"

proc safe_divide {a b} {
    if {$b == 0} {
        error "Division by zero: cannot divide $a by 0"
    }
    return [expr {$a / double($b)}]
}

if {[catch {safe_divide 10 2} result]} {
    puts "  Error: $result"
} else {
    puts "  10 / 2 = $result"
}

if {[catch {safe_divide 10 0} err]} {
    puts "  Caught error: $err"
}

if {[catch {expr {1 / 0}} err]} {
    puts "  TCL error caught: $err"
}


# ============================================================
# Part 6: Practical example - HyperMesh utility procs
# ============================================================
puts ""
puts "--- 6. Practical Example: HyperMesh Utility Procs ---"

proc get_model_stats {} {
    set nc [llength [hm_entitylist nodes id]]
    set ec [llength [hm_entitylist elems id]]
    set cc [llength [hm_entitylist comps id]]
    return [dict create nodes $nc elems $ec comps $cc]
}

proc safe_create_node {x y z} {
    if {[catch {*createnode $x $y $z 0 0 0} err]} {
        puts "  Failed to create node at ($x,$y,$z): $err"
        return 0
    }
    return 1
}

proc batch_create_nodes {coords} {
    set count 0
    set clist $coords
    foreach {x y z} $clist {
        if {[safe_create_node $x $y $z]} {
            incr count
        }
    }
    puts "  batch_create_nodes: created $count nodes"
    return $count
}

set stats [get_model_stats]
puts "  Model stats:"
puts "    nodes = [dict get $stats nodes]"
puts "    elems = [dict get $stats elems]"
puts "    comps = [dict get $stats comps]"

set cdata {0 0 0  50 0 0  100 0 0  0 50 0  50 50 0}
batch_create_nodes $cdata

set stats_after [get_model_stats]
puts "  Nodes after batch create: [dict get $stats_after nodes]"


puts ""
puts "=============================="
puts " Done."
puts "=============================="

# =============================================================
# Summary:
# 1. proc name {args} {body}  -> define a procedure
# 2. {param default}          -> default parameter value
# 3. args                     -> variable arguments as list
# 4. global varName           -> access global variable inside proc
# 5. upvar 1 varName local    -> pass variable by reference
# 6. catch {cmd} errVar       -> catch errors (0=ok, 1=error)
# 7. error "message"          -> throw an error
# Pitfall: Chinese comments cause encoding issues in HyperMesh TCL
#          Always use English comments in scripts
# =============================================================
