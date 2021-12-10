using Plots
pgfplotsx()
# EPIC COLOR PALLETTE
col = [RGB(i) for i in [0x00ab9f,0x7409b7,0xd2cf00,0xff6f00] ] # mah precious colors

using LaTeXStrings
using DelimitedFiles

function nstr(data)
    res = []
    row = []
for j in 1:size(data)[1]
    row = []
    for i in 1:size(data)[2]
        typeof(data[j,i]) <: AbstractString ? continue : push!(row,data[j,i]) 
    end
    j == 1 ? res = transpose(row) : res=vcat(res,transpose(row))
end
    return res    
end

function AbS(data)
    return [abs(i) for i in data]
end

function ΔeltaAB_100(A,B;ABS=false,max=false)
    size(A)[1] != size(B)[1] ? error("A has not the same rows as B") :
    if !max 
        return ABS ? [100*abs((A[i,2]-B[i,2])/B[i,2]) for i in 1:size(A)[1]] : [100*(A[i,2]-B[i,2])/B[i,2] for i in 1:size(A)[1]]
    else 
        return ABS ? [100*abs((A[i,2]-B[i,2])/maximum(AbS(B))) for i in 1:size(A)[1]] : [100*(A[i,2]-B[i,2])/maximum(AbS(B)) for i in 1:size(A)[1]]
    end
end

path = "/home/freshstart/DiplomaThesisData/RAE_2822_baseline1/"

cp = readdlm(path*"cp.dat",' ')
cp0050 = readdlm(path*"cp005000.dat",' ')
cp0010 = readdlm(path*"cp010000.dat",' ')
cp0015 = readdlm(path*"cp015000.dat",' ')
cp0020 = readdlm(path*"cp020000.dat",' ')
cp0025 = readdlm(path*"cp025000.dat",' ')



cp = nstr(cp)[:,[1,4]]
cp0050 = nstr(cp0050)[:,[1,4]]
cp0010 = nstr(cp0010)[:,[1,4]]
cp0015 = nstr(cp0015)[:,[1,4]]
cp0020 = nstr(cp0020)[:,[1,4]]
cp0025 = nstr(cp0025)[:,[1,4]]

Vs_1 = plot(title="|ΔCp| [%]",ylabel="|%|",xlabel="x-normalized",yguidefontrotation=-90,minorgrid=true,)
        # ylims = [0,.1])
# plot!(Vs_1,[0],[0],c=RGB(0xffffff),label = " ")
# plot!(Vs_1,cp[:,1],ΔeltaAB_100(cp,cp0050,ABS=true,max=true),label = L"\frac{Cp_{5000 i} - Cp_{30000 i}}{max(|Cp_{30000}|)}",c=col[1])
plot!(Vs_1,[0],[0],c=RGB(0xffffff),label = " ")
plot!(Vs_1,cp[:,1],ΔeltaAB_100(cp,cp0010,ABS=true,max=true),label = L"\frac{Cp_{10000 i} - Cp_{30000 i}}{max|Cp_{30000}|}",c=col[2])
plot!(Vs_1,[0],[0],c=RGB(0xffffff),label = " ")
plot!(Vs_1,cp[:,1],ΔeltaAB_100(cp,cp0015,ABS=true,max=true),label = L"\frac{Cp_{15000 i} - Cp_{30000 i}}{max|Cp_{30000}|}",c=col[3])
plot!(Vs_1,[0],[0],c=RGB(0xffffff),label = " ")
plot!(Vs_1,cp[:,1],ΔeltaAB_100(cp,cp0020,ABS=true,max=true),label = L"\frac{Cp_{20000 i} - Cp_{30000 i}}{max|Cp_{30000}|}",c=col[4])
plot!(Vs_1,[0],[0],c=RGB(0xffffff),label = " ")
plot!(Vs_1,cp[:,1],ΔeltaAB_100(cp,cp0025,ABS=true,max=true),label = L"\frac{Cp_{25000} - Cp_{30000}}{Cp_{30000}}",c=col[1])
plot!(Vs_1,[0],[0],c=RGB(0xffffff),label = " ")
savefig(Vs_1,"/home/freshstart/DiplomaThesisData/images/Cp_iter_vs_10kt25k.pdf")