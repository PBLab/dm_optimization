function params = fitnessFun(image)
% Computes Perception-based Image QUality Evaluator (PIQUE) score. Lower
% score indicates a better fitness (less distortions).
params = piqe(image);
end