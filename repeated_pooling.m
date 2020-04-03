function [num_tests, b_initial] = repeated_pooling(p,N, num_possible_batch_sizes)
% Uses method of Repeated Pooling to test N total samples with frequency of positives, p,
% INPUTS:
% p - frequency of positives
% N - total number of samples (will be rounded to allow whole number of batches)
% num_possible_batch_sizes (OPTIONAL) - defines how many possible batch sizes to choose from
%           from within pre-determined ranges of values of p
%     if not set, or set to 0, default is to calculate desired batch size
%           for each given p
% OUTPUTS:
% num_tests - number of tests / number of samples
% b_initial - initial batch size


q=1-p;

% Set number of possible initial batch sizes
% If set to 0, compute optimal batch size for each p
if ~exist('num_possible_batch_sizes','var')
    num_possible_batch_sizes = 0;
end

% min_length defines size of batch that is not to be split
%   but rather to be tested individually
min_length = 4;


%% Initial Batch Size

% Set to batch size so that each batch has 0.5 prob of being negative
if num_possible_batch_sizes == 0 
    b_initial = round(-log(2)/log(q));
    
% Otherwise use pre-defined ranges of values    
elseif p < 0.007 & num_possible_batch_sizes > 4
    b_initial = 96;
elseif p < 0.01 & num_possible_batch_sizes > 3
    b_initial = 64;
elseif p < 0.02 & num_possible_batch_sizes > 2
    b_initial = 32;
elseif p < 0.003 & num_possible_batch_sizes > 1
	b_initial=16;
else
	b_initial=8;
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
	ntests = ntests + split_and_recurse(batch,min_length);	
end

num_tests = ntests/n;

end
