# =============================================================
# Script  : 17_python_gui.py
# Purpose : Simple GUI for HyperMesh automation
# Date    : 2026-03-17
# Version : Python 3.x + HyperMesh 2023
# Usage   : python 17_python_gui.py
# =============================================================

"""
Simple GUI for HyperMesh Automation

Features:
- Create simple geometry (plate, beam)
- Run mesh operations
- View model statistics
- Export reports
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import subprocess
import os
import tempfile

HMBATCH_PATH = r"C:\a\Altair\2023\hwdesktop\hm\bin\win64\hmbatch.exe"
SCRIPT_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\scripts"
OUTPUT_DIR = r"C:\Users\13378\Desktop\HyperMesh-Dev\projects"


class HyperMeshGUI:
    """Simple GUI for HyperMesh automation"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("HyperMesh Automation Tool")
        self.root.geometry("500x400")
        
        # Check hmbatch exists
        if not os.path.exists(HMBATCH_PATH):
            messagebox.showerror("Error", f"hmbatch.exe not found:\n{HMBATCH_PATH}")
        
        self.create_widgets()
    
    def create_widgets(self):
        """Create GUI widgets"""
        
        # Title
        title = tk.Label(self.root, text="HyperMesh Automation", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # Notebook for tabs
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill='both', expand=True, padx=10, pady=10)
        
        # Tab 1: Geometry
        tab1 = ttk.Frame(notebook)
        notebook.add(tab1, text="Geometry")
        self.create_geometry_tab(tab1)
        
        # Tab 2: Mesh
        tab2 = ttk.Frame(notebook)
        notebook.add(tab2, text="Mesh")
        self.create_mesh_tab(tab2)
        
        # Tab 3: Tools
        tab3 = ttk.Frame(notebook)
        notebook.add(tab3, text="Tools")
        self.create_tools_tab(tab3)
        
        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        status_bar = tk.Label(self.root, textvariable=self.status_var, 
                             bd=1, relief=tk.SUNKEN, anchor=tk.W)
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)
    
    def create_geometry_tab(self, parent):
        """Geometry creation tab"""
        
        # Plate section
        tk.Label(parent, text="Create Plate", font=("Arial", 12, "bold")).pack(pady=5)
        
        frame = tk.Frame(parent)
        frame.pack(pady=5)
        
        tk.Label(frame, text="Width:").grid(row=0, column=0, padx=5)
        self.width_entry = tk.Entry(frame, width=10)
        self.width_entry.insert(0, "100")
        self.width_entry.grid(row=0, column=1, padx=5)
        
        tk.Label(frame, text="Height:").grid(row=0, column=2, padx=5)
        self.height_entry = tk.Entry(frame, width=10)
        self.height_entry.insert(0, "50")
        self.height_entry.grid(row=0, column=3, padx=5)
        
        tk.Button(parent, text="Create Plate", command=self.create_plate).pack(pady=10)
        
        # Beam section
        tk.Label(parent, text="Create Beam", font=("Arial", 12, "bold")).pack(pady=5)
        
        frame2 = tk.Frame(parent)
        frame2.pack(pady=5)
        
        tk.Label(frame2, text="Length:").grid(row=0, column=0, padx=5)
        self.length_entry = tk.Entry(frame2, width=10)
        self.length_entry.insert(0, "200")
        self.length_entry.grid(row=0, column=1, padx=5)
        
        tk.Button(parent, text="Create Beam", command=self.create_beam).pack(pady=10)
    
    def create_mesh_tab(self, parent):
        """Mesh operations tab"""
        
        tk.Label(parent, text="Mesh Operations", font=("Arial", 12, "bold")).pack(pady=5)
        
        tk.Button(parent, text="Get Model Info", command=self.get_model_info, width=20).pack(pady=5)
        tk.Button(parent, text="Run Quality Check", command=self.run_quality_check, width=20).pack(pady=5)
        tk.Button(parent, text="Clear Model", command=self.clear_model, width=20).pack(pady=5)
    
    def create_tools_tab(self, parent):
        """Tools tab"""
        
        tk.Label(parent, text="Tools", font=("Arial", 12, "bold")).pack(pady=5)
        
        tk.Button(parent, text="Open Projects Folder", command=self.open_folder, width=20).pack(pady=5)
        tk.Button(parent, text="View Last Report", command=self.view_report, width=20).pack(pady=5)
    
    def run_hm_command(self, tcl_code):
        """Run TCL command via hmbatch"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.tcl', delete=False, encoding='utf-8') as f:
            f.write(tcl_code)
            f.write("\nexit\n")
            tcl_file = f.name
        
        try:
            self.status_var.set("Running...")
            self.root.update()
            
            result = subprocess.run(
                [HMBATCH_PATH, "-tcl", tcl_file],
                capture_output=True, text=True, timeout=30,
                encoding='utf-8', errors='replace'
            )
            
            return result.stdout
        except subprocess.TimeoutExpired:
            messagebox.showerror("Error", "Command timed out")
            return ""
        except Exception as e:
            messagebox.showerror("Error", str(e))
            return ""
        finally:
            if os.path.exists(tcl_file):
                os.remove(tcl_file)
            self.status_var.set("Ready")
    
    def create_plate(self):
        """Create plate geometry"""
        
        width = self.width_entry.get()
        height = self.height_entry.get()
        
        tcl_code = f"""
