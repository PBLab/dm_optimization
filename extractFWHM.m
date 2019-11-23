function  FWHM = extractFWHM(signal)
% Extracts the FWHM of a given signal

% Normalize the signal from 0 to 1
normSig = signal/max(signal);
% Find the X index of the gaussian maximum
x_max = find(normSig == 1);
firstHalf = normSig(1:x_max);
secondHalf = normSig(x_max+1:length(normSig));
% Find the Y value closest to 0.5 in every half of the gaussian
higher = [min(firstHalf(firstHalf >= 0.5)),min(secondHalf(secondHalf >= 0.5))];
lower = [max(firstHalf(firstHalf <= 0.5)),max(secondHalf(secondHalf <= 0.5))];
y = zeros(1,2);
for i = 1:2
    if abs(higher(i)-0.5) <= abs(lower(i)-0.5)
        y(i) = higher(i);
    else
        y(i) = lower(i);
    end
end
% Find the X index of Y~0.5
x1 = find(firstHalf == y(1));
x2 = find(secondHalf == y(2))+x_max;
FWHM=x2-x1;
end