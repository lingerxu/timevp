function results = event_sort_by_time(event_in, refer_column)
% Sorts the event according to a specified time column

if refer_column > 2
    error('Invalid REFER_COLUMN value!');
end

[~, temp_idx] = sort(event_in(:, refer_column));
results = event_in(temp_idx, :);