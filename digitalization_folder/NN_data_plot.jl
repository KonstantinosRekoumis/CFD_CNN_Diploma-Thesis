using Plots
pgfplotsx()
plotly()
# gr()
col = [RGB(i) for i in [0x00ab9f,0x7409b7,0xd2cf00,0xff6f00] ] # mah precious colors
using DelimitedFiles

path = "/home/freshstart/DiplomaThesisData/"

median = (data) -> (s=0;for i in data;s+=i;end;return s/length(data))

function dataloader(data)
    a = data[2:end,1]
    b = data[2:end,2]
    c = data[2:end,3]
    d = data[2:end,4]
    time = data[2:end,5:end]
    return a,b,c,d, time
end

function Σum(data)
    sum = 0
    for j in data
        sum += j
    end
    return sum
end

function PLOTS_COMB(data,bs; save = true)
    
    acc_up,  acc_down, vld_up, vld_down, time = dataloader(data)




    plot(   acc_up,  label="training loss top face",        c=col[1])
    plot!(  vld_up,  label="verification loss top face",    c=col[4])
    plot!(  acc_down,label="training loss bottom face",     c=col[2])
    plot!(  vld_down,label="verification loss bottom face", c=col[3])
    plot!( yscale=:log10,
        minorgrid =true,
        minortick=true,
        xlabel= "Epochs", 
        ylabel= "Mean Square Error", yguidefontrotation = -90,
        title="Training and verification loss\n Batch Size = $bs",
        legend= :topright,size=(1000,9/16*1000))
    ylims!((0.9*minimum((minimum(acc_up),minimum(acc_down),minimum(vld_up),minimum(vld_down))),1e-2))
    save ? (display(plot!());savefig(path*"images/Convergence_NN_bs_$bs.pdf")) : display(plot!())



    labels=["training top side","validation top side","training bottom side","validation bottom side"]
    plot(title="Neural Networks\' timelog\n Batch Size = $bs",xlabel = "Epochs",ylabel="Time [ms]"
    , yguidefontrotation = -90,minorticks = true,)
    sum = 0
    for i in 1:4
        plot!(time[2:end,i]*1000,label = labels[i], c =col[i])
        for j in time[:,i]
            sum+=j
        end
    end
    
    sum /= 60
    sum = round(sum,digits = 1)
    plot!(time[2:3],c = RGB(0xFFFFFF), label = "Total training and")
    plot!(time[2:3],c = RGB(0xFFFFFF), label = "validation time = $sum mins")
    save ? (display(plot!());savefig(path*"images/Time_NN_bs_$bs.pdf")) : display(plot!())
end

function c_avg(data;sp=1 ::Int ,ep = 1 ::Int)
    (sp > ep)&(ep != 1) ? error("Start point cannot be greater than end point.") : 
    ep == 1 ? a = data[sp:end] : a = data[sp:ep]

    sum = 0
    for i in a 
        sum += i
    end
    return sum/length(a)
end


function AveragePerStep(data,bs,step)
    acc_up, acc_down, vld_up, vld_down, time = dataloader(data)

    
    avg_acc_up   = [c_avg(acc_up  ,sp = i-step+1, ep = i )  for i in range(step,length(acc_up  ),step = step)]
    avg_vld_up   = [c_avg(vld_up  ,sp = i-step+1, ep = i )  for i in range(step,length(vld_up  ),step = step)]
    avg_acc_down = [c_avg(acc_down,sp = i-step+1, ep = i )  for i in range(step,length(acc_down),step = step)]
    avg_vld_down = [c_avg(vld_down,sp = i-step+1, ep = i )  for i in range(step,length(vld_down),step = step)]
    x = [i*step for i in 1:length(avg_acc_up)]

    plot( x, avg_acc_up,  label="averaged training loss top face"       ,c=col[1])
    plot!(x, avg_vld_up,  label="averaged verification loss top face"   ,c=col[4])
    plot!(x, avg_acc_down,label="averaged training loss bottom face"    ,c=col[2])
    plot!(x, avg_vld_down,label="averaged verification loss bottom face",c=col[3])
    plot!(  yscale=:log10,
            minorgrid =true,
            minortick=true,
            xlabel= "Epochs",
            ylabel= "Mean Square Error", yguidefontrotation = -90,
            title="Training and verification loss averaged per $step Epochs \n Batch Size = $bs ",
            legend= :topright,size=(1000,9/16*1000))
    ylims!((0.9*minimum((minimum(acc_up),minimum(acc_down),minimum(vld_up),minimum(vld_down))),1e-2))
    display(plot!())  
