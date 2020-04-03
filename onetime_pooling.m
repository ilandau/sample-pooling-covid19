function [num_tests, b_initial] = onetime_pooling(p,N, num_possible_batch_sizes)
% Uses method of Optimal One-Time Pooling to test N total samples with frequency of positives, p,
% INPUTS:
% p - frequency of positives
% N - total number of samples (will be rounded to allow whole number of batches)
% num_possible_batch_sizes (OPTIONAL) - defines how many possible batch sizes to choose from
%           from within pre-determined ranges of values of p
%     if not set, or set to 0, default is to calculate desired batch size
%           for each given p
% Returns fractional number of tests, i.e. number of tests / number of samples
%     and initial batch size

q=1-p;

% Set number of possible initial batch sizes
% If set to 0, compute optimal batch size for each p
if ~exist('num_possible_batch_sizes','var')
    num_possible_batch_sizes = 0;
end

%% Initial Batch Size

% set to optimal batch size given p
if num_possible_batch_sizes == 0
    b_initial = round(fsolve(@(a) 1+a.^2.*log(q).*q.^a, 1));
    
% Otherwise use pre-defined ranges of values 
elseif p < 0.0005 & num_possible_batch_sizes > 5
    b_initial = 64;
elseif p < 0.001 & num_possible_batch_sizes > 4
    b_initial = 32;
elseif p < 0.003 & num_possible_batch_sizes > 3
    b_initial = 24;
elseif p<0.008 & num_possible_batch_sizes > 2
	b_initial = 16;
elseif p<0.04 & num_possible_batch_sizes > 1
	b_initial = 8;
else
	b_initial=4;
end

%% Set up Batches
% round total number of samples to fit whole number of batches
n = b_initial*floor(N/b_initial);
num_batches = n/b_initial;

% generate samples
Samples = rand(n,1)<p;

% create batches
batches = reshape(Samples,b_initial, num_batches);

%% Test

% identify and count positive batches				
pos_batches = find(sum(batches)>0);
num_pos = length(pos_batches);
		
% total tests = number of batches + all samples in positive batches
num_tests = (num_batches + b_initial*num_pos)/n;

end