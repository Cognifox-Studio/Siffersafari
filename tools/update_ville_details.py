import glob
import math
import xml.etree.ElementTree as ET

ET.register_namespace("", "http://www.w3.org/2000/svg")
ns = "{http://www.w3.org/2000/svg}"

files = glob.glob("assets/characters/ville/svg/ville_run_*.svg")
for f in files:
    tree = ET.parse(f)
    root = tree.getroot()
    
    for g in root.findall(f".//{ns}g"):
        cls = g.get("class", "")
        
        if cls in ["b-arm", "f-arm"]:
            arm_angle = 0
            path = g.find(f"{ns}path")
            if path is not None:
                path.set("stroke", "#ffdab9") 
                d = path.get("d")
                parts = d.split("L")
                if len(parts) >= 2:
                    # Calculate angle for hand accessories (wristband/thumb)
                    try:
                        p1 = parts[-2].strip().split()
                        p2 = parts[-1].strip().split()
                        ex, ey = float(p1[-2]), float(p1[-1])
                        hx, hy = float(p2[-2]), float(p2[-1])
                        arm_angle = math.degrees(math.atan2(hy - ey, hx - ex))
                    except:
                        arm_angle = 0
                        
                    sleeve_d = parts[0].strip() + " L " + parts[1].strip()
                    for old in g.findall(f"{ns}path[@class='sleeve']"): g.remove(old)
                    
                    sleeve = ET.Element(f"{ns}path")
                    sleeve.set("class", "sleeve")
                    sleeve.set("d", sleeve_d)
                    sleeve.set("stroke", "#ffeb3b")
                    sleeve.set("stroke-width", str(int(path.get("stroke-width"))+1)) # +1 to stick out like shorts
                    sleeve.set("stroke-linecap", "round")
                    sleeve.set("stroke-linejoin", "round")
                    sleeve.set("fill", "none")
                    
                    idx = list(g).index(path)
                    g.insert(idx+1, sleeve)
                    
            for old in g.findall(f"{ns}path[@class='thumb']"): g.remove(old)
            for old in g.findall(f"{ns}path[@class='wristband']"): g.remove(old)
            
            # Fix hand skin tone and add details
            for circle in g.findall(f"{ns}circle"):
                if circle.get("fill") in ["#eba476", "#ffdab9"]:
                    circle.set("fill", "#ffdab9")
                    cx = float(circle.get("cx"))
                    cy = float(circle.get("cy"))
                    r = float(circle.get("r"))
                    
                    # 15. Thumb/fist detail
                    # Make the thumb visually face "up" relative to the forearm vector
                    # Since forearm points down-ish, we just attach a transform
                    thumb = ET.Element(f"{ns}path", {
                        "class": "thumb",
                        "d": f"M {cx-r+2} {cy-1} Q {cx} {cy+4} {cx+r-2} {cy-1}",
                        "stroke": "#d8a688",
                        "stroke-width": "1.5",
                        "fill": "none",
                        "stroke-linecap": "round",
                        "transform": f"rotate({arm_angle - 90} {cx} {cy})"
                    })
                    g.insert(list(g).index(circle)+1, thumb)
                    
                    # 16. Wristband (only on f-arm for asymmetry)
                    if cls == "f-arm":
                        wristband = ET.Element(f"{ns}path", {
                            "class": "wristband",
                            "d": f"M {cx-r} {cy} L {cx+r} {cy}", # Placed exactly across the middle of the hand joint for now
                            "stroke": "#ff5252",
                            "stroke-width": "4",
                            "fill": "none",
                            "stroke-linecap": "round",
                            "transform": f"rotate({arm_angle - 90} {cx} {cy})"
                        })
                        g.insert(list(g).index(circle), wristband)
                        
        elif cls in ["b-leg", "f-leg"]:
            leg_angle = 0
            path = g.find(f"{ns}path")
            if path is not None:
                path.set("stroke", "#ffdab9")
                d = path.get("d")
                parts = d.split("L")
                if len(parts) >= 2:
                    try:
                        p1 = parts[-2].strip().split()
                        p2 = parts[-1].strip().split()
                        kx, ky = float(p1[-2]), float(p1[-1]) # knee
                        hx, hy = float(p2[-2]), float(p2[-1]) # heel
                        leg_angle = math.degrees(math.atan2(hy - ky, hx - kx))
                    except:
                        leg_angle = 0
                        
                    shorts_d = parts[0].strip() + " L " + parts[1].strip()
                    for old in g.findall(f"{ns}path[@class='shorts']"): g.remove(old)
                    for old in g.findall(f"{ns}path[@class='sock']"): g.remove(old)
                    for old in g.findall(f"{ns}path[@class='shorts-pocket']"): g.remove(old)
                    for old in g.findall(f"{ns}path[@class='shorts-seam']"): g.remove(old)
                    for old in g.findall(f"{ns}ellipse[@class='dirt']"): g.remove(old)
                    
                    shorts = ET.Element(f"{ns}path")
                    shorts.set("class", "shorts")
                    shorts.set("d", shorts_d)
                    shorts.set("stroke", "#42a5f5")
                    shorts.set("stroke-width", str(int(path.get("stroke-width"))+1))
                    shorts.set("stroke-linecap", "round")
                    shorts.set("stroke-linejoin", "round")
                    shorts.set("fill", "none")
                    
                    shorts_pocket = ET.Element(f"{ns}path")
                    shorts_pocket.set("class", "shorts-pocket")
                    shorts_pocket.set("d", shorts_d)
                    shorts_pocket.set("stroke", "#90caf9")
                    shorts_pocket.set("stroke-width", "1.5")
                    shorts_pocket.set("stroke-dasharray", "4, 10")
                    shorts_pocket.set("stroke-linecap", "round")
                    shorts_pocket.set("fill", "none")
                    
                    shorts_seam = ET.Element(f"{ns}path")
                    shorts_seam.set("class", "shorts-seam")
                    shorts_seam.set("d", shorts_d)
                    shorts_seam.set("stroke", "#fbc02d") # 13. Stitching yellow
                    shorts_seam.set("stroke-width", "1.5")
                    shorts_seam.set("stroke-dasharray", "3, 22") # Adjusted spacing to look more like stitching on shorts side
                    shorts_seam.set("stroke-linecap", "round")
                    shorts_seam.set("fill", "none")
                    
                    # Add sock at the bottom of the leg
                    # Take the last section of the path
                    sock_d = parts[-2].strip().split(" ")[-2:] # Get roughly the end point coordinates
                    if len(parts) >= 3:
                        px, py = parts[-2].strip().split(" ")[-2:]
                        ex, ey = parts[-1].strip().split(" ")
                        
                        # Just draw a line slightly above the shoe
                        # We calculate a point 70% down the leg
                        mid_x = float(px) + 0.6 * (float(ex) - float(px))
                        mid_y = float(py) + 0.6 * (float(ey) - float(py))
                        
                    # 14. Dirt on knees
                    try:
                        px_orig = float(parts[1].strip().split(" ")[-2])
                        ex_orig = float(parts[2].strip().split(" ")[-2])
                        py_orig = float(parts[1].strip().split(" ")[-1])
                        ey_orig = float(parts[2].strip().split(" ")[-1])
                        mid_x_knee = px_orig + 0.45 * (ex_orig - px_orig)
                        mid_y_knee = py_orig + 0.45 * (ey_orig - py_orig)
                    except:
                        px_orig = float(parts[0].strip().split(" ")[1])
                        py_orig = float(parts[0].strip().split(" ")[2])
                        mid_x_knee = px_orig
                        mid_y_knee = py_orig + 20

                    dirt1 = ET.Element(f"{ns}ellipse", {
                        "class": "dirt", 
                        "cx": str(mid_x_knee - 3), 
                        "cy": str(mid_y_knee), 
                        "rx": "2", 
                        "ry": "1.5", 
                        "fill": "#a1887f", 
                        "opacity": "0.6",
                        "transform": f"rotate({leg_angle - 90} {mid_x_knee - 3} {mid_y_knee})"
                    })
                    dirt2 = ET.Element(f"{ns}ellipse", {
                        "class": "dirt", 
                        "cx": str(mid_x_knee + 2), 
                        "cy": str(mid_y_knee + 2), 
                        "rx": "1.5", 
                        "ry": "1", 
                        "fill": "#a1887f", 
                        "opacity": "0.6",
                        "transform": f"rotate({leg_angle - 90} {mid_x_knee + 2} {mid_y_knee + 2})"
                    })
                    
                    g.insert(idx+1, shorts)
                    g.insert(idx+2, shorts_pocket)
                    g.insert(idx+3, shorts_seam)
                    g.insert(idx+4, dirt1)
                    g.insert(idx+5, dirt2)
                else:
                    idx = list(g).index(path)
                    g.insert(idx+1, shorts)
            
            for old in g.findall(f"{ns}path[@class='shoelace']"): g.remove(old)
            for old in g.findall(f"{ns}path[@class='sneaker-stripe']"): g.remove(old)
            for old in g.findall(f"{ns}path[@class='sole-pattern']"): g.remove(old)
            
            # Need to get all ellipses to find the correct one in the group
            ellipses = g.findall(f"{ns}ellipse")
            for ellipse in ellipses:
                if ellipse.get("class") != "sole" and ellipse.get("class") != "dirt" and ellipse in list(g):
                    for old_sole in g.findall(f"{ns}ellipse[@class='sole']"):
                        g.remove(old_sole)
                        
                    cx = float(ellipse.get("cx"))
                    cy = float(ellipse.get("cy"))
                    rx = float(ellipse.get("rx"))
                    ry = float(ellipse.get("ry"))
                        
                    sole = ET.Element(f"{ns}ellipse")
                    sole.set("class", "sole")
                    sole.set("cx", str(cx))
                    sole.set("cy", str(cy + 3)) # shifted down slightly
                    # Make sole slightly thicker and flatter
                    sole.set("rx", str(rx + 1))
                    sole.set("ry", str(ry + 1))
                    sole.set("fill", "#ecf0f1")
                    if ellipse.get("transform"):
                        sole.set("transform", ellipse.get("transform"))
                        
                    idx = list(g).index(ellipse)
                    g.insert(idx, sole) # Put it before the red shoe so it acts as a base
                    
                    # 19. Sole zig-zag pattern (simplified as a dashed line)
                    sole_pattern = ET.Element(f"{ns}path", {
                        "class": "sole-pattern",
                        "d": f"M {cx-rx} {cy+2} L {cx+rx} {cy+2}",
                        "stroke": "#bdc3c7",
                        "stroke-width": "1.5",
                        "stroke-dasharray": "2,2",
                        "fill": "none",
                        "transform": ellipse.get("transform") if ellipse.get("transform") else ""
                    })
                    g.insert(idx+1, sole_pattern)
                    
                    # 18. Sneaker stripe (white lightning/stripe on side) MUST rotate with foot
                    stripe = ET.Element(f"{ns}path", {
                        "class": "sneaker-stripe",
                        "d": f"M {cx-rx+4} {cy-2} L {cx+rx-8} {cy+2} L {cx+rx-4} {cy-1}",
                        "stroke": "#ffffff",
                        "stroke-width": "2",
                        "stroke-linecap": "round",
                        "stroke-linejoin": "round",
                        "fill": "none",
                        "transform": ellipse.get("transform") if ellipse.get("transform") else ""
                    })
                    
                    # 17. Shoelaces MUST rotate with foot
                    lace = ET.Element(f"{ns}path", {
                        "class": "shoelace",
                        "d": f"M {cx-2} {cy-ry-1} Q {cx-5} {cy-ry-4} {cx-8} {cy-ry-1} M {cx-8} {cy-ry-1} Q {cx-9} {cy-ry-4} {cx-12} {cy-ry-1}",
                        "stroke": "#ffffff",
                        "stroke-width": "1.5",
                        "fill": "none",
                        "stroke-linecap": "round",
                        "transform": ellipse.get("transform") if ellipse.get("transform") else ""
                    })
                    
                    # Insert stripes relative to ellipse so they stay layered inside the foot group
                    g.insert(idx+4, stripe)
                    g.insert(idx+5, lace)
                        
        elif cls == "head":
            for child in list(g):
                if child.get("class") in ["eye", "mouth", "hair", "cheek", "eyebrow", "catchlight", "teeth", "tongue", "nose", "ear", "ear-inner", "freckle", "fringe"]: 
                    g.remove(child)
            
            face = g.find(f"{ns}circle")
            if face is not None:
                idx = list(g).index(face)
                
                # Hair (inserted BEFORE the face so it renders behind the head)
                hair = ET.Element(f"{ns}path", {"class": "hair", "d": "M 15 -10 Q 30 -5 24 12 Q 18 15 10 20 Q 20 5 10 -10 Z", "fill": "#8d6e63"})
                g.insert(idx, hair)
                
                # We compensate the index for the hair we just inserted
                idx += 1
                
                # Eyes slightly larger & expressive
                eye1 = ET.Element(f"{ns}circle", {"class": "eye", "cx": "-5", "cy": "-5", "r": "3", "fill": "#2c3e50"})
                eye2 = ET.Element(f"{ns}circle", {"class": "eye", "cx": "-16", "cy": "-5", "r": "3", "fill": "#2c3e50"})
                
                # Catchlights (the small white glints setting the character alive)
                cl1 = ET.Element(f"{ns}circle", {"class": "catchlight", "cx": "-5.5", "cy": "-6.5", "r": "1.2", "fill": "#ffffff"})
                cl2 = ET.Element(f"{ns}circle", {"class": "catchlight", "cx": "-16.5", "cy": "-6.5", "r": "1.2", "fill": "#ffffff"})
                
                # Eyebrows
                eb1 = ET.Element(f"{ns}path", {"class": "eyebrow", "d": "M -1 -12 Q -5 -14 -8 -10", "stroke": "#5d4037", "stroke-width": "1.5", "fill": "none", "stroke-linecap": "round"})
                eb2 = ET.Element(f"{ns}path", {"class": "eyebrow", "d": "M -12 -12 Q -16 -14 -19 -10", "stroke": "#5d4037", "stroke-width": "1.5", "fill": "none", "stroke-linecap": "round"})
                
                # Cheeks (blush)
                ch1 = ET.Element(f"{ns}ellipse", {"class": "cheek", "cx": "1", "cy": "2", "rx": "3.5", "ry": "2", "fill": "#ff8a65", "opacity": "0.6"})
                ch2 = ET.Element(f"{ns}ellipse", {"class": "cheek", "cx": "-21", "cy": "2", "rx": "3.5", "ry": "2", "fill": "#ff8a65", "opacity": "0.6"})
                
                # Mouth (An open, determined/happy run mouth)
                mouth = ET.Element(f"{ns}path", {"class": "mouth", "d": "M -4 3 Q -10.5 12 -17 3 Q -10.5 16 -4 3 Z", "fill": "#c0392b"})
                mouth_teeth = ET.Element(f"{ns}path", {"class": "teeth", "d": "M -5 4 Q -10.5 10 -16 4 Q -10.5 7 -5 4 Z", "fill": "#ffffff"}) # 1. Teeth
                mouth_tongue = ET.Element(f"{ns}path", {"class": "tongue", "d": "M -5 10 Q -10.5 16 -16 10 Z", "fill": "#f06292"}) # 2. Tongue
                
                # Nose
                nose = ET.Element(f"{ns}ellipse", {"class": "nose", "cx": "-5", "cy": "-1", "rx": "4", "ry": "3.5", "fill": "#e6ad8a"})
                
                # Ear
                ear = ET.Element(f"{ns}ellipse", {"class": "ear", "cx": "12", "cy": "-1", "rx": "5", "ry": "7", "fill": "#ffdab9"})
                inner_ear = ET.Element(f"{ns}path", {"class": "ear-inner", "d": "M 10 2 Q 13 -1 13 -4", "stroke": "#e6ad8a", "stroke-width": "1.5", "fill": "none", "stroke-linecap": "round"})
                
                # 3. Freckles
                freckle1 = ET.Element(f"{ns}circle", {"class": "freckle", "cx": "-18", "cy": "1", "r": "1.2", "fill": "#d8a688", "opacity": "0.7"})
                freckle2 = ET.Element(f"{ns}circle", {"class": "freckle", "cx": "-23", "cy": "2", "r": "1.2", "fill": "#d8a688", "opacity": "0.7"})
                
                # 4. Hair fringe (poking out front)
                fringe = ET.Element(f"{ns}path", {"class": "fringe", "d": "M -16 -15 Q -25 -20 -28 -12 Q -22 -14 -16 -15 Z", "fill": "#8d6e63"})
                
                g.insert(idx+1, fringe)
                g.insert(idx+2, eye1)
                g.insert(idx+3, eye2)
                g.insert(idx+4, cl1)
                g.insert(idx+5, cl2)
                g.insert(idx+6, eb1)
                g.insert(idx+7, eb2)
                g.insert(idx+8, ch1)
                g.insert(idx+9, ch2)
                g.insert(idx+10, freckle1)
                g.insert(idx+11, freckle2)
                g.insert(idx+12, mouth)
                g.insert(idx+13, mouth_teeth)
                g.insert(idx+14, mouth_tongue)
                g.insert(idx+15, nose)
                g.insert(idx+16, ear)
                g.insert(idx+17, inner_ear)
                
            # Add hat band and fix hat structure
            inner_g = g.find(f"{ns}g")
            if inner_g is not None:
                # We need to move the hat crown inside inner_g so it bounces with the brim
                hat_crown = None
                for child in list(g):
                    if child.get("fill") == "#f5deb3":
                        hat_crown = child
                        break
                
                # Also check if it was already moved to inner_g in a previous run
                if hat_crown is None:
                    for child in list(inner_g):
                        if child.get("fill") == "#f5deb3":
                            hat_crown = child
                            break
                        
                if hat_crown is not None:
                    try:
                        g.remove(hat_crown)
                    except:
                        pass
                    try:
                        inner_g.remove(hat_crown)
                    except:
                        pass

                    hat_crown.set("d", "M -18 -10 Q -5 -30 12 -10 Z") # Shifted to face left, centered nicely over the brim
                    inner_g.insert(0, hat_crown)
                    
                for old in inner_g.findall(f"{ns}path[@class='hat-band']"): inner_g.remove(old)
                brim = inner_g.find(f"{ns}rect")
                if brim is not None:
                    # Shift brim to stick out more to the left
                    brim.set("x", "-32")
                    brim.set("width", "54")
                    
                    band = ET.Element(f"{ns}path", {
                        "class": "hat-band", 
                        "d": "M -16 -10 Q -3 -12 10 -10", # Shifted band down to sit cleanly on the brim line
                        "stroke": "#4caf50", 
                        "stroke-width": "4", 
                        "fill": "none", 
                        "stroke-linecap": "round"
                    })
                    idx = list(inner_g).index(brim)
                    inner_g.insert(idx+1, band)
                
        elif cls == "torso":
            for old in g.findall(f"{ns}path[@class='strap']"): g.remove(old)
            for old in g.findall(f"{ns}rect[@class='neck']"): g.remove(old)
            for old in g.findall(f"{ns}rect[@class='waistband']"): g.remove(old)
            for old in g.findall(f"{ns}path[@class='collar']"): g.remove(old)
            for old in g.findall(f"{ns}circle[@class='shirt-logo']"): g.remove(old)
            for old in g.findall(f"{ns}path[@class='shirt-wrinkle']"): g.remove(old)
            rects = g.findall(f"{ns}rect")
            if len(rects) >= 2:
                shirt = rects[1]
                x = float(shirt.get("x"))
                y = float(shirt.get("y"))
                w = float(shirt.get("width"))
                h = float(shirt.get("height"))
                idx = list(g).index(shirt)
                
                # Add a neck behind the shirt, connecting torso and head
                neck = ET.Element(f"{ns}rect", {
                    "class": "neck",
                    "x": str(x + (w/2) - 8),
                    "y": str(y - 12),
                    "width": "16",
                    "height": "25",
                    "rx": "6",
                    "fill": "#ffdab9"
                })
                # Insert behind the first rect (the blue base)
                g.insert(0, neck)
                
                # 7. Shirt collar
                collar = ET.Element(f"{ns}path", {
                    "class": "collar",
                    "d": f"M {x + (w/2) - 10} {y} Q {x + (w/2)} {y+8} {x + (w/2) + 10} {y}",
                    "stroke": "#fbc02d",
                    "stroke-width": "3",
                    "fill": "none",
                    "stroke-linecap": "round"
                })
                g.insert(idx+2, collar)
                
                # 8. Logo on shirt (small star or circle)
                logo = ET.Element(f"{ns}circle", {
                    "class": "shirt-logo",
                    "cx": str(x + 15),
                    "cy": str(y + 20),
                    "r": "6",
                    "fill": "#ffb300"
                })
                g.insert(idx+3, logo)
                
                # 9. Shirt wrinkles
                wrinkle = ET.Element(f"{ns}path", {
                    "class": "shirt-wrinkle",
                    "d": f"M {x+5} {y+10} Q {x+15} {y+15} {x+20} {y+35}",
                    "stroke": "#fbc02d",
                    "stroke-width": "1.5",
                    "fill": "none",
                    "stroke-linecap": "round"
                })
                g.insert(idx+4, wrinkle)
                
                # Add a waistband just above the blue base to visually connect shirt and shorts
                waistband = ET.Element(f"{ns}rect", {
                    "class": "waistband",
                    "x": str(x - 2),
                    "y": str(y + h),
                    "width": str(w + 4),
                    "height": "10",
                    "rx": "4",
                    "fill": "#1976d2" # Darker blue than shorts/shirt
                })
                g.insert(idx+2, waistband)
                
                # Make straps hug the chest and end cleanly at the waist
                sx1, sy1 = x + 15, y - 5
                ex1, ey1 = x + 10, y + h + 5
                sx2, sy2 = x + 40, y - 5
                ex2, ey2 = x + 35, y + h + 5
                
                strap1 = ET.Element(f"{ns}path", {"class": "strap", "d": f"M {sx1} {sy1} Q {sx1-5} {sy1+(h/2)} {ex1} {ey1}", "stroke": "#2e7d32", "stroke-width": "6", "fill": "none", "stroke-linecap": "round"})
                strap2 = ET.Element(f"{ns}path", {"class": "strap", "d": f"M {sx2} {sy2} Q {sx2-2} {sy2+(h/2)} {ex2} {ey2}", "stroke": "#2e7d32", "stroke-width": "6", "fill": "none", "stroke-linecap": "round"})
                # Insert straps behind the logo/wrinkles
                g.insert(idx+1, strap1)
                g.insert(idx+2, strap2)
                
            # Now let's move the backpack (ellipse) to the right side (back)
            for ellipse in g.findall(f"{ns}ellipse"):
                if ellipse.get("fill") == "#4caf50": # Green backpack
                    # Calculate position relative to shirt (if shirt was found!)
                    if len(rects) >= 2:
                        shirt = rects[1]
                        sx = float(shirt.get("x"))
                        sw = float(shirt.get("width"))
                        sy = float(shirt.get("y"))
                        
                        # Position behind the back (right side)
                        ellipse.set("cx", str(sx + sw + 5))
                        ellipse.set("cy", str(sy + 20))
                        ellipse.set("rx", "14")
                        ellipse.set("ry", "24")
                    else:
                        ellipse.set("cx", "125")
                        ellipse.set("cy", "135")
                        ellipse.set("rx", "14")
                        ellipse.set("ry", "24")
                    
                    # Also, the backpack should ideally be drawn BEFORE the torso rects
                    # so that it is partially hidden behind the body, giving depth!
                    # Remove it from current pos
                    g.remove(ellipse)
                    # Insert right at the beginning of the group (index 0)
                    g.insert(0, ellipse)

    tree.write(f, xml_declaration=True, encoding="utf-8")