return avg_acc_up, avg_vld_up, avg_acc_down, avg_vld_down
end

data_025 = readdlm(path*"NeuralNetSaves/MSEsTime.dat")
data_050 = readdlm(path*"NeuralNetSaves_050/MSEsTime.dat")
data_100 = readdlm(path*"NeuralNetSaves_100/MSEsTime.dat")
data_150 = readdlm(path*"NeuralNetSaves_150/MSEsTime.dat")
data_200 = readdlm(path*"NeuralNetSaves_200/MSEsTime.dat")

PLOTS_COMB(data_025,025,save=false)
# PLOTS_COMB(data_050[1:end,:],50,save=false)
# PLOTS_COMB(data_100,100)
# PLOTS_COMB(data_150,150)
# PLOTS_COMB(data_200,200)

step = 40

AveragePerStep(data_025,025,step)
a = AveragePerStep(data_050,050,step)
b = AveragePerStep(data_100,100,step)
c = AveragePerStep(data_150,150,step)
d = AveragePerStep(data_200,200,step)

x = [i*step for i in 1:length(a[1])]
labels=["training top side","validation top side","training bottom side","validation bottom side"]

for i in [1,3]
plot(title = "Comparison between the different Batch Sizes",yaxis = :log10)
plot!(x,a[i], c = col[1], label = labels[i]*" Batch Size = 50")
plot!(x,b[i], c = col[4], label = labels[i]*" Batch Size = 100")
plot!(x,c[i], c = col[3], label = labels[i]*" Batch Size = 150")
plot!(x,d[i], c = col[2], label = labels[i]*" Batch Size = 200")
display(plot!())
# savefig(path*"images/Conv_Comp_BS"*labels[i]*".pdf")
end
plot(title = "Comparison between the different Batch Sizes",)
plot!([Σum(data_050[i,5:end]) for i in 3:length(data_050[2:end,5])], c = col[1], label = "Total Epoch time Batch Size = 50")
plot!([Σum(data_100[i,5:end]) for i in 3:length(data_050[2:end,5])], c = col[4], label = "Total Epoch time Batch Size = 100")
plot!([Σum(data_150[i,5:end]) for i in 3:length(data_050[2:end,5])], c = col[3], label = "Total Epoch time Batch Size = 150")
plot!([Σum(data_200[i,5:end]) for i in 3:length(data_050[2:end,5])], c = col[2], label = "Total Epoch time Batch Size = 200")
display(plot!())
savefig(path*"images/Time_Comp_BS.pdf")

println("Epoch @ Batch Size 50  = ", c_avg([Σum(data_025[i,5:end]) for i in 3:length(data_050[2:end,5])]),"\n", 
        "Epoch @ Batch Size 100 = ", c_avg([Σum(data_100[i,5:end]) for i in 3:length(data_050[2:end,5])]),"\n",
        "Epoch @ Batch Size 150 = ", c_avg([Σum(data_150[i,5:end]) for i in 3:length(data_050[2:end,5])]),"\n",
        "Epoch @ Batch Size 200 = ", c_avg([Σum(data_200[i,5:end]) for i in 3:length(data_050[2:end,5])]),"\n",
)

println("Total time @ Batch Size 50  = ", Σum([Σum(data_050[i,5:end]) for i in 3:length(data_050[2:end,5])])/60,"\n", 
        "Total time @ Batch Size 100 = ", Σum([Σum(data_100[i,5:end]) for i in 3:length(data_050[2:end,5])])/60,"\n",
        "Total time @ Batch Size 150 = ", Σum([Σum(data_150[i,5:end]) for i in 3:length(data_050[2:end,5])])/60,"\n",
        "Total time @ Batch Size 200 = ", Σum([Σum(data_200[i,5:end]) for i in 3:length(data_050[2:end,5])])/60,"\n",
)

