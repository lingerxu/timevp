function [allpairs, events1_wo, events2_wo] = extract_pairs(events1, events2, timing_relation, mapping, args)
%% Overview
% Finds moments from two cevents that match a specified temporal relation
% 
% This function will loop through all events from Variable1 (by either specifying a csv file 
% or a variable name) and find those events in Variable2 that match the temporal  
% relation given in the threshold parameter. These matches (or pairs)
% are output in a resulting CSV file.
% 
% author: sbf@umail.iu.edu
% 
%% Required Arguments
% filename1
%       -- string, the full path or relative path to a
%          .mat or .csv file
%       -- data can either be cstream or cevent format
%       -- if .mat, data should be saved under sdata.data structure, like
%          in multiwork format
%       -- for .csv files, one can specify the number of headers and
%          columns, see the optional arguments below
% filename2
%         -- see filename1
% timing_relation
%         -- string of characters that indicate the temporal relations
% 
%         on1 and off1 correspond to event1's onset and offset, respectively.
%         on2 and off2 correspond to event2's onset and offset, respectively.
% 
%         'more(A,B,T)' means A comes before B with a gap more than T seconds.
%         'less(A,B,T)' means A comes before B with a gap less than T seconds.
%         A and B are to be replaced with any combination of on1, off1, on2,
%         and off2. T is optional, and if it is not provided, will not
%         consider the gap between A and B.
% 
%         e.g.
%         timing_relation = 'more(on1, on2, 4)' means on1 must come before on2 in time,
%         with a gap of more than 4 seconds.
%         timing_relation = 'less(off2, on1, 2)' means off2 must come before on1 in time, with a
%         gap of less than 2 seconds.
% 
%         Note, you can chain multiple timing relations together using '&' or '|'. This
%         means AND and OR, respectively. Use parentheses to indicate
%         more complex timings.
%
%         e.g.  
%         timing_relation = 'more(on1, off1, 4) & less(on1, on2, 2)' means events in
%         Variable1 must be greater than 4 seconds long, and must start at most
%         2 seconds before the events in Variable2
% 
% mapping
%         -- Nx2 array that indicates which categories are to be matched
%            together.
% savefilename
%         -- string indicating where to save the CSV file. The folder
%            must exist.
% 
%% Optional Arguments
% args.pairtype
%         -- single-dimension array of integers whose length matches the
%            length of 'mapping'. Allows user to tag each row in 'mapping' to a type.
% args.cevent_trials
%       -- string, the full path or relative path to a
%          .mat or .csv file
%       -- The timing information in this file is used to cut the data into
%          trials. Ultimately this ensures that events from one trial
%          cannot be paired with events from a second trial, even if the
%          temporal relation holds.
% args.files_numheaders
%       -- integer array of size 2, indicating how many
%          headers are in filename1 and filename2, respectively
%       -- e.g. [1 1] for means to skip 1 header file for both
% args.files_columns
%       -- cell array of size 2, one cell for each filename, indicating which columns
%          to grab from the .csv file
%       -- e.g. {[3 4 5], [6 7 8]} for the two filenames
%          [3 4 5] is for filename1, [6 7 8] is for filename2
%       -- if empty, just grab all columns
% args.cevent_trials_numheaders
%       -- integer array of size 2, indicating how many
%          headers are in filename1 and filename2, respectively
%       -- e.g. [1 1] for means to skip 1 header file for both
% args.cevent_trials_columns
%       -- 1x3 integer array indicating which columns
%          to grab from the .csv file
%       -- if empty, just grab all columns
%
% The following arguments control many to many mapping
% Consider the following many to many mapping from cev1 and cev2
% 10, 15
% 11, 15
% 11, 16
% 11, 17
% To force 1 to 1 mapping, set either first_n_cev1 or last_n_cev1 to 1
% args.first_n_cev1
%         -- integer indicating to only output first N pairings of cev 1
% args.first_n_cev2
%         -- integer indicating to only output first N pairings of cev 2
% args.last_n_cev1
%         -- integer indicating to only output last N pairings of cev 1
% args.last_n_cev2
%         -- integer indicating to only output last N pairings of cev 2

% Output is a CSV with each row respresenting a pair. The pairs can be
% many-to-many.
%
% Two additional CSV files (_cev1wo.csv and _cev2wo.csv) are generated indicating which cevents from cev1
% and cev2 were not paired.
%
% Only in-trial data will be considered, and cevents from one trial cannot
% be paired with cevents from another trial (even if the timing holds true).
%%

if ~exist('args', 'var') || isempty(args)
    args = struct();
end

if ~isfield(args, 'cevent_trials')
    args.cevent_trials = [];
end

if ~isfield(args, 'first_n_cev1')
    args.first_n_cev1 = [];
end

if ~isfield(args, 'last_n_cev1')
    args.last_n_cev1 = [];
end

if ~isfield(args, 'first_n_cev2')
    args.first_n_cev2 = [];
