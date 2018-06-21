function [ sections ] = stream_extract_ranges(streams, ranges)
%Extract ranges of data from continuous or cstream data
%   stream_extract_ranges(DATA, RANGES)
%       Goes through each range in RANGES.  For each range, finds the chunk
%       of data in DATA that is within that range, extracts that chunk, and
%       returns the list of chunks as a cell array.
%       
%   DATA should be a continuous or cstream variable.  It should be an nx2
%   matrix, with one row per sample.  Each row is formatted [timestamp
%   value].  This function also supports cont2, cont3, and so on: these
%   formats don't work in the visualization program, but work with many of
%   the matlab scripts.  They are an NxD matrix, with the columns D
%   consisting of one timestamp and several values.  The function also
%   supports cstreams, which have an identical storage format to cont
%   variables.
%
%   RANGES should be another nx2 or nx3 matrix (actually, any values
%   after the first two are ignored).  Each row is a time range,
%   formatted [begin_time end_time].  This is the same format as an
%   event variable or a list of experimental trials, so you could pass
%   one of those in unmodified.  All data points that have time stamps
%   such that range_start <= timestamp < range_end will be included in
%   the results.
%
%   The return value is a vertical cell array, and the contents of each
%   cell is a section of DATA.  If there is no data in some range, the
%   corresponding cell of the return array will contain an empty matrix
%   (though the empty matrix might not equal []).
%

% create a cell array with as many rows as there are ranges
sections = cell(size(ranges, 1), 1);

float_tolerance = 1e-12;

if isempty(streams)
    sections = {};
    return
end

for range_idx = 1:size(ranges, 1)

    range = ranges(range_idx, :); %range(1) is start, range(2) is end.
    
    % These two arrays are logical indicies for streams.
    ge_start = range(1) <= streams(:, 1) + float_tolerance;
    lt_end = streams(:, 1) + float_tolerance < range(2);
    
    sections{range_idx} = streams(ge_start & lt_end, :);
end

end

