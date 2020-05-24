function params = fitnessMax(image)
% Computes Perception-based Image QUality Evaluator (PIQUE) score. Lower
% score indicates a better fitness (less distortions).
params = 1/max(image(:));
end