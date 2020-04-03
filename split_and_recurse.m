function [ntests] = split_and_recurse(batch,min_length)
% Recursive function to split positive samples and repeat
% INPUTS:
% batch - a binary array of 0s and 1s
% min_length - defines the length of batch, below which (inclusive),
%               all samples are to be tested individually


    % single-sample batches have already been tested
	if length(batch)==1
		ntests = 0;
        
    % all samples in a batch <= min_length tested individually
	elseif length(batch)<=min_length
		ntests = length(batch);
        
    % Split and Recurse
    else
        % length of half-batch
		l = round(length(batch)/2);
        
        % first half-batch
		b1 = batch(1:l);
        
        % second half-batch
		b2 = batch(l+1:end);
        
        % number of tests
		ntests = 2;
        
        % if either half-batch is positive send it to be split,
        %    and accumulate all following number of tests
        
		if sum(b1)>0
			ntests = ntests + split_and_recurse(b1,min_length);
		end
		
		if sum(b2)>0
			
			ntests = ntests+ split_and_recurse(b2,min_length);
		end
	end
end
	