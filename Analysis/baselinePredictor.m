close all
all = 1:12;
figure()

baseline = [];
normalizedStimY = [];
normalizedBaseline = [];
normalizedShamY = [];
for i = 1:length(all)
    subject = all(i);
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

    % PreStim Phase
    prestimY = objectiveData(1:25,2);
    prestimMean = -mean(prestimY((10:25)));

    normalizedStim = stimY / prestimMean;
    normalizedSham = shamY / prestimMean;
    normalizedStimY = [normalizedStimY normalizedStim];
    normalizedShamY = [normalizedShamY normalizedSham];
    baseline = [baseline (ones(1,length(normalizedStimY)) * prestimMean)];


end

baseline = baseline';
normalizedStimY = -normalizedStimY;
normalizedShamY = -normalizedShamY;
meanStimImprove = reshape(normalizedStimY, [], 1);
meanShamImprove = reshape(normalizedShamY, [], 1);

baseX = [ones(length(baseline), 1) baseline];

stimImproveB = mldivide(baseX,meanStimImprove);
stimImproveFit = baseX*stimImproveB;

shamImproveB = mldivide(baseX, meanShamImprove);
shamImproveFit = baseX*shamImproveB;


[stimImproveR, stimImproveP] = corr(baseline, meanStimImprove);
[shamImproveR, shamImproveP] = corr(baseline, meanShamImprove);

subplot(1,2,1)
scatter(baseline, meanStimImprove)
hold on
plot(baseline, stimImproveFit, '--')
xlim([0 7])
ylim([0 1.2])

hold on
ax = gca;
ax.FontSize = 20;
t1 = sprintf('Stimulation Improvement r = %f', stimImproveR);
title(t1)

subplot(1,2,2)
scatter(baseline, meanShamImprove)
hold on
plot(baseline, shamImproveFit, '--')
xlim([0 7])
ylim([0 1.2])
hold on
ax = gca;
ax.FontSize = 20;
t2 = sprintf('Sham Improvement r = %f', shamImproveR);
title(t2)

