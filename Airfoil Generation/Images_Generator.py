# import SDF_module as sdf #legacy changed in (1/6/2021)
import numpy as np
import os
import sys
import matplotlib.pyplot as plt
import csv
import shutil
#Alteration @ 1/6/2021 : Moved the SDF_module code here as i reckon it would be way
#slower and more complicated to work with multiple modules and there was no point
#to hold the module as it required no more work to be done.
def grid_con(Nx,Ny):
        x = np.linspace(-0.1,1.1,Nx)
        y = np.linspace(-0.15,0.15,Ny)
        grid = np.zeros((1,2))
        grid =np.meshgrid(x,y)
        return grid

def sdf_map(geometry,grid): #needs refining
        # The grid is imported as a meshgrid
        # The geometry is imported as 2D array
        # The function exports a 2D surface grid
        try:
            GRID_SDF = np.empty(grid[0].shape)
            for ii in range(GRID_SDF.shape[0]): #rows
                    for jj in range(GRID_SDF.shape[1]):#columns
                            k = 1e+10
                            v = 1
                            for ll in range(len(geometry)):
                                    sdf = np.sqrt((grid[0][ii,jj]-geometry[ll,0])**2+(grid[1][ii,jj]-geometry[ll,1])**2)
                                    if sdf < k :
                                            k = sdf
                                            pos = ll
                            if((grid[0][ii,jj]>=0) & (grid[0][ii,jj]<=1)):
                                if((abs(grid[1][ii,jj]) <= abs(geometry[pos,1]))):
                                        #standard geometry
                                        v=-1 #multiplier for point in geometry
                                        # print((grid[0][ii,jj],grid[1][ii,jj])," point ", geometry[pos,:])
                                elif((ll > int(len(geometry)/2)) & (grid[1][ii,jj]>=geometry[pos,1]) & (grid[1][ii,jj]<=geometry[pos-int(len(geometry)/2),1])):
                                        # close to trailing edge there are some areas where the underside of the airfoil gains positive y-coordinates
                                        v=-1 #multiplier for point in geometry
                                        # print((grid[0][ii,jj],grid[1][ii,jj])," point ", geometry[pos,:])
                            GRID_SDF[ii,jj]=k*v # Magnitude assignment to each node
            return GRID_SDF
        except:
            print(len(geometry))

#---------------------------------------------------------------------------------------------------------------------------

def image_generator(geometry,file_name,Pxx,Pxy,directory="",export_csv=False,showplot=False,showcontours = False):
    """The method image_generator is used to create the image data needed as input for any kind of training and validation attempt.
    The method uses as inputs the geometry that we want to approximate with SDF and then export it in an image according to the Pxx
    pixels along the x axis and Pxy pixels along the y axis. The file_name has arguements about the directory where the image would be saved, its name and finally
    the image type. Preferably the image shall be stored as an png (ie. C:/CustomDir/image_name.png). Optional arguments are the export_csv in order to export image data to csv file,
    showplot in order to plot the sdf image and showcontours to plot a clear contour plot of the SDF image for troubleshooting."""
    #----------------- GRAPHIC GRID CREATION ------------------------
    grid = grid_con(Pxx,Pxy)
    colormap = sdf_map(geometry,grid)
    if(export_csv):
        #------ EXPORTING THE IMAGE DATA IN CSV ------------------------
        file = open(directory+"image_data.csv",'w')
        file_writer = csv.writer(file,dialect = "excel",lineterminator = '\n')#=delimiter=',',quotechar='"',quoting=csv.QUOTE_MINIMAL)
        for ii in range(colormap.shape[0]):
            file_writer.writerow(colormap[ii,:])
        file.close()
        #-------------------------------------------------------------
    if(showcontours):
        fig = plt.figure()
        plt.plot(geometry[:,0],geometry[:,1],'k*')
        c_plot=plt.contour(grid[0],grid[1],colormap, 30, cmap='jet')
        plt.clabel(c_plot, inline=True, fontsize=8)
        plt.colorbar();
        plt.show()

    fig,ax = plt.subplots()
    plt.imshow(colormap,extent = [-0.1,1.1,-0.15,0.15],
                    origin = 'lower', cmap = 'jet',aspect='auto')
    ax.axis("off")
    # plt.savefig("SDF_test.png",bbox_inches='tight',pad_inches =0)
    plt.imsave(directory+file_name,colormap,cmap='jet')
    if(showplot):plt.show()
    plt.close()


def ImageDatabase(_directory,file):
    """ The generator's purpose is to generate the images needed to train and test
        the Neural Netwotrk. This program will create a Directory to store the images
        and give each one of them a unique name."""
    #------ BASIC DATA INITIALIZATION --------
    GEOM = np.zeros((1,2))
    contents = np.empty((1,2))
    isOneParsed = False
    isZeroParsed = False
    FirstElement= True
    #--------------------------------------------
    i=1
    for line in file:
        if (("variant" in line)|("- EOF -" in line)):
            #when changing variant it is expected to "soft reset" the
            #reading algorithm
            if not("- EOF -" in line):
                name = int(line.split(".")[1].split('\n')[0]) # hold the variant No.
            else:
                name = name+1
            if not(FirstElement): #when the next variant start is found call the image_generator()
                GEOM = np.delete(GEOM,0,0)
                name = (name-1)
                image_generator(GEOM,(f"RAE_var.png"),32,32,directory=_directory,showplot=False,showcontours = False)
                # image_generator(GEOM,(f"RAE_var # {name}.png"),32,32,directory=_directory)
                print(f"Airfoil variant {name} \'s SDF image has been stored @ {_directory}.")
            elif(FirstElement):
                FirstElement=False
                continue
            GEOM = np.zeros((1,2))
            contents = np.empty((1,2))
            isOneParsed = False
            isZeroParsed = False
        elif (("#up" in line) | ("#down" in line)):
            continue
        else:
            text = line.split(' ')
            if(("1.0000" in text[1]) & ~isOneParsed): isOneParsed = True
            elif(("1.0000" in text[1]) & isOneParsed): continue
            if(("0.0000" in text[1]) & ~isZeroParsed): isZeroParsed = True
            elif(("0.0000" in text[1]) & isZeroParsed): continue
            contents[0,0]=float(text[0])
            contents[0,1]=float(text[1].split('\n')[0]) # ie '6.605880231510667e-20\n' -> ['6.605880231510667e-20', '']
            GEOM = np.append(GEOM,contents,axis=0)

if("__main__"==__name__):
    # open the file
	if (len(sys.argv)>=2):
		filename = sys.argv[1]
	else:
		print("Enter the input .geom file:")
		filename = input()

	directory = filename.split("/")
	directory.pop()
	directory = [f"{directory[i]}/" for i in range(len(directory))]
	directory = "".join(directory)


	try:
		file = open(filename,"r")
		print("File %s exists." %filename)
		lines=file.readlines()
		file.close()
	except:
		print("File %s doesnot exist." %filename)

	ImageDatabase(directory,lines)
