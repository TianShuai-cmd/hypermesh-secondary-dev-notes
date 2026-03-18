# =============================================================
# Script  : 16_python_export_report.py
# Purpose : Export model info and quality report to file
# Date    : 2026-03-17
# Version : Python 3.x + HyperMesh 2023
# Usage   : python 16_python_export_report.py
# =============================================================

"""
Export Report - Generate model information and quality reports
"""

import os
import subprocess
import tempfile
from datetime import datetime

HMBATCH_PATH = r"C:\a\Altair\2023\hwdesktop\hm\bin\win64\hmbatch.exe"
OUTPUT_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\projects"


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
        return result.stdout
    finally:
        if os.path.exists(tcl_file):
            os.remove(tcl_file)


def generate_report():
    """Generate model report"""
    
    tcl_code = """
# Create test model
*collectorcreate comps Report_Test {}
*currentcollector comps Report_Test

# Create 2 quads - one good, one distorted
*createnode 0 0 0 0 0 0
*createnode 10 0 0 0 0 0
*createnode 10 10 0 0 0 0
*createnode 0 10 0 0 0 0

*createnode 20 0 0 0 0 0
*createnode 35 2 0 0 0 0
*createnode 30 10 0 0 0 0
*createnode 18 8 0 0 0 0

set nids [hm_entitylist nodes id]
*createlist nodes 1 {*}$nids
*createelement 104 1 1 1

*createlist nodes 1 5 6 7 8
*createelement 104 1 1 1

# Get counts
set node_count [llength [hm_entitylist nodes id]]
set elem_count [llength [hm_entitylist elems id]]

# Quality check
*createmark elems 2 "all"
set asp [hm_getelemcheckvalues 2 2 aspect]

puts "===REPORT_START==="
puts "NODES:$node_count"
puts "ELEMS:$elem_count"
puts "ASPECT:$asp"
puts "===REPORT_END==="
"""
    
    stdout = run_hm_tcl(tcl_code)
    
    # Parse output
    lines = stdout.split('\n')
    report_data = {}
    in_report = False
    
    for line in lines:
        if '===REPORT_START===' in line:
            in_report = True
            continue
        if '===REPORT_END===' in line:
            break
        if in_report and ':' in line:
            key, val = line.split(':', 1)
            report_data[key.strip()] = val.strip()
    
    return report_data


if __name__ == "__main__":
    print("=" * 50)
    print("HyperMesh Export Report")
    print("=" * 50 + "\n")
    
    print("Generating report...")
    data = generate_report()
    
    # Print to console
    print(f"\nNodes: {data.get('NODES', 'N/A')}")
    print(f"Elements: {data.get('ELEMS', 'N/A')}")
    print(f"Aspect: {data.get('ASPECT', 'N/A')}")
    
    # Save to file
    report_path = os.path.join(OUTPUT_DIR, "model_report.txt")
    with open(report_path, 'w') as f:
        f.write("=" * 50 + "\n")
        f.write("   HYPERMESH MODEL REPORT\n")
        f.write("=" * 50 + "\n")
        f.write(f"Generated: {datetime.now()}\n\n")
        f.write("MODEL SUMMARY\n")
        f.write("-" * 50 + "\n")
        f.write(f"Nodes:     {data.get('NODES', 'N/A')}\n")
        f.write(f"Elements:  {data.get('ELEMS', 'N/A')}\n")
        f.write(f"\nMESH QUALITY (Aspect Ratio)\n")
        f.write("-" * 50 + "\n")
        f.write(f"{data.get('ASPECT', 'N/A')}\n")
    
    print(f"\nReport saved: {report_path}")
    print("=" * 50)
