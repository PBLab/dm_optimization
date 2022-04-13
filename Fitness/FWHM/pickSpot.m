function spots = pickSpot(image)
% Picks all the PSF spots from an image

% Pick only the spots intensities assuming there're black gaps between them
[row,col] = find(image>0.0001);
% Find the gaps in the Y axis
sortByRow = sortrows([row,col]);
diffRow = diff(sortByRow(:,1));
idxRow = [0,find(diffRow~=0 & diffRow~=1),length(row)];
count = 0;
% Separate the spots using their locations
for i=2:length(idxRow)
    pickRows = sortByRow(idxRow(i-1)+1:idxRow(i),:);
    % Find the gaps in the X axis
    sortByCol = sortrows(pickRows,2);
    diffCol = diff(sortByCol(:,2));
    idxCol = [0,find(diffCol~=0 & diffCol~=1),length(pickRows)];
    for j=2:length(idxCol)
        pickCols = sortByCol(idxCol(j-1)+1:idxCol(j),:);
        count = count+1;
        name = genvarname(['spot' num2str(count)]);
        spots.(name) = pickCols;
    end
end
end