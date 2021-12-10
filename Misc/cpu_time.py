
import matplotlib.pyplot as plt

def median(data):
    sum=0
    for i in data:
        sum += i
    return sum/len(data)


with open("/home/freshstart/DiplomaThesisData/log",'r') as file:
    rundir = file.readlines()
    rundir.pop(0)

data=[]
for dir in rundir:
    d = dir.split('\n')[0]
    d +="total_cputime.dat"
    with open(d,'r') as file:
        lines = file.readlines()

    data.append(float(lines[-1].split(":")[1])/60)

lines = [f"{i}\n" for i in data]
with open("cpu_times.dat","w") as f:
    f.writelines(lines)


fig = plt.figure()
plt.plot(data,label="Time history")
print(median(data))
plt.plot([0,len(data)],[median(data),median(data)],"r-",label="Median time")
plt.title("CPU time per foil")
plt.ylabel("Time [min]")
plt.xlabel("N")
plt.legend()
plt.show()
