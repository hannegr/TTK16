#=
Example1a:
- Julia version: 1.8.1
- Author: Hanne-Grete Alvheim
- Date: 2022-09-15
=#
using JuMP
using GLPK

model = Model(GLPK.Optimizer)
@variable(model, BluePaint >=0)
@variable(model, BlackPaint >=0)

@constraint(model, (1/40)*BluePaint + (1/30)*BlackPaint <= 40)
@constraint(model, BluePaint <= 860)
@constraint(model, BlackPaint <= 1000)

@objective(model, Max, 10*BluePaint + 15*BlackPaint)
optimize!(model)


@show value(BlackPaint);
@show value(BluePaint);
@show objective_value(model);

