using JuMP
using GLPK

Items = ["hammer", "wrench", "screwdriver", "towel"]
b = Containers.DenseAxisArray([8, 3, 6, 11], Items) #wrench må ha vekt 9 for å bli tatt
w = Containers.DenseAxisArray([5, 7, 4, 3], Items)
W_max = 14

model = Model(GLPK.Optimizer)

@variable(model, x[i = Items], Bin)

@constraint(model, sum(w[i]*x[i] for i in Items) <= W_max)

@objective(model, Max, sum(b[i]*x[i] for i in Items))

optimize!(model);

for i in Items
    println("$(i): $(value(x[i])) ")
end

@show objective_value(model);
