# using Plots

# @userplot CirclePlot
# @recipe function f(cp::CirclePlot)
#     x, y, i = cp.args
#     n = length(x)
#     inds = circshift(1:n, 1 - i)
#     linewidth --> range(0, 10, length = n)
#     seriesalpha --> range(0, 1, length = n)
#     aspect_ratio --> 1
#     label --> false
#     x[inds], y[inds]
# end

# n = 150
# t = range(0, 2π, length = n)
# x = sin.(t)
# y = cos.(t)

# anim = @animate for i ∈ 1:n
#     circleplot(x, y, i)
# end
# gif(anim, "anim_fps15.gif", fps = 15)
using Plots
 
x = collect(1:0.1:30)
y = sin.(x)
df = 2
plot(x[1:i], y[1:i], legend=false)
 
# anim = @animate for i = 1:df:length(x)
#     plot(x[1:i], y[1:i], legend=false)
# end
 
# gif(anim, "tutorial_anim_fps30.gif", fps = 30)