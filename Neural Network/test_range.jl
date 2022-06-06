using Flux
using Statistics
using CUDA
using Plots
using BSON
using Images
using FileIO
using LaTeXStrings
using DelimitedFiles
gr()
col = [RGB(i) for i in [0x00ab9f,0x7409b7,0xd2cf00,0xff6f00] ] # mah precious colors

loadModelsGPU = (path;top="model-up.bson",down="model-down.bson") -> (
    filename = path*top;
    up = BSON.load(filename) ;
    model_up = up ;
    filename = path*down;
    down = BSON.load(filename) ;
    model_down = down;    
    return model_up,model_down)

function calc_one(image)
    image = image 
    y_up=CNN_C5_up(image)
    y_down=CNN_C5_down(image)
    y_up = y_up |> cpu
    y_down = y_down |> cpu
    return y_up,y_down
end

a = loadModelsGPU("/home/freshstart/DiplomaThesisData/NeuralNetSaves_050/")
CNN_C5_up = a[1][:md] |> gpu
CNN_C5_down = a[2][:md] |> gpu

data_pth = "/home/freshstart/DiplomaThesisData/r_-50_50/"
io = open(data_pth*"DIRS.dat","r") 
dirs=readlines(io)
close(io)



#TRAINING IMAGES LOADING
N = size(dirs)[1] #training batch dynamically allocated to the training batch size
L = 49 #points of interest on the airfoil geometry per side

images = Array{Float32}(undef,(32,32,3,N));
Points_Cp_up = Array{Float32}(undef,(L,N));
Points_Cp_down = Array{Float32}(undef,(L,N));
pers = Array{Float16}(undef,(1,N));




n = 1
@time for airfoil in dirs
    #--- image loading-----
    image = load(airfoil*"RAE_var.png") 
    image = channelview(image) #CWH not WHC ie. 3X32X32
    Channels,Width,Height=size(image[:,:,:])
    for C = 1:Channels-1,W = 1:Width,H = 1:Height
        images[W,H,C,n] = image[C,W,H] #Switching from CWH to WHCN
    end
    #-----------------------
    pers[1,n] = parse(Float16,replace(replace(replace(airfoil, data_pth=>""),"/"=>""),"%"=>""))
    #----- Cp data loading--
    
    file = open(airfoil*"Cp_RAE_up_var.dat")
    lines=readlines(file);
    num=[]
    for i in 1:length(lines)
        push!(num,parse(Float32, lines[i]))
    end
    Points_Cp_up[:,n]=num    
    close(file)
    
    file = open(airfoil*"Cp_RAE_down_var.dat")
    lines=readlines(file);
    num=[]
    for i in 1:length(lines)
        push!(num,parse(Float32, lines[i]))
    end
    Points_Cp_down[:,n]=num    
    close(file)

    n +=1
#     break
end

#-- Converting the data arrays to Cuda Arrays to be processed by the gpu
images = images |> gpu;


c = Array{Float32}(undef,(2,N))
x = [0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.41,0.42,0.43,0.44,0.45,0.46,0.47,0.48,0.49,0.5,0.51,0.52,0.53,0.54,0.55,0.56,0.57,0.58,0.59,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.96,0.97,0.98,0.99,1]


# UP =[]
# DOWN = []
for i in 1:N
    UP, DOWN = calc_one(reshape(images[:,:,:,i], (32,32,3,1)))
    c[1,i] = (1-sqrt(Flux.mse(UP,Points_Cp_up[:,i])))*100
    c[2,i] = (1-sqrt(Flux.mse(DOWN,Points_Cp_down[:,i])))*100
end

for i in 1:N
    if (i>1 & i<N)
        if ((pers[1,i-1] < 0) & (pers[1,i] > 0))
            c = hcat(c[:,1:i-1],[NaN;NaN],c[:,i:end])
            pers = hcat(pers[:,1:i-1],[0],pers[:,i:end])
            break
        end
    end
end
# test=plot()
# plot!(test,x,UP)
# plot!(test,x,Points_Cp_up[:,1])

pgfplotsx()
# gr() #Debug Only
plot(   title = "Accuracy plot for airfoils deformed over the original range ",
        xlabel = "Deformation Percentage [%]",
        ylabel = "Accuracy Percentage [%]",
        minorgrid = true)
plot!(pers[1,:],c[1,:],label = "Top side",c = col[4])
plot!(pers[1,:],c[2,:],label = "Bottom side",c = col[2])
savefig("/home/freshstart/DiplomaThesisData/images/Acc_-50_50.pdf")