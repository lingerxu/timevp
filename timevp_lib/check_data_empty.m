function is_empty = check_data_empty(data, flag_allow_empty_cell)

if nargin < 2
    flag_allow_empty_cell = true;
end

if iscell(data)
    if flag_allow_empty_cell
        has_data = false;
        for i = 1:size(data, 1)
            for j = 1:size(data, 2)
                has_data = has_data || ~isempty(data{i, j});
            end
        end
        is_empty = ~has_data;
    else
        is_empty = false;
        for i = 1:size(data, 1)
            for j = 1:size(data, 2)
                is_empty = is_empty || isempty(data{i, j});
            end
        end
    end
    
else
    is_empty = isempty(data);
end