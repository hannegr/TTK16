using JuMP
using GLPK

model = Model(GLPK.Optimizer)
c = [4,3,2,1]
idx = 1:4

@variable(model, 0 <= x[n in idx], Bin)
@objective(model, Max, sum(c[i]*x[i] for i = idx))
@constraint(model, x[2] <= x[4])
@constraint(model, x[1] == x[2]+x[3])
@constraint(model, x[1]+x[2] >= 1)
@constraint(model, sum(x[i] for i = idx) <= 2)

optimize!(model) 


for i in idx
    println("$(value(x[i])) ")
end

@show objective_value(model);