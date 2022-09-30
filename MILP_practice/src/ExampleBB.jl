# Example BB
using JuMP
using GLPK

idx = 1:4;
model = Model(GLPK.Optimizer)

@variable(model, 0 <= x[n in idx], Bin)
#@variable(model, 0 <= x[n in idx] <= 1, )
@objective(model, Max, 24*x[1] + 2*x[2] + 20*x[3] + 4*x[4])

@constraint(model, 8*x[1] + x[2] + 5*x[3] + 4*x[4] <= 9)

optimize!(model);
@show value.(x);
@show objective_value(model)
