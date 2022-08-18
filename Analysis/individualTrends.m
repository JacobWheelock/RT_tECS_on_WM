%function findTrends(subjectNum)
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
% Sham/Stim Phase
stimShamX = weightData(51:end,:);
stimShamY = -objectiveData(76:end,2);

dominantAmpBool = stimShamX(:,1) > stimShamX(:,3);
dominantFreq = zeros(size(dominantAmpBool));
dominantAmp = zeros(size(dominantAmpBool));
nonDominantFreq = zeros(size(dominantAmpBool));
nonDominantAmp = zeros(size(dominantAmpBool));
delay = zeros(size(dominantAmpBool));

for i = 1:height(dominantAmpBool)
    if dominantAmpBool(i)
        dominantFreq(i) = stimShamX(i,2);
        dominantAmp(i) = stimShamX(i,1);
        nonDominantFreq(i) = stimShamX(i,4);
        nonDominantAmp(i) = stimShamX(i,3);
        delay(i) = stimShamX(i,5);
    else
        dominantFreq(i) = stimShamX(i,4);
        dominantAmp(i) = stimShamX(i,3);
        nonDominantFreq(i) = stimShamX(i,2);
        nonDominantAmp(i) = stimShamX(i,1);
        delay(i) = stimShamX(i,5);
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
subplot(2,2,1);
scatter(dominantFreq, stimShamY, 36, 1:size(dominantFreq));
hold on
plot(dominantFreq, domFreqFit, '--')
text = sprintf("Dominant Frequency vs. Performance, r = %f", domFreqR);
title(text);
xlim([0 30])
ylim([0 7])
xlabel("Frequency (Hz)")
ylabel("Performance Score")

subplot(2,2,2);
scatter(dominantAmp, stimShamY, 36, 1:size(dominantFreq));
hold on
plot(dominantAmp, domAmpFit, '--')
text = sprintf("Dominant Amplitude vs. Performance, r = %f", domAmpR);
title(text);
xlim([0 1])
ylim([0 7])
xlabel("Amplitude (mA)")
ylabel("Performance Score")

subplot(2,2,3);
scatter(nonDominantFreq, stimShamY, 36, 1:size(dominantFreq));
hold on
plot(nonDominantFreq, nDomFreqFit, '--')
text = sprintf("Non-Dominant Frequency vs. Performance, r = %f", nDomFreqR);
title(text);
xlim([0 30])
ylim([0 7])
xlabel("Frequency (Hz)")
ylabel("Performance Score")

subplot(2,2,4);
scatter(nonDominantAmp, stimShamY, 36, 1:size(dominantFreq));
hold on
plot(nonDominantAmp, nDomAmpFit, '--')
text = sprintf("Non-Dominant Amplitude vs. Performance, r = %f", nDomAmpR);
title(text);
xlim([0 1])
ylim([0 7])
xlabel("Amplitude (mA)")
ylabel("Performance Score")


%end



