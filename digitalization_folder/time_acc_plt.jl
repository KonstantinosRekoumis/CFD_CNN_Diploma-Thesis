using Plots
pgfplotsx()
col = [RGB(i) for i in [0x00ab9f,0x7409b7,0xd2cf00,0xff6f00] ] # mah precious colors
using DelimitedFiles
path = "/home/freshstart/DiplomaThesisData/images/"

#---- cpu times ----
cpu_ti = readdlm("cpu_times.dat")
median = (data) -> (s=0;for i in data;s+=i;end;return s/length(data))

cpu = plot(cpu_ti, label = "CPU times",c = col[1],
                title = "CPU time per aifoil variant simulation",
                ylabel = "Time [min]",yguidefontrotation = -90,
                xlabel = "Variant number",xguidefontrotation = 0,)

plot!(cpu,[0,length(cpu_ti)],[median(cpu_ti),median(cpu_ti)],
        label = "Median CPU time value",c = col[4])
savefig(cpu,path*"cpu_times.pdf")

println("Median time per airfoil = ",median(median(cpu_ti)))