# =============================================================
# Script  : 14_python_basics.py
# Purpose : Python + HyperMesh integration via hmbatch
# Date    : 2026-03-17
# Version : Python 3.x + HyperMesh 2023
# Usage   : python 14_python_basics.py
# =============================================================

"""
HyperMesh Python Integration - Basics

This script demonstrates how to:
1. Run TCL scripts via hmbatch.exe
2. Pass parameters from Python to TCL
3. Read results back from HyperMesh

HyperMesh doesn't have built-in Python, so we use subprocess to
call hmbatch.exe which runs TCL scripts in batch mode.
"""

import subprocess
import os
import tempfile

# Configuration
HMBATCH_PATH = r"C:\a\Altair\2023\hwdesktop\hm\bin\win64\hmbatch.exe"
SCRIPT_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\scripts"
OUTPUT_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\projects"


def run_hm_script(tcl_code, timeout=30):
    """
    Run TCL code in HyperMesh batch mode.
    
    Args:
        tcl_code: TCL commands to execute
        timeout:  timeout in seconds
    
    Returns:
        stdout: command output
        returncode: exit code
    """
    # Write TCL code to temp file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.tcl', delete=False, encoding='utf-8') as f:
        f.write(tcl_code)
        f.write("\nexit\n")  # Exit after running
        tcl_file = f.name
    
    try:
        # Run hmbatch
        result = subprocess.run(
            [HMBATCH_PATH, "-tcl", tcl_file],
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding='utf-8',
            errors='replace'
        )
        return result.stdout, result.stderr, result.returncode
    except subprocess.TimeoutExpired:
        return "", "Timeout", -1
    except Exception as e:
        return "", str(e), -1
    finally:
        # Clean up temp file
        if os.path.exists(tcl_file):
            os.remove(tcl_file)


def example_01_get_model_info():
    """Example 1: Get model information"""
    print("=" * 50)
    print("Example 1: Get Model Info")
    print("=" * 50)
    
    tcl_code = """
puts "--- Model Info ---"
puts "Nodes: [llength [hm_entitylist nodes id]]"
puts "Elems: [llength [hm_entitylist elems id]]"
puts "Comps: [llength [hm_entitylist comps id]]"
puts "Done."
"""
    
    stdout, stderr, code = run_hm_script(tcl_code)
    print(stdout)
    if stderr:
        print(f"Stderr: {stderr}")
    print(f"Return code: {code}\n")


def example_02_create_nodes():
    """Example 2: Create nodes from Python"""
    print("=" * 50)
    print("Example 2: Create Nodes")
    print("=" * 50)
    
    # Define node positions in Python
    nodes = [
        (0, 0, 0),
        (10, 0, 0),
        (10, 10, 0),
        (0, 10, 0),
    ]
    
    # Build TCL code
    tcl_code = "*collectorcreate comps Python_Test {}\n*currentcollector comps Python_Test\n"
    for i, (x, y, z) in enumerate(nodes, 1):
        tcl_code += f"*createnode {x} {y} {z} 0 0 0\n"
    tcl_code += 'puts "Created [llength [hm_entitylist nodes id]] nodes"\n'
    
    stdout, stderr, code = run_hm_script(tcl_code)
    print(stdout)
    print(f"Return code: {code}\n")


def example_03_create_elements():
    """Example 3: Create elements from Python"""
    print("=" * 50)
    print("Example 3: Create Elements")
    print("=" * 50)
    
    tcl_code = """
*collectorcreate comps Quad_Test {}
*currentcollector comps Quad_Test

*createnode 0 0 0 0 0 0
*createnode 10 0 0 0 0 0
*createnode 10 10 0 0 0 0
*createnode 0 10 0 0 0 0

set nids [hm_entitylist nodes id]
*createlist nodes 1 {*}$nids
*createelement 104 1 1 1

puts "Created [llength [hm_entitylist elems id]] quad element"
"""
    
    stdout, stderr, code = run_hm_script(tcl_code)
    print(stdout)
    print(f"Return code: {code}\n")


def example_04_read_hm_file():
    """Example 4: Read existing HM file"""
    print("=" * 50)
    print("Example 4: Read HM File")
    print("=" * 50)
    
    # Use forward slashes for cross-platform compatibility
    hm_file = (OUTPUT_DIR + "/export_test.hm").replace("\\", "/")
    
    if not os.path.exists(hm_file):
        print(f"File not found: {hm_file}")
        print("Run script 12 first to create it.\n")
        return
    
    tcl_code = f"""
*readfile "{hm_file}" 0 0 0
puts "Loaded HM file:"
puts "  Nodes: [llength [hm_entitylist nodes id]]"
puts "  Elems: [llength [hm_entitylist elems id]]"
puts "  Comps: [llength [hm_entitylist comps id]]"
"""
    
    stdout, stderr, code = run_hm_script(tcl_code)
    print(stdout)
    print(f"Return code: {code}\n")


def example_05_pass_parameters():
    """Example 5: Pass parameters from Python to TCL"""
    print("=" * 50)
    print("Example 5: Pass Parameters")
    print("=" * 50)
    
    # Python variables
    plate_width = 100
    plate_height = 50
    mesh_size = 10
    comp_name = f"Plate_{plate_width}x{plate_height}"
    
    tcl_code = f"""
# Parameters passed from Python
set width {plate_width}
set height {plate_height}
set size {mesh_size}

puts "Received parameters:"
puts "  Width: $width"
puts "  Height: $height"  
puts "  Mesh size: $size"

# Create a parameterized plate
*collectorcreate comps {comp_name} {{}}
*currentcollector comps {comp_name}

*createnode 0 0 0 0 0 0
*createnode $width 0 0 0 0 0
*createnode $width $height 0 0 0 0
*createnode 0 $height 0 0 0 0

set nids [hm_entitylist nodes id]
*createlist nodes 1 {{*}}$nids
*createelement 104 1 1 1

puts "Created plate: $width x $height with mesh size $size"
"""
    
    stdout, stderr, code = run_hm_script(tcl_code)
    print(stdout)
    print(f"Return code: {code}\n")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print(" HyperMesh Python Integration - Basics")
    print("=" * 60 + "\n")
    
    # Check hmbatch exists
    if not os.path.exists(HMBATCH_PATH):
        print(f"ERROR: hmbatch.exe not found at: {HMBATCH_PATH}")
        print("Please check your HyperMesh installation path.")
        exit(1)
    
    print(f"Using hmbatch: {HMBATCH_PATH}\n")
    
    # Run examples
    example_01_get_model_info()
    example_02_create_nodes()
    example_03_create_elements()
    example_04_read_hm_file()
    example_05_pass_parameters()
    
    print("=" * 60)
    print(" All examples completed!")
    print("=" * 60)
