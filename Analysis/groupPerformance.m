close all
stimEff= [2,3,7];
distraction = [1, 5, 6, 10];
shamEff = [4,8,11];
none = [9, 12];
figure()

%% Stim Data

stim = [];
sham = [];
baseline = [];
errStim = [];
errSham = [];
errBase = [];
normalizedStimY = [];
normalizedBaseline = [];
normalizedShamY = [];
for i = 1:length(stimEff)
    subject = stimEff(i);
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

    % PreStim Phase
    prestimY = objectiveData(1:25,2);
    prestimMean = -mean(prestimY((10:25)));
    prestimError = (std(prestimY) / sqrt(length(prestimY)));
    prestimError = prestimError / prestimMean;


    meanStim = -mean(stimY) / prestimMean;
    errorStim = (std(stimY) / sqrt(length(stimY))) / prestimMean;
    meanSham = -mean(shamY) / prestimMean;
    errorSham= (std(shamY) / sqrt(length(shamY))) / prestimMean;

    normalizedStim = stimY / prestimMean;
    normalizedSham = shamY / prestimMean;
    normalizedBase = prestimY / prestimMean;
    normalizedStimY = [normalizedStimY; normalizedStim];
    normalizedShamY = [normalizedShamY; normalizedSham];
    normalizedBaseline = [normalizedBaseline; normalizedBase];

    prestimMean = prestimMean / prestimMean;

    

    %% Plot data

    % Plot Bar Graph

    stim = [stim meanStim];
    sham = [sham meanSham];
    baseline = [baseline prestimMean];
    errStim = [errStim errorStim];
    errSham = [errSham errorSham];
    errBase = [errBase prestimError];


end
subplot(2,2,1)
meanStimAll = mean(stim);
meanShamAll = mean(sham);
meanBaseAll = mean(baseline);
errStimAll = mean(errStim);
errShamAll = mean(errSham);
errBaseAll = mean(errBase);

bar([meanStimAll, meanShamAll, meanBaseAll])
hold on

ylim([0 1.2])
ax = gca;
ax.FontSize = 20;

set(gca, 'xticklabel', {'Stim', 'Sham', 'Baseline'});
er = errorbar([meanStimAll meanShamAll meanBaseAll], [errStimAll errShamAll errBaseAll]);
er.Color = [0 0 0];
er.LineStyle = 'none';

title('Stimulation Effect')
disp("Stim Stats")
normalizedBaseline = -normalizedBaseline;
normalizedStimY = -normalizedStimY;
normalizedShamY = -normalizedShamY;
meanIncreaseStim = mean(normalizedStimY)
meanIncreaseSham = mean(normalizedShamY)
ErrorIncreaseStim = (std(normalizedStimY) / sqrt(length(normalizedStimY)))
ErrorIncreaseSham = (std(normalizedShamY) / sqrt(length(normalizedShamY)))
[~, baseNormP] = kstest(normalizedBaseline)
[~, stimNormP] = kstest(normalizedStimY)
[~, shamNormP] = kstest(normalizedShamY)
[~, pStim] = ttest2(normalizedBaseline, normalizedStimY, 'Vartype','unequal', 'Tail', 'left')
[~, pSham] = ttest2(normalizedBaseline, normalizedShamY, 'Vartype','unequal')
%% Sham Data
stim = [];
sham = [];
baseline = [];
errStim = [];
errSham = [];
errBase = [];
normalizedStimY = [];
normalizedBaseline = [];
normalizedShamY = [];
for i = 1:length(shamEff)
    subject = shamEff(i);
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

    % PreStim Phase
    prestimY = objectiveData(1:25,2);
    prestimMean = -mean(prestimY((10:25)));
    prestimError = (std(prestimY) / sqrt(length(prestimY)));
    prestimError = prestimError / prestimMean;


    meanStim = -mean(stimY) / prestimMean;
    errorStim = (std(stimY) / sqrt(length(stimY))) / prestimMean;
    meanSham = -mean(shamY) / prestimMean;
    errorSham= (std(shamY) / sqrt(length(shamY))) / prestimMean;

    normalizedStim = stimY / prestimMean;
    normalizedSham = shamY / prestimMean;
    normalizedBase = prestimY / prestimMean;
    normalizedStimY = [normalizedStimY; normalizedStim];
    normalizedShamY = [normalizedShamY; normalizedSham];
    normalizedBaseline = [normalizedBaseline; normalizedBase];

    prestimMean = prestimMean / prestimMean;

    %% Plot data

    % Plot Bar Graph

    stim = [stim meanStim];
    sham = [sham meanSham];
    baseline = [baseline prestimMean];
    errStim = [errStim errorStim];
    errSham = [errSham errorSham];
    errBase = [errBase prestimError];