*deletemodel
*collectorcreate comps Plate_{width}x{height} {{}}
*currentcollector comps Plate_{width}x{height}}
*createnode 0 0 0 0 0 0
*createnode {width} 0 0 0 0 0
*createnode {width} {height} 0 0 0 0
*createnode 0 {height} 0 0 0 0
set nids [hm_entitylist nodes id]
*createlist nodes 1 {{*}}$nids
*createelement 104 1 1 1
puts "Created plate: {width} x {height}"
"""
        
        result = self.run_hm_command(tcl_code)
        messagebox.showinfo("Done", f"Plate created:\n{width} x {height}")
    
    def create_beam(self):
        """Create beam geometry"""
        
        length = self.length_entry.get()
        
        tcl_code = f"""
*deletemodel
*collectorcreate comps Beam_L{length} {{}}
*currentcollector comps Beam_L{length}
*createnode 0 0 0 0 0 0
*createnode {length} 0 0 0 0 0
*createnode {length} 10 0 0 0 0
*createnode 0 10 0 0 0 0
set nids [hm_entitylist nodes id]
*createlist nodes 1 {{*}}$nids
*createelement 104 1 1 1
puts "Created beam: length {length}"
"""
        
        result = self.run_hm_command(tcl_code)
        messagebox.showinfo("Done", f"Beam created:\nLength {length}")
    
    def get_model_info(self):
        """Get model information"""
        
        tcl_code = """
puts "Nodes: [llength [hm_entitylist nodes id]]"
puts "Elems: [llength [hm_entitylist elems id]]"
puts "Comps: [llength [hm_entitylist comps id]]"
"""
        
        result = self.run_hm_command(tcl_code)
        
        # Parse result
        lines = result.split('\n')
        info = '\n'.join([l for l in lines if ':' in l and not l.startswith(' ')])
        
        messagebox.showinfo("Model Info", info if info else "Model is empty")
    
    def run_quality_check(self):
        """Run mesh quality check"""
        
        tcl_code = """
*createmark elems 2 "all"
set asp [hm_getelemcheckvalues 2 2 aspect]
puts "Aspect: $asp"
"""
        
        result = self.run_hm_command(tcl_code)
        messagebox.showinfo("Quality Check", result)
    
    def clear_model(self):
        """Clear model"""
        
        if messagebox.askyesno("Confirm", "Clear current model?"):
            tcl_code = "*deletemodel\nputs \"Model cleared\""
            self.run_hm_command(tcl_code)
            messagebox.showinfo("Done", "Model cleared")
    
    def open_folder(self):
        """Open projects folder"""
        
        os.startfile(OUTPUT_DIR)
    
    def view_report(self):
        """View last report"""
        
        report_path = os.path.join(OUTPUT_DIR, "model_report.txt")
        if os.path.exists(report_path):
            os.startfile(report_path)
        else:
            messagebox.showinfo("Info", "No report found.\nRun script 16 first.")


def main():
    """Main entry point"""
    
    root = tk.Tk()
    app = HyperMeshGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
