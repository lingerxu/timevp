function [all_chunks, extracted_info] = extract_ranges(all_data, all_ranges, args)
%Extract chunks from data, delegating based on data type
%   USAGE:
%   extract_ranges(DATA, RANGES, IS_VALUE_MATCHING)
%       For each range in RANGES, extracts that range of of data from DATA.
%       All the ranges of data are returned in a cell array.  DATA is
%       assumed to be of the type specified by DATA_TYPE.
%       When IS_VALUE_MATCHING set to true by the user, the function will
%       only return the extracted data with matched categorical value as
%       the range event.
%
%   DDATA can be a stream (nx2 matrix) or event type variable (nx3 matrix)
%   For stream, each row is formatted [timestamp value]. 
%   For events, each row is formated [start_time end_time value].
%
%   RANGES should be another nx2 or nx3 matrix (actually, any values
%   after the first two are ignored).  Each row is a time range,
%   formatted [begin_time end_time].  This is the same format as an
%   event variable or a list of experimental trials, so you could pass
%   one of those in unmodified.  All data points that have time stamps
%   such that range_start <= timestamp < range_end will be included in
%   the results.
%
%   The return value is a vertical cell array, with a portion of DATA in
%   each cell.  If DATA_TYPE is cont or cstream, the cells contain exact
%   copies of pieces of DATA.  If DATA_TYPE is event or cevent, then each
%   cell contains the intersection of the events with one range.
%
%   See also: CELLFUN

% IS_VALUE_MATCHING is not a required input argument.
if nargin < 3
    args = struct([]);
end

if isfield(args, 'is_value_matching')
    is_value_matching = args.is_value_matching;
else
    is_value_matching = false;
end

if (~isfield(args, 'whence') && isfield(args, 'interval')) || ...
    (isfield(args, 'whence') && ~isfield(args, 'interval'))
    error(['Error! Input should either have both fields of ' ...
        '''whence'' and ''interval'' or neither of them']);
end
has_whence = false;

float_tolerance = 1e-12;

if ~ iscell(all_data)
    all_data = {all_data};
end

ranges_by_chunk = matchArgumentSize(all_data, all_ranges);
num_chunks = size(all_data, 1);

all_chunks = cell(num_chunks, 1);

if isfield(args, 'whence') && isfield(args, 'interval')
    has_whence = true;
    ranges_whence = cell(num_chunks, 1);
end

for cidx = 1:num_chunks
    data = all_data{cidx};
    
    if isempty(data)
        continue
    end
    
    ranges = ranges_by_chunk{cidx};
    chunks = cell(size(ranges, 1), 1);
    chunk_one = [];
    if has_whence
        range_new = [];
    end

    % check the data format
    data_cols = size(data, 2);

    for range_idx = 1:size(ranges, 1)
        range_one = ranges(range_idx, :); %range_one(1) is start, range_one(2) is end.
        has_range_value = size(range_one, 2) == 3;

        if has_whence
            range_one = cevent_relative_intervals(range_one, args.whence, args.interval);
            range_new = [range_new; range_one];
        end

        % when data is a stream
        if data_cols == 2
            % These two arrays are logical indicies for data.
            ge_start = range_one(1) <= data(:, 1) + float_tolerance;
            lt_end = data(:, 1) + float_tolerance < range_one(2);

            chunk_one = data(ge_start & lt_end, :);
        % when data is event type
        elseif data_cols == 3
            chunk_one = get_event_in_range(data, range_one);
        else
            error(['extract_ranges:invalid data type. The input data can only be stream [time category_number]', ...
            ' or event type [time_start time_end category_number].']);
        end

        % if the user only wants data with matching value
        if has_range_value && is_value_matching
            chunk_one = get_matching_segments(chunk_one, range_one);
        end

        chunks{range_idx} = chunk_one;
    end
    if has_whence
        ranges_whence{cidx} = range_new;
    end
    all_chunks{cidx} = chunks;
end

if has_whence
    ranges_by_chunk = ranges_whence;
end

if num_chunks == 1
    all_chunks = all_chunks{1};
    extracted_info.ranges = ranges_by_chunk{1};
else
    extracted_info.ranges = ranges_by_chunk;
end

end

function matchedArgument = matchArgumentSize(desired, realArgument)
% matchArgumentSize(desired, realArgument)
% Returns a cell array of arguments with the same size as
% DESIRED, so then you can loop through desired and the
% arguments together.
%
% if realArgument is not a cell array, it duplicates it once
% for each element in desired.
%
% if realArgument is a cell array, it makes sure it's the same
% size as DESIRED.
if ~ iscell(realArgument)
    matchedArgument = repmat({ realArgument }, size(desired));
else
    if ~ isequal(size(desired), size(realArgument))
        error('Argument must be non-cell, or cell with same size as other arguments');
    end
    matchedArgument = realArgument;
end
end
