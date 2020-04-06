function [num_tests, b_initial] = repeated_pooling(p,N, max_batch_size, min_batch_size, round_down)
% Uses method of Repeated Pooling to test N total samples with frequency of positives, p,
%
% INPUTS:
% p - frequency of positives
% N - total number of samples (will be rounded to allow whole number of batches)
% max_batch_size (OPTIONAL) - defines maximal batch size
% min_batch_size (OPTIONAL) - any positive batch smaller than or equal to min_batch_size will be tested individually
%       DEFAULT: min_batch_size = 4
% round_down (OPTIONAL) - if true, round batch sizedown to nearest power of 2
%       DEFAULT: round_down = true
%
% OUTPUTS:
% num_tests - number of tests / number of samples
% b_initial - initial batch size


q=1-p;

% round_down batch size to nearest power of 2 or not
if ~exist('round_down','var')
    round_down = true;
end


% min_batch_size defines size of batch that is not to be split
%   but rather to be tested individually
if ~exist('min_batch_size','var')
    min_batch_size = 4;
end



%% Initial Batch Size

% Set to batch size so that each batch has 0.5 prob of being negative,
b_initial = round(-log(2)/log(q));


% round down to nearest power of 2
if round_down
    b_initial = 2^max(2,(floor(log2(-log(2)/log(q)))));
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

% initial number of tests
ntests = num_batches;
		
% identify positive batches				
pos_batches = find(sum(batches)>0);
		
% loop through each positive batch and split in two
for bi=pos_batches		
	batch = batches(:,bi);
    % split_and_recurse splits a positive batch into, checks both halves,
    % and repeats, returning number of tests accumulated
	ntests = ntests + split_and_recurse(batch,min_batch_size);	
end

num_tests = ntests/n;

end
