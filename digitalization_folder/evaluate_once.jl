using BSON
using Flux
using Plots
using Images

# EPIC COLOR PALLETTE
col = [RGB(i) for i in [0x00ab9f,0x7409b7,0xd2cf00,0xff6f00] ] # mah precious colors


loadModelsGPU = (path;top="model-up.bson",down="model-down.bson") -> (
    filename = path*top;
    up = BSON.load(filename) ;
    model_up = up ;
    filename = path*down;
    down = BSON.load(filename) ;
    model_down = down;    
    return model_up,model_down)

function calc_one(image,model_up,model_down)
    image = image |> gpu
    y_up= model_up(image)
    y_down= model_down(image)
    y_up = y_up |> cpu
    y_down = y_down |> cpu
    return y_up,y_down
end

a = loadModelsGPU("/home/freshstart/DiplomaThesisData/NeuralNetSaves_050/")
CNN_C5_up = a[1][:md] |> gpu
CNN_C5_down = a[2][:md] |> gpu

# FATHER FOIL RAE-2822 Loading for testing
FF=Array{Float32}(undef,(32,32,3,1))
#--- image loading-----
beep = "/home/freshstart/DiplomaThesisData/RAE_2822_baseline/"
image = load(beep*"RAE_var.png") 
image = channelview(image) #CWH not WHC ie. 3X32X32
Channels,Width,Height=size(image[:,:,:])
for C = 1:Channels-1,W = 1:Width,H = 1:Height
    FF[W,H,C,1] = image[C,W,H] #Switching from CWH to WHCN
end
#-----------------------

#----- Cp data loading--
    
file = open(beep*"Cp_RAE_up_var.dat")
lines=readlines(file);
CP_up=[]
for i in 1:length(lines)
    push!(CP_up,parse(Float32, lines[i]))
end    
close(file)
    
file = open(beep*"Cp_RAE_down_var.dat")
lines=readlines(file);
CP_down=[]
for i in 1:length(lines)
    push!(CP_down,parse(Float32, lines[i]))
end
close(file)

bench = []

@time for i in 1:1000
t=@elapsed up,down=calc_one(FF,CNN_C5_up,CNN_C5_down)
push!(bench,t)
end

sum = 0
for i in bench
    sum+=i
end

println("Average evaluation time = ",sum/length(bench))

up,down=calc_one(FF,CNN_C5_up,CNN_C5_down)
x = [0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.41,0.42,0.43,0.44,0.45,0.46,0.47,0.48,0.49,0.5,0.51,0.52,0.53,0.54,0.55,0.56,0.57,0.58,0.59,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.96,0.97,0.98,0.99,1]
col = [RGB(i) for i in [0x00ab9f,0x7409b7,0xd2cf00,0xff6f00] ] # mah precious colors
pgfplotsx()
plot(title = "Cp distribution between CFD simulation and Neural Net Prediction", yflip = true)
plot!(x,up,label = "CNN prediction distribution",c=col[1])
plot!(x,down,label="",c=col[1])
plot!(x,CP_up,label = "CFD simulation distribution",c=col[4])
plot!(x,CP_down,label="",c=col[4])

loss_up = Flux.mse(up,CP_up)
loss_down = Flux.mse(down,CP_down)