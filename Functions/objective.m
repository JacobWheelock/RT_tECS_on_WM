% The objective function will be the accuracy for a certain set of weights
function [score, span] = objective(span, trial)
data = pyrunfile('Task/SpatialTest.py', 'data', span0 = span, currTrial0 = trial);
score = cell(data(2));
span = cell(data(1));
score = cellfun(@double, score);
span = cellfun(@double, span);
end