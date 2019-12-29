function [dm, Z2C] = initMirror(sn)

% Initialise new mirror object
dm = asdkDM( sn );
% Load matrix Zernike to command matrix
% in NOLL's order without Piston in µm RMS
Z2C = importdata( [sn '-Z2C.mat'] );
% Check the number of actuator
 if dm.nAct ~= size(Z2C, 2)
    error( 'ASDK:NAct', 'Number of actuator mismatch.' );
 end
 
 dm.Reset();