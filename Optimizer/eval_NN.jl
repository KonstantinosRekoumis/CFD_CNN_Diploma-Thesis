using Flux,CUDA,Images,BSON

loadModelsGPU = (path;top="model-up.bson",down="model-down.bson") -> (
    filename = path*top;
    up = BSON.load(filename) ;
    model_up = up ;
    filename = path*down;
    down = BSON.load(filename) ;
    model_down = down;    
    return model_up,model_down)

function calc_one(image,model_up,model_down)
    image = image #|> gpu
    y_up= model_up(image)
    y_down= model_down(image)
    y_up = y_up #|> cpu
    y_down = y_down #|> cpu
    return y_up,y_down
end

function NN_eval(path_NN, path_im)
    x = [0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.41,0.42,0.43,0.44,0.45,0.46,0.47,0.48,0.49,0.5,0.51,0.52,0.53,0.54,0.55,0.56,0.57,0.58,0.59,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.96,0.97,0.98,0.99,1]
    a = loadModelsGPU(path_NN)
    CNN_C5_up = a[1][:md] #|> gpu
    CNN_C5_down = a[2][:md] #|> gpu

    #---- Image Loading ----
    FF=Array{Float32}(undef,(32,32,3,1))
    #--- image loading-----
    beep = path_im
    image = load(beep) 
    image = channelview(image) #CWH not WHC ie. 3X32X32
    Channels,Width,Height=size(image[:,:,:])
    for C = 1:Channels-1,W = 1:Width,H = 1:Height
        FF[W,H,C,1] = image[C,W,H] #Switching from CWH to WHCN
    end
    up,down=calc_one(FF,CNN_C5_up,CNN_C5_down)
    up = hcat(x,up)
    down = hcat(x,down)
    return up, down
end

