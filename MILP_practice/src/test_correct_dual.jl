#=
test_correct_dual:
- Julia version: 1.8.1
- Author: Hanne-Grete Alvheim
- Date: 2022-09-15
=#
using JuMP
using GLPK
model1Vars = 1:3
c = [100 75 55]
b = [7200 6000]
model2Vars = 1:2


model1 = Model(GLPK.Optimizer)
@variable(model1, 0 <= x[n in model1Vars])
@objective(model1, Max, sum(c[n]*x[n] for n in model1Vars))
@constraint(model1, 3*x[1]+2*x[2]+x[3] == b[1])
@constraint(model1, 2*x[1]+2*x[2]+3*x[3] == b[2])


model2 = Model(GLPK.Optimizer)
@variable(model2, 0 <= u[n in model2Vars])
@objective(model2, Min, sum(b[n]*u[n] for n in model2Vars))
@constraint(model2, 3*u[1]+2*u[2] >= 100)
@constraint(model2, 2*u[1]+2*u[2] >= 75)
@constraint(model2, u[1]+3*u[2] >= 30)


optimize!(model1)
@show value.(x);
@show objective_value(model1);

optimize!(model2)
@show value.(u);
@show objective_value(model2);