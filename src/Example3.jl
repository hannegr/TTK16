# Example 3
using JuMP
using GLPK
using DataFrames
using CSV

const DATA_DIR = "C:\\Users\\hannegga\\IdeaProjects\\MILP_practice\\src"; # Remember to change backslash to /

Example3_df = CSV.read(joinpath(DATA_DIR,"Example3.dat"), DataFrames.DataFrame)

T = 40; # Total number of hours available in a week

N = DataFrames.nrow(Example3_df);
Products = tuple(Example3_df[:,1]...); # Names of products
Products = 1:N;
p = Example3_df[:,2];
r = Example3_df[:,3];
d = Example3_df[:,4];

model = Model(GLPK.Optimizer)
@variable(model,0 <= x[n in Products])

@objective(model, Max, sum(p[n]*x[n] for n in Products))

@constraint(model, sum((1/r[n])*x[n] for n in Products) <= T)
@constraint(model, [n in Products], x[n] <= d[n])

optimize!(model);
@show value.(x);

@show objective_value(model);