using JuMP
using GLPK

idx = 1:4
b = [10, 40, 30, 50]
w = [5, 4,  6, 3]
W_max = 10

#possible cover (higher than 10)
#x[1],x[2],x[3] sum <= 2
#but we see that
#x[1],x[3] sum <= 1



model = Model(GLPK.Optimizer)

@variable(model, 0 <= x[i = idx] <= 1)

@constraint(model, sum(w[i]*x[i] for i in idx) <= W_max)
#Added constraints using cover cuts: 
@constraint(model, x[1]+x[3] <= 1)
@constraint(model, x[1]+x[2]+x[4] <= 2)
@constraint(model, sum(x[i] for i in 2:4) <= 2)

@objective(model, Max, sum(b[i]*x[i] for i in idx))

optimize!(model);

@show value.(x);
@show objective_value(model);

@show termination_status(model);
