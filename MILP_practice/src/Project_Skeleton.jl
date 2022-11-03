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

### Define variables
@variable(model, y[Wells], Bin)
@variable(model, 0 <= q_inj[Wells])
@variable(model, 0 <= q_oil[Wells])
@variable(model, 0 <= q_water[Wells])
@variable(model, 0 <= q_gas[Wells])

@variable(model, 0<= lam[n=Wells, k=DatapointsWell[n]])
@variable(model, z[n=Wells, k=DatapointsWell[n]], Bin)



### Define objective 
@objective(model, Max, sum(q_oil[Wells]))

### Define constraints
#TODO fix whatever is not working here 



@constraint(model, sum(q_inj) <= Qinj_max)
@constraint(model, sum(q_water[n] + q_oil[n] for n in Wells) <= Qliq_max)
@constraint(model, sum(q_inj[n] + q_gas[n] for n in Wells) <= Qgas_max)
@constraint(model, (q_oil[n] == Qoil[n] for n in Wells))
@constraint(model, q_oil[n] <= Qoil*y[n] for n in Wells)
@constraint(model, q_inj[n] >= lb_inj[n]*y[n] for n in Wells)
@constraint(model, q_inj[n] <= ub_inj[n]*y[n] for n in Wells)
@constraint(model, q_water[n] == wcut[n]*q_oil[n] for n in Wells)
@constraint(model, q_gas[n] == gor[n]*q_oil[n] for n in Wells)

@constraint(model, sum(lam[n,:] for n in Wells) <= 1)
@constraint(model, sum(z[n,:] for n in Wells) <= 1)
@constraint(model, q_inj[n] == sum(lam[n,k]*Qinj[n,k] for n in Wells, k in DatapointsWell[n]))
@constraint(model, q_oil[n] == sum(lam[n,k]*Qoil[n,k] for n in Wells, k in DatapointsWell[n]))




### Optimize and show results 
optimize!(model);

@show value.(x);
@show objective_value(model);

@show termination_status(model);



