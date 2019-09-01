function DMvec = MirrorCommand(zernikeVector,nZern,mirrorMatrix)
zeroVec = zeros( 1, nZern );
for n = 1:nZern
    zeroVec(n)=zernikeVector(n);
    DMvec = zeroVec * mirrorMatrix;  % Send command to mirror
    zeroVec(n) = 0;      % Reset Zernike vector
end
disp('Update Complete')
    
end