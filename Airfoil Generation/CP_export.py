import sys


# open the file
if (len(sys.argv)==2):
    filename = sys.argv[1]
else:
    print("Enter the file\'s full path:")
    savename = input()

list = filename.split("/")
list.pop()
index = list[-1]
list = [f"{list[i]}/" for i in range(len(list))]
savename = ""
savename=savename.join(list)
savename_u = savename+f"Cp_RAE_up_var.dat"
savename_d = savename+f"Cp_RAE_down_var.dat"


with open(filename,"r") as file:
    input=file.readlines()

xc=[]
yc=[]
cp=[]

for line in input :
    # print(line)
    data = []
    line=line.replace(" "," ? ") #EPIC SPACES Manipulation
    line = line.split("?")
    for item in line:
        if not((item ==" ")or(item == "  ")):# exclude the single or double spaces strings
                data.append(item)
    # x y z cp ? ?
    xc.append(float(data[0]))
    yc.append(float(data[1]))
    cp.append(float(data[3]))
    # if len(xc)<30:
    #     print(data)
    #     print(f"{xc[-1]} {yc[-1]} {cp[-1]}")
M=10
i_min = 1
for m in range(len(xc)-1):
    if xc[m] < M:
        M=xc[m]
        i_min = m

M= -10
i_max = 1
for m in range(len(xc)-1):
    if xc[m] > M:
        M=xc[m]
        i_max = m


intervals = [0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.41,0.42,0.43,0.44,0.45,0.46,0.47,0.48,0.49,0.5,0.51,0.52,0.53,0.54,0.55,0.56,0.57,0.58,0.59,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.96,0.97,0.98,0.99,1]

data = []
CP_up=[]
CP_down=[]
for i in intervals:
    data=[]
    # print("-----------\n",i)
    for j in range(len(xc)-1):
        if ((i >= xc[j])and(i <= xc[j+1]))or((i <= xc[j])and(i >= xc[j+1])):
            data.append([cp[j],yc[j],xc[j]])
            # print(f"------- {xc[j]} {i}")
        elif(min(xc) >= i):
            data.append([cp[i_min],yc[i_min],xc[i_min]])
            break
        elif(max(xc) <=i):
            data.append([cp[i_max],yc[i_max],xc[i_max]])
            break
    # print(data)
    if len(data)>=2:
        if data[0][1]>=data[1][1]:
            CP_up.append(data[0])
            CP_down.append(data[1])
        elif data[0][1]<data[1][1]:
            CP_up.append(data[1])
            CP_down.append(data[0])
    else:
        #singular points near the 2 edges
        CP_up.append(data[0])
        CP_down.append(data[0])
    if len(data) >= 3:
        print(">3 ",i)


with open(savename_u,'w') as file:
    for i in CP_up:
        file.write(f"{i[0]}\n")

with open(savename_d,'w') as file:
    for i in CP_down:
        file.write(f"{i[0]}\n")

print("--------------------------")
[print(f"{CP_up[i][2]} {CP_up[i][0]} {CP_down[i][0]}") for i in range(len(CP_up))]
print("--------------------------")
