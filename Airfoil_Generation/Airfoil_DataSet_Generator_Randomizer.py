import matplotlib.pyplot as plt
import numpy as np
import scipy.interpolate as spln
import pyDOE as pd
import matplotlib.animation as anime
import sys
import Images_Generator as ig
import shutil
import os
"""
Airfoil_DataSet_Generator_Randomizer.py
---------------------------------------------
This program is used to create a full Database of airfoil variants based on the RAE-2822 airfoil.
The program requires from the user to enter the mother foil's data as an ASCII or UTF-8 text base format
along with its full directory and the target directory where all the data would be stored. An optional argument
is to enter '-v' after the obligatory arguments in order to get a visual representation of the Database
that was created.
This code shall be used only once per batch as there is no control over the random pattern ganeration
and any new results may not be the same as the old ones.


revision 1: Altered the text data export to facilitate the deformation of the grids and charged this
			program with the duty of creating the proper data structure to hold the variants' .geom files
			and their respective sdf format images. (6/2021)

Developed by Konstantinos Rekoumis 12/2020 (School of Naval and Marine Engineering NTUA)
"""
#------------- Functions definitions -----------------------------------
def randomizer_ControlPoints(tck,n):
	#inputs are the knotvector , Control Points, the splines grade and the number of samples need to be created
	kn=tck[0]
	CP=np.array(tck[1])
	k=tck[2]
	s1 = pd.lhs(n,samples = 1)
	s=[-0.2+0.4*x for x in s1[0,:]]
	CP_temp = []

	TCK = []

	for i in range(n):
		for j in range(len(CP[0])):
			CP_temp.append((1+s[i])*CP[1,j])

		TCK.append([kn,[CP[0,:],CP_temp],k])
		CP_temp =[]

	return TCK

def spline_fitting(points,samples,k=3,s=0):
	# ------- B-spline preping ----------
	tck,u = spln.splprep([points[:,0],points[:,1]],k=3,s=0)
	# ----- Control Points Manipulation--------
	CP = np.array(tck[1])
	TCK=randomizer_ControlPoints(tck,samples)
	# ------- B-splines fitting ----------
	# u = np.linspace(0,1,100)
	splines = [spln.splev(u,TCK[i]) for i in range(samples)]
	return splines

def ran_plot(i):
	if i<samples:
		line1.set_ydata(up_sides[i][1])
		line2.set_ydata(down_sides[i][1])

	return line1, line2,




#----------------------------------------------------------------------------

