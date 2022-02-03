import sys

# open the file
if (len(sys.argv)==2):
    filename = sys.argv[1]
else:
    filename = 'node.geom'

list = filename.split("/")
list.pop()
list = [f"{list[i]}/" for i in range(len(list))]
savename = ""
savename=savename.join(list)
savename += "RAE_2822.geom"

#indexing array
index = []
raw_index = []
index_points =[]
#----------------------------------------------------------------------------------------
#------------- MAIN INPUT SECTION -------------------------------------------------------
file=open(filename,'r')
lines=file.readlines()

for line in lines :
    # print(line)
    data = []
    line=line.replace(" "," ? ") #EPIC SPACES Manipulation
    line = line.split("?")
    for item in line:
        if not((item ==" ")or(item == "  ")):# exclude the single or double spaces strings
                data.append(item)
    #parsing the data string array
    id =data[0]
    x_co=data[1]
    y_co=data[2]
    try:
        id = int(id)
        raw_index.append(id) #save the original mesh nodes' order
        x_co = float(x_co)
        y_co = float(y_co)
        # print("GOOD",id , x_co,y_co)
    except:
        print("ERROR",id , x_co,y_co)
        break
    #Check whether the current node already exists in the id list
    if not(id in index):
        #if it doesnot exist then based on the id it must be put to the correct position
        #if the node id is greater than the maximum that has been encountered then
        #append
        if (len(index)==0)or(id > max(index)):
            index.append(id)
            index_points.append([x_co,y_co])
        #if less than maximum then search the list to find its place
        elif(id < max(index)):
            for i in range(len(index)-1):
                if((id>index[i])and(id<index[i+1])):
                    index.insert(i,id)
                    index_points.insert(i,[x_co,y_co])
                    break
    else:continue
#----------------------------------------------------------------------------------------
#------------- FILTERING AND SORTING SECTION --------------------------------------------
data = []
co = len(index)
#Sorting the points according to asceding x-coordinate
for i in range(co):
    # if i == 10:break
    if (i==0)or(index_points[i][0] >= max([data[k][1] for k in range(len(data))])):
        data.append([index[i],index_points[i][0],index_points[i][1]])
    elif(index_points[i][0] < max([data[k][1] for k in range(len(data))])):
        for j in range(len(data)):
            if((index_points[i][0]<data[j][1])):
                data.insert(j,[index[i],index_points[i][0],index_points[i][1]])
                break
#Sorting the points in order to move the underside points to the back of the array
while True:
    e=0
    for i in range(co-1):
        if(data[i][2]<0)and(data[i+1][2]>0):
            e+=1
            x = data.pop(i)
            data.insert(i+1,x)
        elif(data[i][2]<0)and(data[i+1][2]<0)and(data[i][1]>data[i+1][1]):
            e+=1
            x = data.pop(i)
            data.insert(i+1,x)
    if e==0:break
#Filtering the underside points near the trailing edge
for i in range(int(co/2)+2):
    if ((data[i][2]-data[i+1][2])>(data[i][2]-data[i+2][2]))and((data[i][2]>0)and(data[i+1][2]>0))and(data[i][2]>data[i+2][2]):
        x = data.pop(i+1)
        data.insert(i+int(co/2),x)#shifting the points to the bottom side ie. moving them at the back half of the array
#Sorting the trailing edge points as the number of points are not uniform among the bottom and upper sides
#thus the sorted points from the above step are not inserted with the proper order across x-axis
while True:
    e=0
    for i in range(co-int(co/4),co-1):
        if data[i][1]>data[i+1][1]:
            e+=1
            x = data.pop(i)
            data.insert(i+1,x)
    if e==0:break
#----------------------------------------------------------------------------------------
#------------- DATA EXPORT SECTION ------------------------------------------------------
print(savename)
file = open(savename,"w")
file.write(f"{co}\n")
for i in range(co):
    file.write(f"{data[i][0]} {data[i][1]} {data[i][2]}\n")
file.close()
#----------------------------------------------------------------------------------------
