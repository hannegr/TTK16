# Example 2 -- MPC
using JuMP
using Ipopt
using OSQP

# Parameters
a = 0.8104
b = 0.2076
N = 4
idx = 0:N-1
xinit = 0.4884

model = Model()

@variable(model, u[i = 0:N-1])
@variable(model, x[i = 0:N]) # one element longer since it will also contain x[0]

# Add constraints and objective
#@constraint(model, (a*x[i-1]+b*u[i-1]= x[i] for i = 1:N))
@constraint(model, [i = 0:N-1], x[i+1] == a*x[i] + b*u[i])
@constraint(model, x[0] == xinit)

#@constraint(model, (x[i-1]*a + u[i-1]*b)=x[i] for i in 1:N)
@objective(model, Min, sum(x[i]*x[i] + u[i]*u[i] for i = 0:N-1))



set_optimizer(model,Ipopt.Optimizer)  # Or OSQP
optimize!(model)

using Plots
plot(0:N-1,value.(u).data, label = "u", lw = 2)
plot!(0:N,value.(x).data, label = "x", lw = 2)
xlabel!("Timestep")
