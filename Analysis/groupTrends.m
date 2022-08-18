%% Load in Data
close all
stimShamX = []; stimShamY = [];
means = [];
baselines = [];
all = [1:12];
distraction = [1, 5, 6, 10]; stim = [2, 3, 7]; sham = [4, 8, 11]; none = [9, 12]; single = 12;
group = none;

groupName = "All Aggregate Data";
for i = 1:length(group)
    subject = group(i);
    XData = sprintf('Data/Behavior/%iX.mat', subject);
    YData = sprintf('Data/Behavior/%iY.mat', subject);
    shamData = sprintf('Data/Behavior/%iShamStim.mat',subject);

    weightData = load(XData);
    objectiveData = load(YData);
    shamStimData = load(shamData);

    weightData = weightData.X;
    objectiveData = objectiveData.combData;
    shamStimData = shamStimData.shamOrStim;

    % Sham/Stim Phase
    stimShamX = [stimShamX; weightData(51:end,:)];
    stimShamY = [stimShamY; -objectiveData(76:end,2)];

    % Prestim
    prestimY = objectiveData(1:25,2);

    baselines = [baselines; prestimY(10:25)];
end

for i = 1:length(all)
    subject = all(i);
    XData = sprintf('Data/Behavior/%iX.mat', subject);
    YData = sprintf('Data/Behavior/%iY.mat', subject);
    shamData = sprintf('Data/Behavior/%iShamStim.mat',subject);

    weightData = load(XData);
    objectiveData = load(YData);
    shamStimData = load(shamData);

    weightData = weightData.X;
    objectiveData = objectiveData.combData;
    shamStimData = shamStimData.shamOrStim;
    % Prestim
    prestimY = objectiveData(1:25,2);
    means = [means; -mean(prestimY((10:25)))];
    
    
end
%% Plot Mean Bar Graphs
distMeans = [means(1), means(5), means(6), means(10)];
stimMeans = [means(2), means(3), means(7), nan];
shamMeans = [means(4), means(8), means(11), nan];
noneMeans = [means(9), means(12), nan, nan];
meanGroups = [distMeans; stimMeans; shamMeans; noneMeans];
figure()
groups = ["Distracton", "Stimulus", "Sham", "No Effect"];
groups = categorical(groups);
bar(groups, meanGroups, 'b');
title('Group Means');

%% Plot Scatter Trends
dominantAmpBool = stimShamX(:,1) > stimShamX(:,3);
dominantFreq = zeros(size(dominantAmpBool));
dominantAmp = zeros(size(dominantAmpBool));
nonDominantFreq = zeros(size(dominantAmpBool));
nonDominantAmp = zeros(size(dominantAmpBool));

for i = 1:height(dominantAmpBool)
    if dominantAmpBool(i)
        dominantFreq(i) = stimShamX(i,2);
        dominantAmp(i) = stimShamX(i,1);
        nonDominantFreq(i) = stimShamX(i,4);
        nonDominantAmp(i) = stimShamX(i,3);
    else
        dominantFreq(i) = stimShamX(i,4);
        dominantAmp(i) = stimShamX(i,3);
        nonDominantFreq(i) = stimShamX(i,2);
        nonDominantAmp(i) = stimShamX(i,1);
    end
end

domFreqX = [ones(length(dominantFreq), 1) dominantFreq];
domAmpX = [ones(length(dominantAmp), 1) dominantAmp];
nDomFreqX = [ones(length(nonDominantFreq), 1) nonDominantFreq];
nDomAmpX = [ones(length(nonDominantAmp), 1) nonDominantAmp];

domFreqB = mldivide(domFreqX,stimShamY);
domFreqFit = domFreqX*domFreqB;

domAmpB = mldivide(domAmpX, stimShamY);
domAmpFit = domAmpX*domAmpB;

nDomFreqB = mldivide(nDomFreqX, stimShamY);
nDomFreqFit = nDomFreqX*nDomFreqB;

nDomAmpB = mldivide(nDomAmpX, stimShamY);
nDomAmpFit = nDomAmpX*nDomAmpB;

[domFreqR, domFreqP] = corr(dominantFreq, stimShamY);
[domAmpR, domAmpP] = corr(dominantAmp, stimShamY);
[nDomFreqR, nDomFreqP] = corr(nonDominantFreq, stimShamY);
[nDomAmpR, nDomAmpP] = corr(nonDominantAmp, stimShamY);


%% Plot data
figure()
sgtitle(groupName)
subplot(2,2,1);
scatter(dominantFreq, stimShamY);
hold on
plot(dominantFreq, domFreqFit, '--')
text = sprintf("Dominant Frequency vs. Performance, r = %f", domFreqR);
title(text);
xlim([0 30])
ylim([0 7])
xlabel("Frequency (Hz)")
ylabel("Performance Score")

subplot(2,2,2);
scatter(dominantAmp, stimShamY);
hold on
plot(dominantAmp, domAmpFit, '--')
text = sprintf("Dominant Amplitude vs. Performance, r = %f", domAmpR);
title(text);
xlim([0 1])
ylim([0 7])
xlabel("Amplitude (mA)")
ylabel("Performance Score")

subplot(2,2,3);
scatter(nonDominantFreq, stimShamY);
hold on
plot(nonDominantFreq, nDomFreqFit, '--')
text = sprintf("Non-Dominant Frequency vs. Performance, r = %f", nDomFreqR);
title(text);
xlim([0 30])
ylim([0 7])
xlabel("Frequency (Hz)")
ylabel("Performance Score")

subplot(2,2,4);
scatter(nonDominantAmp, stimShamY);
hold on
plot(nonDominantAmp, nDomAmpFit, '--')
text = sprintf("Non-Dominant Amplitude vs. Performance, r = %f", nDomAmpR);
title(text);
xlim([0 1])
ylim([0 7])
xlabel("Amplitude (mA)")
ylabel("Performance Score")




