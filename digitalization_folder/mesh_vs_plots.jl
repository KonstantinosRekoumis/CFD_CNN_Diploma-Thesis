using Plots
pgfplotsx()
# using LaTeXStrings

using JSON
using FileIO
using DelimitedFiles

# --- NeuralNet realated modules --------
# using Flux
# using CUDA
# using BSON:@load

include("./digit_mods.jl")
using .digit_mods 

# EPIC COLOR PALLETTE
col = [RGB(i) for i in [0x00ab9f,0x7409b7,0xd2cf00,0xff6f00] ] # mah precious colors

# DATA LOADING

data = readdlm("./digitalization_folder/exp_points.csv",',')

# println(data)
# println(typeof(data["exp_up"]),"\n",data["exp_up"])
# println(digit_mods.interpolate([0.1 0.5;0.3 0.25], exp_up"]),"\n",data["exp_up"])[0.15,0.2]))

exp_down = str_el([data[2:end,1],data[2:end,2]],concat=true)
exp_up = str_el([data[2:end,3],data[2:end,4]],concat=true)
x = str_el([data[2:end,5]],concat=false)

int_down = interpolate(exp_down,x)
int_up = interpolate(exp_up,x)

meshlm = Array{Float32}(undef,(2,49)) 
mesh1  = Array{Float32}(undef,(2,49))
nasa   = Array{Float32}(undef,(2,49))

popul("/home/freshstart/Dropbox/DTC/testRAE/",meshlm)
popul("/home/freshstart/DiplomaThesisData/RAE_2822_baseline1/",mesh1)
popul("/home/freshstart/DiplomaThesisData/RAE_2822_baseline/",nasa)

m_delta_up =   [[100*abs(int_up[i]-meshlm[1,i])/maximum([abs(i) for i in int_up]) for i in 1:length(x)],
                [100*abs(int_up[i]-mesh1[1,i])/maximum([abs(i) for i in int_up]) for i in 1:length(x)],
                [100*abs(int_up[i]-nasa[1,i])/maximum([abs(i) for i in int_up]) for i in 1:length(x)]]
m_delta_down = [[100*abs(int_down[i]-meshlm[2,i])/maximum([abs(i) for i in int_down]) for i in 1:length(x)],
                [100*abs(int_down[i]-mesh1[2,i])/maximum([abs(i) for i in int_down]) for i in 1:length(x)],
                [100*abs(int_down[i]-nasa[2,i])/maximum([abs(i) for i in int_down]) for i in 1:length(x)]]
delta_up =     [[100*(int_up[i]-meshlm[1,i])/int_up[i] for i in 1:length(x)],
                [100*(int_up[i]-mesh1[1,i])/int_up[i] for i in 1:length(x)],
                [100*(int_up[i]-nasa[1,i])/int_up[i] for i in 1:length(x)]]
delta_down =   [[100*abs(int_down[i]-meshlm[2,i])/int_down[i] for i in 1:length(x)],
                [100*abs(int_down[i]-mesh1[2,i])/int_down[i] for i in 1:length(x)],
                [100*abs(int_down[i]-nasa[2,i])/int_down[i] for i in 1:length(x)]]


up=plot(title="Cp distribution divegence from the experiment for the top face [%]",
        ylabel="%",yguidefontrotation=-90,xlabel="x-axis normalized",minorgrid=true)
# plot!(up,x[2:end],delta_up[1][2:end],c=col[2],label="Mesh #1")
plot!(up,x[2:end],m_delta_up[2][2:end],c=col[1],label = "Mesh #2")
plot!(up,x[2:end],m_delta_up[3][2:end],c=col[4],label = "NASA Mesh")
plot!(up,[0],[0],c=RGB(0xffffff),label = L"\frac{|Cp_{Mesh\ i} - Cp_{exp\ i}|}{max(|Cp_{exp}|)}")
plot!(up,[0],[0],c=RGB(0xffffff),label = " ")

bot=plot(title="Cp distribution divegence from the experiment for the bottom face [%]",
        ylabel="%",yguidefontrotation=-90,xlabel="x-axis normalized",minorgrid=true)
# plot!(bot,x[2:end],delta_down[1][2:end],c=col[2],label="Mesh #1")
plot!(bot,x[2:end],m_delta_down[2][2:end],c=col[1],label = "Mesh #2")
plot!(bot,x[2:end],m_delta_down[3][2:end],c=col[4],label = "NASA Mesh")
plot!(bot,[0],[0],c=RGB(0xffffff),label = L"\frac{|Cp_{Mesh\ i} - Cp_{exp\ i}|}{max(|Cp_{exp}|)}")
plot!(bot,[0],[0],c=RGB(0xffffff),label = " ")

savefig(up,"/home/freshstart/DiplomaThesisData/images/Cp_delta_u.pdf")
savefig(bot,"/home/freshstart/DiplomaThesisData/images/Cp_delta_b.pdf")

_lw=1
s=(800,600)
plt=plot(size=s,legend=:topright,yflip=true,title="Comparison between the different meshes",
        ylabel="Cp",yguidefontrotation=-90,xlabel="x-axis normalized",background=:gray99,
        thickness_scaling=1.5,minorgrid=true)

plot!(plt,exp_up[:,1],exp_up[:,2],color=col[4],lw=_lw,line=:dot ,label="exp top side")
plot!(exp_down[:,1],exp_down[:,2],color=col[4],line=:dash,lw=_lw,label="exp bottom side")
#----------------
plot!(x,meshlm[1,:],color=col[2],lw=_lw,line=:dashdot ,label="Mesh #1 top side")
plot!(x,meshlm[2,:],color=col[2],lw=_lw,label="Mesh #1 bottom side")
#---------------
plot!(x,nasa[1,:],color=col[1],lw=_lw,line=:dashdot ,label="NASA mesh top side")
plot!(x,nasa[2,:],color=col[1],lw=_lw,label="NASA mesh top side")
#---------------
plot!(x,mesh1[1,:],color=col[3],lw=_lw,line=:dashdot ,label="Mesh #2 top side")
plot!(x,mesh1[2,:],color=col[3],lw=_lw,label="Mesh #2 bottom side")
savefig(plot!(),"/home/freshstart/DiplomaThesisData/images/Meshes_versus.pdf")

# plot!(x,mesh1[1,:],c=col[2])
# plot!(x,mesh1[2,:],c=col[2])
# plot!(x,int_down,c=col[3])
# plot!(x,int_up,c=col[3])
