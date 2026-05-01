import glob
import xml.etree.ElementTree as ET

ET.register_namespace("", "http://www.w3.org/2000/svg")
ns = "{http://www.w3.org/2000/svg}"

files = glob.glob("assets/characters/ville/svg/ville_run_*.svg")
for f in files:
    tree = ET.parse(f)
    root = tree.getroot()
    
    for g in root.findall(f".//{ns}g"):
        if g.get("class") == "head":
            # The rotating group
            inner_g = g.find(f"{ns}g")
            
            # The currently static hat crown
            hat_crown = None
            for path in g.findall(f"{ns}path"):
                # Finding the crown by its fill color
                if path.get("fill") == "#f5deb3":
                    hat_crown = path
                    break
                    
            if inner_g is not None and hat_crown is not None:
                # Remove crown from its static position
                g.remove(hat_crown)
                
                # Let's adjust the crown to lean left. 
                # Old: d="M -25 -10 Q 0 -50 25 -10 Z"
                # New: leaning left, peaking slightly left of center
                hat_crown.set("d", "M -28 -10 Q -5 -50 22 -10 Z")
                
                # Add crown to the rotating group BEFORE the brim (so brim draws on top)
                # Wait, originally in generate script, crown was drawn AFTER brim?
                # Actually, crown behind brim makes sense.
                # Let's insert at index 0 of inner_g
                inner_g.insert(0, hat_crown)
                
                # Let's also adjust the brim to stick out more to the left
                brim = inner_g.find(f"{ns}rect")
                if brim is not None:
                    # Old: x="-35" width="70"
                    # New: shifts left
                    brim.set("x", "-42")
                    brim.set("width", "68") # Slightly longer brim towards the left
                
                # Adjust hat band slightly left too
                # Old: d="M -23 -13 Q 0 -18 23 -13"
                # New: shifted left
                band = inner_g.find(f"{ns}path[@class='hat-band']")
                if band is not None:
                    band.set("d", "M -26 -13 Q -3 -18 20 -13")
                    
    tree.write(f, xml_declaration=True, encoding="utf-8")
    
print("Fixed hats!")