if("__main__"==__name__):
	#---------- Open the airfoil file for data entry ----------------------------
	#------ RAE 2822 via Online data (Legacy still working tho) -----------------
	# points_up = np.zeros((1,2),dtype="float")
	# points_down = np.zeros((1,2),dtype="float")
	# vv="down"
	# samples = 500
	# data = open("RAE_2822.txt")
	# for line in data:
	# 	if ('0' in line):
	# 		bits=line.split(' ') #text separation
	# 		bits[2]=bits[2].split('\n')[0] #newline char trim
	# 		if (("0.000000" == bits[1]) & ("0.000000" == bits[2]) & (vv!="down")): vv ="down"
	# 		elif(("0.000000" == bits[1]) & ("0.000000" == bits[2]) & (vv=="down")): vv ="up"
	# 		if (vv == "up"):
	# 			points_up=np.append(points_up,[[float(bits[1]),float(bits[2])]],axis=0)
	# 		else:
	# 			points_down=np.append(points_down,[[float(bits[1]),float(bits[2])]],axis=0)
	#
	# #getting rid of the zeros of the initialization
	# points_up=np.delete(points_up,0,0)
	# points_down=np.delete(points_down,0,0)
	#------ RAE 2822 via mesh points sorting (New) --------------------------------
	if (len(sys.argv)>=2):
		input = sys.argv[1]
		if(len(sys.argv)==3):
			directory = sys.argv[2]
		else:
			print("Enter the Database destination directory:")
			directory = input()
	else:
		print("Enter the Mother Foil\'s .geom file name:")
		input = input()

	points_up = np.zeros((1,2),dtype="float")
	points_down = np.zeros((1,2),dtype="float")
	vv="up"
	samples = 1500
	index = []

	data = open(input,"r")
	lines=data.readlines()
	lines.pop(0)#first line usefull only for MaPFlow
	for line in lines:
		bits=line.split(" ")
		index.append(bits[0])
		if (points_up[-1,1]>0)and(float(bits[2])<0):vv="down"
		if vv=="up":
			points_up=np.append(points_up,[[float(bits[1]),float(bits[2])]],axis=0)
		elif vv=="down":
			points_down=np.append(points_down,[[float(bits[1]),float(bits[2])]],axis=0)

	#appointing the spline end points
	points_up=np.append(points_up,[[1.0,0.0]],axis=0)
	points_down=np.append(points_down,[[0.0,0.0]],axis=0)
	points_up=np.delete(points_up,0,0)
	# points_down=np.delete(points_down,0,0)

	up_sides=spline_fitting(points_up,samples)
	down_sides=spline_fitting(points_down,samples)
	#------------------------------------------------
	# # ------ Visualising Area ------------
	if (len(sys.argv)==4)and(sys.argv[3] == "-v"):
		fig = plt.figure()
		plt.plot(points_up[:,0],points_up[:,1],"ro")
		plt.plot(points_down[:,0],points_down[:,1],"b*")

		fig2 = plt.figure()
		for i in range(samples):
			plt.plot(up_sides[i][0],up_sides[i][1])
			plt.plot(down_sides[i][0],down_sides[i][1])

		fig1,ax=plt.subplots()
		line1,=ax.plot(up_sides[0][0],up_sides[0][1])
		line2,=ax.plot(down_sides[0][0],down_sides[0][1])
		plt.axis([-0.1,1.1,-0.5,0.5])
		animation=anime.FuncAnimation(fig1,ran_plot,blit=False)
		plt.show()
	#----------- Data Export -----------------
	# # windows test mode----------------------------------
    # directory = "C:\\AA_NeuralNetwork_ImagesFolder\\"
    # train = "train\\"
    # test = "test\\"
    # Linux mode --------------------------
    # directory = "~/DiplomaThesisData/"
	train ="train/"
	test ="test/"
	DIRS = ""
    #Create ROOT Directory
	try:
		os.mkdir(directory)
		print(f"The directory: {directory} has been made.")
	except:
		print(f"The directory: {directory} already exists.")
	try:
		os.mkdir(directory+train)
		print(f"The directory: {directory+train} has been made.")
	except:
		print(f"The directory: {directory+train} already exists.")
	try:
		os.mkdir(directory+test)
		print(f"The directory: {directory+test} has been made.")
	except:
		print(f"The directory: {directory+test} already exists.")

	for i in range(samples):
		dir =""
		if i < int(2*samples/3):
			dir = f"{directory+train}#_{i}/"
		elif i >= int(2*samples/3):
			dir = f"{directory+test}#_{i}/"
		try:
			os.mkdir(dir)
		except:
			shutil.rmtree(dir,ignore_errors=True)
			os.mkdir(dir)
		DIRS += f"{dir}\n"
		# lines=""
		text=[f"#variant no.{i}\n"]
		for j in range(0,len(up_sides[i][0])-1):
			# lines += f"{index[j-1]} {up_sides[i][0][j]} {up_sides[i][1][j]}\n"
			text.append(f"{up_sides[i][0][j]} {up_sides[i][1][j]}\n")
		for j in range(1,len(down_sides[i][0])-1):
			# lines += f"{index[j+len(up_sides[i][0])-3]} {down_sides[i][0][j]} {down_sides[i][1][j]}\n"
			text.append(f"{down_sides[i][0][j]} {down_sides[i][1][j]}\n")
		# lines+="----------- EOF ---------------------"
		text.append("----------- EOF ---------------------")

		#data export as var.geom file for use with grid manipulation
		with open((dir+f"var.geom"),'w') as file:
			# file.write(lines)
			for line in text:
				file.write(line)

		#image data export
		ig.ImageDatabase(dir,text)
	with open("/home/freshstart/DiplomaThesisData/DIRS",'w') as file:
		file.write(DIRS)
