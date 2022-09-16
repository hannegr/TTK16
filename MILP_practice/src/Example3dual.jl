# Example 3 dual

using JuMP
using GLPK
using DataFrames
using CSV

const DATA_DIR = "C:\\Users\\hanne\\OneDrive - NTNU\\Desktop\\2022\\2022høst\\TTK16\\MILP_practice\\src"; # Remember to change backslash to /

Example3_df = CSV.read(joinpath(DATA_DIR,"Example3.dat"), DataFrames.DataFrame)

T = 40; # Total number of hours available in a week

N = DataFrames.nrow(Example3_df);
# Products = tuple(Example3_df[:,1]...); # Names of products
Products = 1:N;
p = Example3_df[:,2];
r = Example3_df[:,3];
d = Example3_df[:,4];

model = Model(GLPK.Optimizer)

# Variables
@variable(model, 0 <= y[i in Products])
@variable(model, 0 <= w)

# Objective
@objective(model, Min, T*w + sum(d[i]*y[i] for i in Products))

# Constraint
@constraint(model, [n in Products], (1/r[n])*w + y[n] >= p[n])

optimize!(model);
@show value.(y);
@show value.(w);

@show objective_value(model);