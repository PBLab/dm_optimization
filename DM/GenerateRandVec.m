function OriginZern=GenerateRandVec(size,min,space,max)
% Generates a random zernike vector within a range of values
range=min:space:max;
OriginZern=zeros(1,size);
for i=1:size
    loc=randi([1 length(range)],1,1);
    OriginZern(i)=range(loc);
end
end