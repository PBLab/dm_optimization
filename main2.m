oldParams = zeros(1);
for iteration = 1:100
    newParams = pipeline(oldParams);
    fprintf("The new params are: %s", newParams);
    graphParams(newParams(iteration, :));
    oldParams = newParams;
end