#=
Example1b:
- Julia version: 1.8.1
- Author: Hanne-Grete Alvheim
- Date: 2022-09-15
=#

using JuMP
using GLPK

#using vectors

model = Model(GLPK.Optimizer)

#problem data
idx = 1:2
x_lb = (0,0)
x_ub = (860, 1000)
A = (1/40, 1/30)
b = 40
c = (10, 15) #objective c*x

@variable(model, x[i = idx])
@constraint(model, [i = idx], x_lb[i] <= x[i] <= x_ub[i])

@constraint(model, sum(A[i]*x[i] for i in idx) <= b)
@objective(model, Max, sum(c[i]*x[i] for i in idx))

optimize!(model)


@show objective_value(model);
@show value(x[1])
@show value(x[2]) 

