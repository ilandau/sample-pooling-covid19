function [num_tests, b_initial] = onetime_pooling(p, N, max_batch_size, preset_ranges)
% Uses method of Optimal One-Time Pooling to test N total samples with frequency of positives, p
% 	Source: "Efficient and Practical Sample Pooling for High-Throughput PCR Diagnosis of COVID-19" (Shani-Narkiss et al 2020)
%
% INPUTS:
% p - frequency of positives
% N - total number of samples (will be rounded to allow whole number of batches)
% max_batch_size (OPTIONAL) - defines maximal batch size
% preset_ranges (OPTIONAL) - if true, use predefined ranges of values from published protocol
%           DEFAULT: preset_ranges = false
%
% OUTPUTS:
% num_tests - number of tests / number of samples
% b_initial - initial batch size

q=1-p;

% Set number of possible initial batch sizes
% If set to 0, compute optimal batch size for each p
if ~exist('preset_ranges','var')
    preset_ranges = false;
end

%% Initial Batch Size

% set to optimal batch size given p
b_initial = round(fsolve(@(a) 1+a.^2.*log(q).*q.^a, 1));

% Or use pre-defined ranges of values 
if preset_ranges

    if p < 0.0005
        b_initial = 64;
    elseif p < 0.001
        b_initial = 32;
    elseif p < 0.003
        b_initial = 24;
    elseif p<0.008
        b_initial = 16;
    elseif p<0.04
        b_initial = 8;
    else
        b_initial=4;
    end
end

% compare to max batch size
if exist('max_batch_size','var')
    b_initial = min(b_initial, max_batch_size);
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
