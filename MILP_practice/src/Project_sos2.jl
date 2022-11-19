using JuMP
using GLPK
using DataFrames
using CSV
using Gurobi

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


Q_inj_max = zeros(100)
for n = 1:100
    Q_inj_max[n] = 25*n
end

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
    Qinj[n,k] = row[3];
    Qoil[n,k] = row[4];
end

Qoil_max = zeros(N)
for n in Wells
    Qoil_max[n] = max(Qoil[n,:]...)
end

### Create model object
for d in 1:100
        
    model = Model(Gurobi.Optimizer)
    test = MOI.supports_constraint(
    backend(model), MOI.VectorOfVariables, MOI.SOS2{Float64}
    )
    ### Define variables
    @variable(model, y[Wells], Bin)
    @variable(model, 0.0 <= q_inj[Wells])
    @variable(model, 0.0 <= q_oil[Wells])
    @variable(model, 0.0 <= q_water[Wells])
    @variable(model, 0.0 <= q_gas[Wells])

    @variable(model, 0.0 <= lam[n=Wells, k=DatapointsWell[n]])



    ### Define objective 
    @objective(model, Max, sum(q_oil[n] for n in Wells))  

    ### Define constraints
    @constraint(model, [n in Wells], q_oil[n] ==  q_gas[n]/gor[n]) 
    @constraint(model, [n in Wells], q_water[n] == wcut[n]*q_oil[n]/(1-wcut[n])) 

    @constraint(model, sum(q_inj[n] for n in Wells) <= Q_inj_max[d]) 
    @constraint(model, sum(q_water[n] + q_oil[n] for n in Wells) <= Qliq_max) 
    @constraint(model, sum(q_inj[n] + q_gas[n] for n in Wells) <= Qgas_max) 


    @constraint(model, [n in Wells], q_oil[n] <= Qoil_max[n]*y[n])
    @constraint(model, [n in Wells], lb_inj[n]*y[n] <= q_inj[n]) # min(Qinj[n]...)
    @constraint(model, [n in Wells], q_inj[n] <= ub_inj[n]*y[n]) # max(Qinj[n]...)

    @constraint(model, [n in Wells],  [lam[n, d] for d in DatapointsWell[n]] in SOS2())
    @constraint(model, [n in Wells], sum(lam[n,:]) == y[n]) 
  
    @constraint(model, [n in Wells], q_inj[n] == sum(lam[n, k]*Qinj[n,k] for k in DatapointsWell[n])) 
    @constraint(model, [n in Wells], q_oil[n] == sum(lam[n, k]*Qoil[n,k] for k in DatapointsWell[n])) 



    ### Optimize and show results 
    optimize!(model);

    @show value.(q_oil);
    @show value.(q_gas); 
    @show value.(q_water);
    @show value.(lam);
    @show value.(q_inj);
    @show value.(y)
    @show objective_value(model);

    qoil = zeros(8)
    qgas = zeros(8)
    qwater = zeros(8)
    qinj = zeros(8)

    for i in 1:8
        qoil[i] = value.(q_oil[i])
        qgas[i] = value.(q_gas[i])
        qwater[i] = value.(q_water[i])
        qinj[i] = value.(q_inj[i])
    end 


    @show termination_status(model);

    CSV.write("$(DATA_DIR)\\info_different_Q_inj_sos2.csv",DataFrame(q_oil = qoil, q_gas = qgas, q_water = qwater, q_inj = qinj, Q_inj_max = Q_inj_max[d], objective_value = objective_value(model)), append=true)
end 
