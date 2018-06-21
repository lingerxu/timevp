function [all_data] = align_streams(time_base, streams, varargin)
%Aligns several cont/cstream variables on time, and sticks them all together
%
% align_streams(time_base, streams)
% align_streams(time_base, streams, ...)
%
% The input is a cell array of cont or cstream variables.  They are aligned
% based on the timestamps in the first argument, which should be an Nx1
% vector of timestamps.  The values from each variable are put together in
% the output.
%
%
% If there are T timestamps in the time basis, and V variables (with
% one data column each), the output is a TxV matrix.  Each column is the
% value from one of the variables (in the same order that you passed them
% in).
%
% This function should correctly handle input data with multiple columns of
% values.
%
% This function has to interpolate to find variable values for times
% between the actual sample times.  The default is:  If a particular stream
% has only integer values, use zero-order hold (step function)
% interpolation ("zoh").  Otherwise, use linear interpolation.
%
% The default is to trust the timestamps given in the input streams.  If
% you want to force time to be relative, that is, set each stream to start
% at zero, use the 'ForceZero' argument:
%
% align_streams(time_base, streams, 'ForceZero')
%
% If the defaults for interpolation are not good enough, you can use the
% 'InterpMethod' argument:
%
% align_streams(time_base, streams, 'InterpMethod', 'linear')
%
% The argument after 'InterpMethod' is either a single string or object, or a
% cell array of them, one per stream.  Each entry is either the string
% 'zoh', 'linear', or some other valid interpolation method.  
%
% See also: timeseries/setinterpmethod
%

version = '$Id: align_streams.m 2000 2011-04-18 20:30:57Z thgsmith@ADS.IU.EDU $';

all_data = [];

% If they didn't give us any data... just return nothing?
if isempty(streams)
    return
end

opt_force_zero = 0;
opt_use_default_interpolation = 1;
interp_method = [];

I = 1;
while I <= length(varargin)
    arg = varargin{I};
    switch arg
        case 'ForceZero'
            opt_force_zero = 1;
        case 'InterpMethod'
            if I+1 > length(varargin)
                error('InterpMethod argument needs another argument after it');
            end
            opt_use_default_interpolation = 0;
            I = I + 1;
            interp_method = varargin{I};
            % if they specify a *list* of interpolation methods, 
            % we should have one interpolation method for each stream.
            if iscell(interp_method)
                if length(interp_method) ~= length(streams)
                    error('Must specify no interpolation methods, exactly one, or one per stream');
                end
            end
        otherwise
            error('Invalid argument: only ''ForceZero'' and ''InterpMethod'' are accepted.');
    end
    
    I = I + 1;
end
            
            
            
        

% determine the size of the output
num_vars = length(streams);
cols_by_var = cellfun(@(stream) size(stream, 2), streams);
num_cols = sum(cols_by_var) - num_vars;
num_times = length(time_base);

% the data (not including time) that will be returned
all_data = nan(num_times, num_cols);


if opt_force_zero
    time_base(:, 1) = time_base(:, 1) - time_base(1, 1);
end


% This loop copies resampled data into the output variable

%col_idx : the first column of data from the current variable
col_idx = 1;
for var_idx = 1:numel(streams)
    var = streams{var_idx};
    if size(var, 1) < 2
        continue
    end
    num_values = size(var, 2) - 1;
    
    % possibly adjust all streams so timestamp starts at zero
    if opt_force_zero
        var(:, 1) = var(:, 1) - var(1, 1);
    end
    
    ts = timeseries(var(:, 2:end), var(:, 1));
    
    
    % Are we guessing interpolation methods?
    if opt_use_default_interpolation
        % If it looks like integers, use zero-order hold
        % otherwise, linear.
        if all(round(ts.Data) == ts.Data)
            interpolation = 'zoh';
        else
            interpolation = 'linear';
        end
    else
        % we're not guessing, use the explicitly-provided one.
        if iscell(interp_method)
            interpolation = interp_method{var_idx};
        else
            interpolation = interp_method;
        end
    end
    
    
    ts_r = resample(ts, time_base, interpolation);
%     if length(time_base) ~= length(ts_r)
%         disp('uh oh!')
%         length(time_base)
%         length(ts_r)
%         ts_r
%         disp('huh')
%     end
%     size(all_data)
%     size(ts_r.Data)
    all_data(:, col_idx:(col_idx + num_values - 1)) = ts_r.Data;
    
    col_idx = col_idx + num_values;
end


