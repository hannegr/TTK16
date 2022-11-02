# Example 3
using JuMP
using GLPK
using DataFrames
using CSV

root = dirname(dirname(@__FILE__))
const DATA_DIR = "$(root)\\src"# "C:\\Users\\hanne\\OneDrive - NTNU\\Desktop\\2022\\2022høst\\TTK16\\MILP_practice\\src"; # Remember to change backslash to /

Example3_df = CSV.read(joinpath(DATA_DIR,"Example3.dat"), DataFrames.DataFrame)

T = 40; # Total number of hours available in a week

N = DataFrames.nrow(Example3_df);
Products = tuple(Example3_df[:,1]...); # Names of products
Products = 1:N;

p = Example3_df[:,2];
r = Example3_df[:,3];
d = Example3_df[:,4];
B4 = 7; 
M = 100000; 

p_with_w = push!(p, B4); 
p_with_w_and_z = push!(p, 0)

Products_with_w_and_z = 1:N+2;

model = Model(GLPK.Optimizer)
@variable(model,0 <= x[n in Products_with_w_and_z])
set_integer(x[6]);

@objective(model, Max, sum(p_with_w_and_z[n]*x[n] for n in Products_with_w_and_z))
@constraint(model, sum((1/r[n])*x[n] for n in Products) <= T)
@constraint(model, [n in Products], x[n] <= d[n])
#if more than 300 items of product 2 are manufactured weekly, then at least 200 items of product 1 must be produced.
#introducing 2 binary variables, z_0 and z_1 to account for this
# z = 0: x_2 <= 300
# z = 1: x_2 > 300

# 300*z < x_2 <= 300 + M*z
@constraint(model, x[2] >= 300*x[6])

@constraint(model, x[2] <= 300 + M*x[6])
# 200*z <= x_1
@constraint(model, x[1] >= 200*x[6])

@constraint(model, x[6] <= 1)


#A client will pay a bonus of B4 = 7 for each package of 10 items of product 4 delivered weekly. 
#w in Z^+ (natural integer from 0) w: number of packages of 10! 
# max (sum(p[i]*x[i]) + B_4*w)
#w <= x_4/10
@constraint(model, 10*x[5] <= x[4])



optimize!(model);
@show value.(x);

@show objective_value(model);