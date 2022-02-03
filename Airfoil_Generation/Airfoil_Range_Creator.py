import sys
import os
import shutil
import numpy as np
import scipy.interpolate as spln
import Airfoil_Generation.Images_Generator as ig
# import Airfoil_DataSet_Generator_Randomizer as air

"""
plusminus_50.py
--------------------
This piece of code is developed to generate airfoil geometrical
data in a linear and deterministic fashion. This is done to create
a deterministic spectrum of uniformally deformed airfoils ranging from
-50% to +50% deformation rates (or whatever else rate it may be desired).
There is an option to skip certain percentages, as they may be already have
been calculated and they are redundant to examine again.

The program may be called as :
python3 plusminus_50.py geometry_file_path -percentage +percentage -exclusion +exclusion delta

ie. python3 plusminus_50.py geometry.dat -78 90 -10 15 2
"""


def spline_fitting_over_range(points, prange):
    # ------- B-spline preping ----------
    tck, u = spln.splprep([points[:, 0], points[:, 1]], k=3, s=0)
    kn = tck[0]  # extract knotvectodr
    CP = np.array(tck[1])  # control points
    k = tck[2]  # spline grade

    CP_temp = []
    curves = []
    n = len(prange)

    for i in range(n):
        for j in range(len(CP[0])):
            CP_temp.append((1+prange[i]/100)*CP[1, j])

        curves.append(spln.splev(u, [kn, [CP[0, :], CP_temp], k]))
        CP_temp = []

    return curves


def c_range(m_per, p_per, m_exc, p_exc, delta):
    outer_bounds = list(range(m_per, p_per+1, delta))
    inner_bounds = list(range(m_exc, p_exc+1, delta))
    lastj = 0

    for i in range(len(inner_bounds)):
        for j in range(lastj, len(outer_bounds), 1):
            if (abs((inner_bounds[i]-outer_bounds[j])) < delta):
                outer_bounds.pop(j)
                lastj = j
                break
    return outer_bounds


def readfile(path):
    points_up = np.zeros((1, 2), dtype="float")
    points_down = np.zeros((1, 2), dtype="float")
    vv = "up"
    index = []
    #requires a .geom file
    data = open(path, "r")
    lines = data.readlines()
    lines.pop(0)  # first line usefull only for MaPFlow
    for line in lines:
            bits = line.split(" ")
            index.append(bits[0])
            if (points_up[-1, 1] > 0) and (float(bits[2]) < 0):
                vv = "down"
            if vv == "up":
                points_up = np.append(
                    points_up, [[float(bits[1]), float(bits[2])]], axis=0)
            elif vv == "down":
                points_down = np.append(
                    points_down, [[float(bits[1]), float(bits[2])]], axis=0)

    # appointing the spline end points
    points_up = np.append(points_up, [[1.0, 0.0]], axis=0)
    points_down = np.append(points_down, [[0.0, 0.0]], axis=0)
    points_up = np.delete(points_up, 0, 0)
    # points_down=np.delete(points_down,0,0)
    return points_up, points_down


def organizer(r, curves_up, curves_down, directory, reset=True):
    DIRS = ""  # Directories List for indexing
    try:
        os.mkdir(directory)
        print(f"The directory: {directory} has been made.")
    except:
        print(f"The directory: {directory} already exists.")

    for i in range(len(r)):
        dir = f"{directory}/{r[i]}%/"

        try:
            os.mkdir(dir)
        except:
            shutil.rmtree(dir, ignore_errors=reset)
            os.mkdir(dir)

        DIRS += f"{dir}\n"

        text = [f"#variant no.{i}\n"]
        for j in range(0, len(curves_up[i][0])-1):
            text.append(f"{curves_up[i][0][j]} {curves_up[i][1][j]}\n")
        for j in range(1, len(curves_down[i][0])-1):
            text.append(f"{curves_down[i][0][j]} {curves_down[i][1][j]}\n")
        text.append("----------- EOF ---------------------")

        #data export as var.geom file for use with grid manipulation
        with open((dir+f"var.geom"), 'w') as file:
            for line in text:
                file.write(line)
		#image data export
        ig.ImageDatabase(dir, text)

    return DIRS


if __name__ == "__main__":
    ABS_PATH = "/home/freshstart/DiplomaThesisData/"
    args = sys.argv
    args.pop(0)
    if (len(args) == 0 ):
        sys.exit("Error: Geometry data file path not specified")
    else: path = args[0]

    # Default state
    m_per = -50
    p_per = 50
    m_exc = -20
    p_exc = 20
    delta = 1

    try:
        args.pop(0) #optional arguments
    except:
        print("No optional args were found. Default values are used!")

    if (len(args) >= 2):
        m_per = int(sys.argv[0])
        p_per = int(sys.argv[1])
        if(len(args) >= 4):
            m_exc = int(sys.argv[2])
            p_exc = int(sys.argv[3])
            if(len(args) >= 5):
                delta = float(sys.argv[4])
                if (delta < 1.0):
                    sys.exit(
                        "ValueError: Delta should be a positive integer greater or equal to 1")
                else:
                    delta = round(delta)

    elif ((len(args) == 3) | (len(args) == 1)):
        sys.exit(
            "Error: Detected a single percentage when expecting a couple per case.")

    pers = c_range(m_per, p_per, m_exc, p_exc, delta)
    points_up, points_down = readfile(path)
    curves_up = spline_fitting_over_range(points_up, pers)
    curves_down = spline_fitting_over_range(points_down, pers)
    DIRS = organizer(pers,curves_up,curves_down,f"{ABS_PATH}r_{pers[0]}_{pers[-1]}")
    
    with open(f"{ABS_PATH}r_{pers[0]}_{pers[-1]}/DIRS.dat","w") as file:
        file.write(DIRS)



    # print(outer_bounds)
