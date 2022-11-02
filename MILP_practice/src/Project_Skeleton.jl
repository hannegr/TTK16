using JuMP
using GLPK
using DataFrames
using CSV

### Data

root = dirname(dirname(@__FILE__))
const DATA_DIR = "$(root)\\src"

N = 8; # number of wells
Wells = 1:N;
Datapoints = Containers.DenseAxisArray([6, 8, 9, 5, 5, 8, 7, 6], Wells); # Number of datapoints for each well
DatapointsWell = fill(Int[],1,N);  # Index sets for datapoints for each well
for n = Wells
    DatapointsWell[n] = 1:Datapoints[n];
end

Qinj_max = 500; # Max gas injection
Qliq_max = 5500; # Max liquid production
Qgas_max = 6000; # Max gas production

# Read in bounds on injection
injectionbounds_df = CSV.read(joinpath(DATA_DIR,"injectionbounds.csv"), DataFrames.DataFrame, delim = " ", header = false)
lb_inj = Containers.DenseAxisArray(injectionbounds_df[:,2], Wells);
ub_inj = Containers.DenseAxisArray(injectionbounds_df[:,3], Wells);

# Read in water cut for each well
wcut_df = CSV.read(joinpath(DATA_DIR,"wcut.csv"), DataFrames.DataFrame, delim = " ", header = false)
wcut = Containers.DenseAxisArray(wcut_df[:,2], Wells);

# Read in GOR for each well
gor_df = CSV.read(joinpath(DATA_DIR,"gor.csv"), DataFrames.DataFrame, delim = " ", header = false)
gor = Containers.DenseAxisArray(gor_df[:,2], Wells);

# Read in datapoints from file for each well. Note that number of datapoints for each well differ
datapoints_df = CSV.read(joinpath(DATA_DIR,"datapoints.csv"), DataFrames.DataFrame, delim = " ", header = false)
Qinj = zeros(N,9);  # 9 is max number of datapoints for each well
Qoil = zeros(N,9);
for row in eachrow(datapoints_df)
    n = row[1];
    k = row[2];
    #println("($n,$k): $(row[3])")
    Qinj[n,k] = row[3];
    Qoil[n,k] = row[4];
end

### Create model object
model = Model(GLPK.Optimizer)

### TODO finn x(q_inj^n) vha PWL. 
#altså x = \hat{Qoil}!


### Define variables
@variable(model,0 <= x[n in Wells])
@variable(model, 0 <= z[(n, 9) n in Wells], bin)
@variable(model, 0 <= lambda[(n,9) n  in Wells])


### Define objective 
@objective(model, Max, sum(x[n] for n in Wells))

### Define constraints
@constraint(model, sum(lambda) <= 1)
@constraint(model, sum(z) <= 1)
@constraint(model, )
@constraint(model, sum(Qinj) <= Qinj_max)


### Optimize and show results 
#optimize!(model);

#@show value.(x);
#@show objective_value(model);

#@show termination_status(model);



