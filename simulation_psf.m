%% Create frames for iteration
[psfImage_1,spot_data1]=createSpots([512 512],4,[60 60 60 60],'spotPos',[128,128;384,128;128,384;384,384]);
images.('psfImage_1') = psfImage_1;
data.('spot_data1') = spot_data1;
for i=2:10
    vec = GenerateRandVec(4,45,5,60);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;
end
for i=11:20
    vec = GenerateRandVec(4,40,5,55);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;
end
for i=21:30
    vec = GenerateRandVec(4,35,5,50);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end
for i=31:40
    vec = GenerateRandVec(4,30,5,45);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end
for i=41:50
    vec = GenerateRandVec(4,25,5,40);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end
for i=51:60
    vec = GenerateRandVec(4,20,5,35);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end  
for i=61:70
    vec = GenerateRandVec(4,15,5,30);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end 
for i=71:80
    vec = GenerateRandVec(4,10,5,25);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end 
for i=81:90
    vec = GenerateRandVec(4,10,5,20);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end 
for i=91:99
    vec = GenerateRandVec(4,5,5,15);
    imageName = ['psfImage_' num2str(i)];
    dataName = ['spot_data' num2str(i)];
    [psfImage ,spot_data]=createSpots([512 512],4,vec,'spotPos',[128,128;384,128;128,384;384,384]);
    images.(imageName) = psfImage;
    data.(dataName) = spot_data;    
end 
[psfImage_100,spot_data100]=createSpots([512 512],4,[5 5 5 5],'spotPos',[128,128;384,128;128,384;384,384]);
images.('psfImage_100') = psfImage_100;
data.('spot_data100') = spot_data100;
%% Perform 'DMoptimization' function as on SI 
imageFields = fieldnames(images);
popSize = 10;
genesNum = 30;
% Initialize Zernike vectors population and send command to the mirror
pop = initialize (popSize,genesNum);
disp(pop)
figure(1)
% Perform iteration
for frameNum=1:length(imageFields)
    individualNum = mod(frameNum, popSize);
    % During the popSize'th frame we're both updating the population
    % vector and running the algorithm. Otherwise we're just updating
    % the vector.
    if mod(frameNum, popSize) ~= 0
        [pop] = fillFitnessValue(individualNum, images.(imageFields{frameNum}), pop, genesNum); %dm, Z2C);
    else
        % Call pipeline to create new generations, apply genetic algorithm
        % and send mirror commands
        [pop, returnedPop] = runAlgorithm(images.(imageFields{frameNum}),pop, genesNum, popSize); %dm, Z2C);
    end
    % Present the fitness of every frame
    stem(frameNum, fitnessFun(images.(imageFields{frameNum})));
    xlabel('Frame')
    ylabel('FWHM')
    hold on
    % Once the fitness is optimal, the iteration stops
    if fitnessFun(images.(imageFields{frameNum})) <= 6
        break
    end
end