function MirrorCommand(dm, zernikeVector, Z2C)
nZern = 30;  % Not likely we'll ever use more
zeroVec = zeros( 1, nZern );
% Apply Zernike one by one on mirror
% for n = 1:nZern
%     zeroVec(n)=zernikeVector(n);
%     dm.Send( zernikeVector * Z2C ); % Send command to mirror
%     zeroVec(n) = 0;      
% end
% pause(0.1);

for n = 1:min(nZern,15)
    zeroVec(n)=zernikeVector(n); 
    dm.Send( zeroVec * Z2C ); % Send command to mirror
    zeroVec(n) = 0;      
end
end