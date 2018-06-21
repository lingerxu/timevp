function [res, sample_rate] = cstream2cevent(cstream, sample_rate, include_zero)
% cstream2cevent   Convert cstream data to cevent data
% 
% cevent = cstream2cevent(cstream, include_zero)
%
% cstream - (input)category cstream. list of pair [timestamp categorynumber]
%               e.g.
%               344.7000   32.0000
%               344.8000   34.0000
%               344.9000   34.0000
%               345.0000   34.0000
%               345.1000   34.0000
%               345.2000   34.0000
%               345.3000   34.0000
%               345.4000   32.0000
%               345.5000   32.0000
%               345.6000   32.0000
% include_zero: a flag determing whether 0 segments should be treated as events
% or not. include_zero == 0 means not including 0 events, which is the
% default.
%
% cevent: (output)category event. list of [start_time end_time categorynumber]
%		344.7000   344.8000  32.0000
%		344.8000   345.4000  34.0000
%		345.4000   345.7000  32.0000
%
%  This function is copied from Ikhyun's function
%  make_cevent_from_cstream.   Feb 19,2009
%  
%  Last modified by txu@indiana.edu, Jun. 19, 2014

MAX_SAMPLE_RATE = 0.1001;

num = size(cstream,1);
res = zeros(num,3);

if (isempty(cstream))
    return
end

if ~exist('sample_rate', 'var')
    warning('Sample_rate is a neccesary input for this function');
%     chunk_len = size(cstream, 1);
    sr_list = cstream(2:end,1) - cstream(1:end-1,1);
    sample_rate = mode(sr_list);
    if sample_rate > MAX_SAMPLE_RATE
        error(['Our estimate sample rate is larger than 0.1, which is ' ...
            'the largerest sample rate in multisensory project, please enter sample rate manually']);
    end
end

if ~exist('include_zero', 'var')
    include_zero = 0;
end

max_gap = sample_rate * 1.5;

gap = 0;
res(1,1) = cstream(1,1);   % start timestamp
res(1,3) = cstream(1,2);   % value
% end_time = res(1,1) + gap; % temporal end timestamp
idx = 1;
for i = 2:num
    gap = cstream(i,1) - cstream(i-1,1);
    if gap > max_gap || cstream(i,2) ~= cstream(i-1,2)
        idx = idx + 1;
        res(idx-1,2) = cstream(i-1,1) + sample_rate;
        res(idx,1) = cstream(i,1);
        res(idx,3) = cstream(i,2);
    end
end
res(idx,2) = max(res(idx,1) + gap, cstream(end, 1) + gap);
res = res(1:idx,:);

if (include_zero == 0) % not including 0 events
    nonzeros = res(:, 3) ~= 0;
    res = res(nonzeros, :);
end


