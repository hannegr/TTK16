# Example BB
using JuMP
using GLPK

idx = 1:4;
model = Model(GLPK.Optimizer)

@variable(model, 0 <= x[n in idx] <= 1)
@objective(model, Max, 24*1 + 2*x[2] + 20*0 + 4*0)

@constraint(model, 8*1 + x[2] + 5*0 + 4*0 <= 9)

optimize!(model);
@show value.(x);
@show objective_value(model)