end
subplot(2,2,2)
meanStimAll = mean(stim);
meanShamAll = mean(sham);
meanBaseAll = mean(baseline);
errStimAll = mean(errStim);
errShamAll = mean(errSham);
errBaseAll = mean(errBase);

bar([meanStimAll, meanShamAll, meanBaseAll])
hold on

ylim([0 1.2])
ax = gca;
ax.FontSize = 20;

set(gca, 'xticklabel', {'Stim', 'Sham', 'Baseline'});
er = errorbar([meanStimAll meanShamAll meanBaseAll], [errStimAll errShamAll errBaseAll]);
er.Color = [0 0 0];
er.LineStyle = 'none';

title('Sham Effect')
disp("sham stats")
normalizedBaseline = -normalizedBaseline;
normalizedStimY = -normalizedStimY;
normalizedShamY = -normalizedShamY;
meanIncreaseStim = mean(normalizedStimY)
meanIncreaseSham = mean(normalizedShamY)
ErrorIncreaseStim = (std(normalizedStimY) / sqrt(length(normalizedStimY)))
ErrorIncreaseSham = (std(normalizedShamY) / sqrt(length(normalizedShamY)))
[~, baseNormP] = kstest(normalizedBaseline)
[~, shamNormP] = kstest(normalizedShamY)
[~, stimNormP] = kstest(normalizedStimY)
[~, pSham] = ttest2(normalizedBaseline, normalizedShamY, 'Vartype','unequal', 'Tail', 'left')
[~, pStim] = ttest2(normalizedBaseline, normalizedStimY, 'Vartype','unequal')

%% Distraction Data
stim = [];
sham = [];
baseline = [];
errStim = [];
errSham = [];
errBase = [];
normalizedStimY = [];
normalizedBaseline = [];
normalizedShamY = [];
for i = 1:length(distraction)
    subject = distraction(i);
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

    % PreStim Phase
    prestimY = objectiveData(1:25,2);
    prestimMean = -mean(prestimY((10:25)));
    prestimError = (std(prestimY) / sqrt(length(prestimY)));
    prestimError = prestimError / prestimMean;


    meanStim = -mean(stimY) / prestimMean;
    errorStim = (std(stimY) / sqrt(length(stimY))) / prestimMean;
    meanSham = -mean(shamY) / prestimMean;
    errorSham= (std(shamY) / sqrt(length(shamY))) / prestimMean;

    normalizedStim = stimY / prestimMean;
    normalizedSham = shamY / prestimMean;
    normalizedBase = prestimY / prestimMean;
    normalizedStimY = [normalizedStimY; normalizedStim];
    normalizedShamY = [normalizedShamY; normalizedSham];
    normalizedBaseline = [normalizedBaseline; normalizedBase];

    prestimMean = prestimMean / prestimMean;

    %% Plot data

    % Plot Bar Graph

    stim = [stim meanStim];
    sham = [sham meanSham];
    baseline = [baseline prestimMean];
    errStim = [errStim errorStim];
    errSham = [errSham errorSham];
    errBase = [errBase prestimError];


end
subplot(2,2,3)
meanStimAll = mean(stim);
meanShamAll = mean(sham);
meanBaseAll = mean(baseline);
errStimAll = mean(errStim);
errShamAll = mean(errSham);
errBaseAll = mean(errBase);

bar([meanStimAll, meanShamAll, meanBaseAll])
hold on

ylim([0 1.2])
ax = gca;
ax.FontSize = 20;