end

if ~isfield(args, 'last_n_cev2')
    args.last_n_cev2 = [];
end

if ~exist('mapping', 'var')
    mapping = [];
end

if ~isfield(args, 'pairtype')
    args.pairtype = ones(1, numel(mapping));
end
allpairs = [];
events1_wo = [];
events2_wo = [];

if ~isempty(events1) && ~isempty(events2)
    events1 = sortrows(events1, [1 2 3]);
    events2 = sortrows(events2, [1 2 3]);
    
    num_events1 = size(events1, 1);
    num_events2 = size(events2, 1);
    
    events1 = [events1 (1:num_events1)'];
    events2 = [events2 (1:num_events2)'];
    
    on2 = events2(:,1);
    off2 = events2(:,2);
    
    prealloc = cell(size(events1,1),1);
    for c = 1:numel(prealloc)
        on1 = events1(c,1);
        off1 = events1(c,2);
        
        log = eval(timing_relation);
        cev2matched = events2(log,:);
        prealloc{c,1} = [repmat(events1(c,:), size(cev2matched,1), 1), cev2matched];
    end
    
    allpairs = vertcat(prealloc{:});
    
    if ~isempty(allpairs)
        % on off cat idx  on  off cat idx
        % 1   2   3   4   5   6   7   8
        IDX_ON1 = 1;
        IDX_OFF1 = 2;
        IDX_CAT1 = 3;
        IDX_INS1 = 4;
        IDX_ON2 = 5;
        IDX_OFF2 = 6;
        IDX_CAT2 = 7;
        IDX_INS2 = 8;
        IDX_PAIR = 9;
        
        % only consider the pairs specified in mapping
        if ~isempty(mapping)
            if ~iscell(mapping)
                mapping = num2cell(mapping, 2);
            end
            for d = 1:size(allpairs, 1)
                pair = allpairs(d,[IDX_CAT1 IDX_CAT2]);
                log = cellfun(@(a) isequal(pair, a), mapping);
                if sum(log) > 0
                    allpairs(d, IDX_PAIR) = args.pairtype(log);
                else
                    allpairs(d, IDX_PAIR) = 0;
                end
            end
            allpairs(allpairs(:, IDX_PAIR) == 0,:) = [];
        else
            % fill pairtype column with 'cat0cat'
            cat1 = arrayfun(@num2str, allpairs(:, IDX_CAT1), 'un', 0);
            cat2 = arrayfun(@num2str, allpairs(:, IDX_CAT2), 'un', 0);
            bothcat = cellfun(@(a,b) str2double(strcat(a, '0', b)), cat1, cat2);
            allpairs(:,11) = bothcat;
        end
        
        uidx = unique(allpairs(:, IDX_INS1));
        idx_keep = [];
        if ~isempty(args.first_n_cev1)
            for u = 1:numel(uidx)
                idx_first = find(allpairs(:, IDX_INS1) == uidx(u), args.first_n_cev1, 'first');
                idx_keep = cat(1, idx_keep, idx_first);
            end
        end
        if ~isempty(args.last_n_cev1)
            for u = 1:numel(uidx)
                idx_last = find(allpairs(:, IDX_INS1) == uidx(u), args.last_n_cev1, 'last');
                idx_keep = cat(1, idx_keep, idx_last);
            end
        end
        
        idx_keep = unique(idx_keep);
        
        if ~isempty(idx_keep)
            allpairs = allpairs(idx_keep, :);
        end
        
        uidx = unique(allpairs(:, IDX_PAIR));
        idx_keep = [];
        if ~isempty(args.first_n_cev2)
            for u = 1:numel(uidx)
                idx_first = find(allpairs(:, IDX_PAIR) == uidx(u), args.first_n_cev2, 'first');
                idx_keep = cat(1, idx_keep, idx_first);
            end
        end
        if ~isempty(args.last_n_cev2)
            for u = 1:numel(uidx)
                idx_last = find(allpairs(:, IDX_PAIR) == uidx(u), args.last_n_cev2, 'last');
                idx_keep = cat(1, idx_keep, idx_last);
            end
        end
        
        idx_keep = unique(idx_keep);
        
        if ~isempty(idx_keep)
            allpairs = allpairs(idx_keep, :);
        end
        log = ~ismember(events1(:, end), allpairs(:, IDX_INS1));
        events1_wo = events1(log,:);
        log = ~ismember(events2(:, end), allpairs(:, IDX_INS2));
        events2_wo = events2(log,:);
    end
end
end

function log = less(t1,t2,thres)
less_dif = t2 - t1;
log = less_dif > -0.001;
if exist('thres', 'var')
    log = log & less_dif <= thres;
end
end

function log = more(t1,t2,thres)
more_dif = t2 - t1;
log = more_dif > -0.001;
if exist('thres', 'var')
    log = log & more_dif >= thres;
end
end