function MirrorCommand(zernikeVector)
% Add 'Wrapper' folder to Matlab path
addpath( [pwd '/Wrapper/'] );
% Set your mirror serial name
mirrorSN = 'BAX278';
% Initialise new mirror object
dm = asdkDM( mirrorSN );
% Load matrix Zernike to command matrix
% in NOLL's order without Piston in µm RMS
Z2C = importdata( [mirrorSN '-Z2C.mat'] );
% Number of Zernike in Z2C (Zernike to mirror Command matrix)
nZern = size(Z2C, 1);
% Check the number of actuator
 if dm.nAct ~= size(Z2C, 2)
    error( 'ASDK:NAct', 'Number of actuator mismatch.' );
 end
% Apply Zernike one by one on mirror
zeroVec = zeros( 1, nZern );
for n = 1:nZern
    zeroVec(n)=zernikeVector(n);
    dm.Send( zernikeVector * Z2C ); % Send command to mirror
    zeroVec(n) = 0;      
end
% Reset the mirror (send zeros) 
dm.Reset();
% Clear object
clear dm;
    
end