set(gca, 'xticklabel', {'Stim', 'Sham', 'Baseline'});
er = errorbar([meanStimAll meanShamAll meanBaseAll], [errStimAll errShamAll errBaseAll]);
er.Color = [0 0 0];
er.LineStyle = 'none';

title('Distraction Effect')
disp("dist stats")
normalizedBaseline = -normalizedBaseline;
normalizedStimY = -normalizedStimY;
normalizedShamY = -normalizedShamY;
meanIncreaseStim = mean(normalizedStimY)
meanIncreaseSham = mean(normalizedShamY)
ErrorIncreaseStim = (std(normalizedStimY) / sqrt(length(normalizedStimY)))
ErrorIncreaseSham = (std(normalizedShamY) / sqrt(length(normalizedShamY)))
[~, baseNormP] = kstest(normalizedBaseline)
[~, shamNormP] = kstest(normalizedShamY)
[~, stimNormP] = kstest(normalizedStimY)
[~, pStim] = ttest2(normalizedBaseline, normalizedStimY, 'Vartype','unequal', 'Tail', 'right')
[~, pSham] = ttest2(normalizedBaseline, normalizedShamY, 'Vartype','unequal', 'Tail', 'right')

%% No Effect

stim = [];
sham = [];
baseline = [];
errStim = [];
errSham = [];
errBase = [];
normalizedStimY = [];
normalizedBaseline = [];
normalizedShamY = [];
for i = 1:length(none)
    subject = none(i);
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

    % PreStim Phase
    prestimY = objectiveData(1:25,2);
    prestimMean = -mean(prestimY((10:25)));
    prestimError = (std(prestimY) / sqrt(length(prestimY)));
    prestimError = prestimError / prestimMean;


    meanStim = -mean(stimY) / prestimMean;
    errorStim = (std(stimY) / sqrt(length(stimY))) / prestimMean;
    meanSham = -mean(shamY) / prestimMean;
    errorSham= (std(shamY) / sqrt(length(shamY))) / prestimMean;

    normalizedStim = stimY / prestimMean;
    normalizedSham = shamY / prestimMean;
    normalizedBase = prestimY / prestimMean;
    normalizedStimY = [normalizedStimY; normalizedStim];
    normalizedShamY = [normalizedShamY; normalizedSham];
    normalizedBaseline = [normalizedBaseline; normalizedBase];

    prestimMean = prestimMean / prestimMean;

    %% Plot data

    % Plot Bar Graph

    stim = [stim meanStim];
    sham = [sham meanSham];
    baseline = [baseline prestimMean];
    errStim = [errStim errorStim];
    errSham = [errSham errorSham];
    errBase = [errBase prestimError];


end
subplot(2,2,4)
meanStimAll = mean(stim);
meanShamAll = mean(sham);
meanBaseAll = mean(baseline);
errStimAll = mean(errStim);
errShamAll = mean(errSham);
errBaseAll = mean(errBase);

bar([meanStimAll, meanShamAll, meanBaseAll])
hold on

ylim([0 1.2])
ax = gca;
ax.FontSize = 20;

set(gca, 'xticklabel', {'Stim', 'Sham', 'Baseline'});
er = errorbar([meanStimAll meanShamAll meanBaseAll], [errStimAll errShamAll errBaseAll]);
er.Color = [0 0 0];
er.LineStyle = 'none';

title('No Effect')
disp("none stats")
normalizedBaseline = -normalizedBaseline;
normalizedStimY = -normalizedStimY;
normalizedShamY = -normalizedShamY;
meanIncreaseStim = mean(normalizedStimY)
meanIncreaseSham = mean(normalizedShamY)
ErrorIncreaseStim = (std(normalizedStimY) / sqrt(length(normalizedStimY)))
ErrorIncreaseSham = (std(normalizedShamY) / sqrt(length(normalizedShamY)))
[~, baseNormP] = kstest(normalizedBaseline)
[~, stimNormP] = kstest(normalizedStimY)
[~, shamNormP] = kstest(normalizedShamY)
[~, pStim] = ttest2(normalizedBaseline, normalizedStimY, 'Vartype','unequal')
[~, pSham] = ttest2(normalizedBaseline, normalizedShamY, 'Vartype','unequal')




