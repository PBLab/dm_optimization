function  FWHM = extractFWHM(signal,varargin)
% Extracts FWHM of a given signal by fitting a gaussian shape to the signal 

% Optional- transpose the signal
f1=find(strcmp('transpose',varargin));
if ~isempty(f1)
    transFlag = varargin{f1+1};
else
    transFlag = 0;
end

% Apply a gaussian fitting
x=1:length(signal);
if transFlag == 1
    f = fit(x.',signal.','gauss1');
else
    f = fit(x.',signal,'gauss1');
end
std = (f.c1)/sqrt(2);
% Relation between standard deviation and FWHM
FWHM= std * 2 * sqrt(2*log(2));                                 
end