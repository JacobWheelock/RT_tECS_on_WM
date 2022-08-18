close all
subject = 2;
%% Load in Data
XData = sprintf('Data/Behavior/%iX.mat', subject);
YData = sprintf('Data/Behavior/%iY.mat', subject);
shamData = sprintf('Data/Behavior/%iShamStim.mat',subject);

weightData = load(XData);
objectiveData = load(YData);
shamStimData = load(shamData);

weightData = weightData.X;
objectiveData = objectiveData.combData;
shamStimData = shamStimData.shamOrStim;

%% Seperate Data

% PreStim Phase
prestimY = objectiveData(1:25,2);
prestimMean = -mean(prestimY((10:25)));
prestimError = std(prestimY) / sqrt(length(prestimY));

% Learning Phase
learningX = weightData(1:50,:);
learningY = objectiveData(26:75,2);

% Sham/Stim Phase
stimShamX = weightData(51:end,:);
stimShamY = objectiveData(76:end,2);
stimShamData = shamStimData;
stimShamBool = stimShamData < 10;
shamX = []; shamY = [];
stimX = []; stimY = [];

for i = 1:(height(stimShamX) / 3)
    for j = 1:3
        if stimShamBool(i)
            stimX = [stimX; stimShamX((3*(i-1) + j),:)];
            stimY = [stimY; stimShamY((3*(i-1) + j),1)];
        else
            shamX = [shamX; stimShamX((3*(i-1) + j),:)];
            shamY = [shamY; stimShamY((3*(i-1) + j),1)];
        end
    end
end

meanStim = -mean(stimY);
errorStim = std(stimY) / sqrt(length(stimY));
meanSham = -mean(shamY);
errorSham= std(shamY) / sqrt(length(shamY));

%% Plot data

% Plot Bar Graph
figure()
subplot(1,2,1)
bar([meanStim meanSham prestimMean]);
set(gca, 'xticklabel', {'Stim', 'Sham', 'Baseline'});
hold on;
er = errorbar([meanStim meanSham prestimMean], [errorStim errorSham prestimError]);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';

title('Mean with Std. Error')

% Plot Line Graph
subplot(1,2,2)
stimYReshape = reshape(stimY, 3,[]);
shamYReshape = reshape(shamY, 3,[]);
meanStimLine = -mean(stimYReshape,2);
meanShamLine = -mean(shamYReshape, 2);
errorStimLine = std(stimYReshape,0,2) / sqrt(length(stimYReshape));
errorShamLine = std(shamYReshape, 0, 2) / sqrt(length(shamYReshape));
errorbar(meanStimLine, errorStimLine);
hold on
errorbar(meanShamLine, errorShamLine)
plot([1 2 3], [prestimMean prestimMean prestimMean], '--');
ylim([0 7]);
xlim([0 4]);
legend('stim', 'sham', 'baseline');
title("Mean for Each Part of Block")




