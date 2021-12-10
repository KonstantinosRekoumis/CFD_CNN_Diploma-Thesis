module digit_mods

export interpolate, str_el, ΔeltaAB

function ΔeltaAB(A,B;ABS=false)
    size(A)[1] != size(B)[1] ? error("A has not the same rows as B") :
    
    return ABS ? [abs((A[i,2]-B[i,2])/B[i,2]) for i in 1:size(A)[1]] : [(A[i,2]-B[i,2])/B[i,2] for i in 1:size(A)[1]]
end

function interpolate(a::Array{<:Real}, x::Array{<:Real};side="y")
    # a is input array with a x and an y axis. VALUES ARE IN ORDER AND NOT RANDOMLY PLACED
    # x is the array which carries the values where we want to interpolate data out of a 
    (minimum(size(a)) >= 3) | (length(size(a)) > 2) ?  error("Check input array's dimensions") : 
    (length(size(x)) > 2) ?  error("Check interpolation array's dimensions") : 
    size(a)[1] < size(a)[2] ? a_len = 2 : a_len = 1 # check whether is a row or column matrix
    if side == "y"
       a_len == 1 ? xa = a[:,1] : xa = a[1,:]
       a_len == 1 ? ya = a[:,2] : ya = a[2,:]
    end

    res = Array{Real}(undef,size(x))
 
    for k in 1:size(x)[1]
        i = x[k]
        for j in 1:size(a)[a_len] - 1
           ((xa[j] <= i) & (xa[j + 1] >= i)) | ((xa[j] >= i) & (xa[j + 1] <= i))  ?  (res[k] = ya[j] + (ya[j + 1] - ya[j]) / (xa[j + 1] - xa[j]) * (i - xa[j]);break) : continue
        end
    end
    return res
end

function str_el(data;concat=false)
   # empty strings elimination
    for i ∈ 1:size(data)[1] 
        pos = []
        for j ∈ 1:size(data[i])[1]
            if !((typeof(data[i][j]) == Float64) || (typeof(data[i][j]) == Int64))
                push!(pos, j)
            end
        end
        for p ∈ 1:size(pos)[1]            
            deleteat!(data[i], pos[size(pos)[1] - p + 1])
        end
    end
   
    ((size(data)[1] == 1) & concat) ? (concat = false; @warn "Data were a single column,thus non concatenation is needed.") :
    if concat   
        tmp = data[1]
        for i in 2:size(data)[1]
            length(data[1]) != length(data[i]) ? ( @warn "Column $i is not the same length as the previous. Skipping it.";continue) :
            tmp = hcat(tmp, data[i]) 
        end
        data = tmp
    else
        data = [i for i in data[1]]
    end
    return data
end
# new VS plot for different meshes against the experiment
export popul
function popul(path::AbstractString,a::AbstractArray)
    file = open(path*"Cp_RAE_up_var.dat")
    lines = readlines(file)
    for i in 1:size(lines)[1]
       a[i,1] = parse(Float32,lines[i])
    end
    close(file);
    file = open(path*"Cp_RAE_down_var.dat");
    lines = readlines(file);
    for i in 1:size(lines)[1]
       a[i,2] = parse(Float32,lines[i])
    end
    close(file)
end


end
