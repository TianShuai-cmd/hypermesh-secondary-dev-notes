# =============================================================
# Script  : 15_python_csv_import.py
# Purpose : Import CSV data and create geometry in HyperMesh
# Date    : 2026-03-17
# Version : Python 3.x + HyperMesh 2023
# Usage   : python 15_python_csv_import.py
# =============================================================

"""
CSV Import - Read coordinate data from CSV and create nodes/elements

CSV format:
x,y,z
0,0,0
10,0,0
10,10,0
"""

import csv
import os
import subprocess
import tempfile

HMBATCH_PATH = r"C:\a\Altair\2023\hwdesktop\hm\bin\win64\hmbatch.exe"
SCRIPT_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\scripts"
OUTPUT_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\projects"
DATA_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\projects"


def create_sample_csv():
    """Create a sample CSV file for testing"""
    csv_path = os.path.join(DATA_DIR, "coordinates.csv")
    
    data = [
        ["x", "y", "z"],
        ["0", "0", "0"],
        ["100", "0", "0"],
        ["100", "50", "0"],
        ["0", "50", "0"],
        ["50", "25", "0"],  # center point
    ]
    
    with open(csv_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(data)
    
    print(f"Created sample CSV: {csv_path}")
    return csv_path


def run_hm_tcl(tcl_code, timeout=30):
    """Run TCL in hmbatch"""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.tcl', delete=False, encoding='utf-8') as f:
        f.write(tcl_code)
        f.write("\nexit\n")
        tcl_file = f.name
    
    try:
        result = subprocess.run(
            [HMBATCH_PATH, "-tcl", tcl_file],
            capture_output=True, text=True, timeout=timeout,
            encoding='utf-8', errors='replace'
        )
        return result.stdout, result.stderr, result.returncode
    finally:
        if os.path.exists(tcl_file):
            os.remove(tcl_file)


def import_csv_to_nodes(csv_path, comp_name="CSV_Import"):
    """Import CSV file and create nodes in HyperMesh"""
    
    # Read CSV
    coords = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            coords.append((float(row['x']), float(row['y']), float(row['z'])))
    
    print(f"Read {len(coords)} coordinates from CSV")
    
    # Build TCL - each *createnode call needs separate x y z
    # Note: # *deletemodel (skip - prompts in batch) prompts in batch, so we skip it and just create new
    tcl_code = f"""
*collectorcreate comps {comp_name}_new {{}}
*currentcollector comps {comp_name}_new

puts "Creating {len(coords)} nodes..."
"""
    
    for x, y, z in coords:
        tcl_code += f"*createnode {x} {y} {z} 0 0 0\n"
    
    tcl_code += f"""
set node_count [llength [hm_entitylist nodes id]]
puts "Created $node_count nodes from CSV"
puts "Node IDs: [hm_entitylist nodes id]"
"""
    
    stdout, stderr, code = run_hm_tcl(tcl_code)
    print(stdout)
    if stderr:
        print(f"Stderr: {stderr}")
    
    return code == 0


def import_csv_to_quads(csv_path, comp_name="CSV_Quad"):
    """Import CSV as quad mesh (4 corner points)"""
    
    coords = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            coords.append((float(row['x']), float(row['y']), float(row['z'])))
    
    if len(coords) < 4:
        print("Need at least 4 points for quad")
        return False
    
    # Use first 4 points as quad corners
    n1, n2, n3, n4 = coords[:4]
    
    tcl_code = f"""
# *deletemodel (skip - prompts in batch)
*collectorcreate comps {comp_name} {{}}
*currentcollector comps {comp_name}

*createnode {n1[0]} {n1[1]} {n1[2]} 0 0 0
*createnode {n2[0]} {n2[1]} {n2[2]} 0 0 0
*createnode {n3[0]} {n3[1]} {n3[2]} 0 0 0
*createnode {n4[0]} {n4[1]} {n4[2]} 0 0 0

set nids [hm_entitylist nodes id]
*createlist nodes 1 {{*}}$nids
*createelement 104 1 1 1

puts "Created quad from 4 CSV points"
puts "Nodes: [hm_entitylist nodes id]"
puts "Elems: [hm_entitylist elems id]"
"""
    
    stdout, stderr, code = run_hm_tcl(tcl_code)
    print(stdout)
    return code == 0


def batch_import_multiple_csvs():
    """Import multiple CSV files"""
    
    # Create multiple sample CSVs
    files = []
    for i in range(3):
        csv_path = os.path.join(DATA_DIR, f"plate_{i}.csv")
        with open(csv_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['x', 'y', 'z'])
            writer.writerow([i*10, 0, 0])
            writer.writerow([i*10+10, 0, 0])
            writer.writerow([i*10+10, 10, 0])
            writer.writerow([i*10, 10, 0])
        files.append(csv_path)
    
    print(f"Created {len(files)} sample CSV files")
    
    # Import each
    for csv_path in files:
        basename = os.path.splitext(os.path.basename(csv_path))[0]
        import_csv_to_quads(csv_path, comp_name=basename)


if __name__ == "__main__":
    print("=" * 50)
    print("CSV Import to HyperMesh")
    print("=" * 50 + "\n")
    
    # Create sample CSV
    csv_path = create_sample_csv()
    
    # Option 1: Import as nodes
    print("\n--- Option 1: Import as Nodes ---")
    import_csv_to_nodes(csv_path)
    
    # Option 2: Import as quad
    print("\n--- Option 2: Import as Quad ---")
    import_csv_to_quads(csv_path)
    
    # Option 3: Batch import
    print("\n--- Option 3: Batch Import ---")
    batch_import_multiple_csvs()
    
    print("\n" + "=" * 50)
    print("Done!")
    print("=" * 50)
