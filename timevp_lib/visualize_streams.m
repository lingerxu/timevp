function visualize_streams(data, args, cont_data, cont_args)
% This is a plotting function for visualizing temperol pattens
% For input format, please see the function get_test_data() below
% 
% Example:
% >>>  args.legend = {'Event1'; 'Event2'; 'Event3'; 'Event4'};
% >>>  plot_temp_patterns({}, 1, args)

% add other vs target

% debugging:
% visualize_cevent_patterns(data, args)

LENGTH_CEVENT = 3;

figure_bgcolor = [1 1 1];
text_bgcolor = figure_bgcolor;
if isfield(args, 'row_text')
    row_text = args.row_text;
else
    row_text = [];
end

% if isfield(args, 'text_offset')
%     text_offset = args.text_offset;
% else
%     text_offset = -0.1;
% end

is_data_empty = check_data_empty(data);

if is_data_empty
    warning('Input data is empty. Function visualize_streams() will exist now.')
    return;
%     data = get_test_data();
end

num_rows = size(data, 1);
if num_rows > 2 % there are multiple trials
    is_multi_rows = true;
else
    is_multi_rows = false;
end

if is_multi_rows
    data = flip(data, 1);
end

if isfield(args, 'windows')
%     max_trial_due = max(args.trial_times(:,2)-args.trial_times(:,1));
%     text_offset = text_offset * (max_trial_due/100);
    text_offset = args.windows(1,1) - 0.1;
    
    % reverse visualization order
    if is_multi_rows
        args.windows = flip(args.windows, 1);
    end
    if isempty(row_text)
        row_text = cell(1, num_rows);
        for ridx = 1:num_rows
            text_one = sprintf('%d - %d', args.windows(ridx, 1), args.windows(ridx, 2));
            row_text{ridx} = text_one;
        end
    end
end

if isfield(args, 'time_ref') && is_multi_rows
    args.time_ref = flip(args.time_ref, 1);
end

if ~exist('args', 'var')
    args.info = 'No user input information here';
end

% How many instances on each figure
if isfield(args, 'MAX_ROWS')
	MAX_ROWS = args.MAX_ROWS;
else
    MAX_ROWS = 20;
end

if isfield(args, 'colormap')
    colormap = args.colormap;
else
    colormap = get_colormap();
end

if isfield(args, 'color_code')
    color_code = args.color_code;
else
    color_code = 'category';
end

if isfield(args, 'sample_rate')
    sample_rate = args.sample_rate;
else
    sample_rate = timevp_config_dataset_info();
end

if isfield(args, 'is_closeplot')
    is_closeplot = args.is_closeplot;
elseif isfield(args, 'dir_plots') || isfield(args, 'save_name')
    is_closeplot = true;
else
    is_closeplot = false;
end

% preprocess cell data, transfer it into a matrix
if iscell(data)
    num_data_stream = size(data, 2);
    data_new = {};
    max_num_cvent_data_column = nan(1,num_data_stream);
    
    % go through each stream (each column in the cell data)
    for dsidx = 1:num_data_stream
        data_column = data(:,dsidx);
        %var_type = get_data_type(args.var_name_list{dsidx});
        
        data_column_length = cellfun(@(data_one) ...
            size(data_one, 1), ...
            data_column, ...
            'UniformOutput', false);
        data_column_length = vertcat(data_column_length{:});
        list_cevent_length = unique(data_column_length(:,1));
        max_data_column_length = max(list_cevent_length);
        
        % if data is a cell and needs to be processed
        if sum(~ismember(list_cevent_length, 1)) > 0
            data_column_new = nan(length(data_column), max_data_column_length*LENGTH_CEVENT);
            for didx = 1:length(data_column)
                data_column_one = data_column{didx};
                
                % convert stream to events
                if size(data_column_one, 2) < 3
                    data_column_one = stream2event(data_column_one, sample_rate);
                end
                
                for doidx = 1:max_data_column_length
                    if doidx <= size(data_column_one,1)
                        data_column_new(didx,(doidx-1)*3+1:doidx*3) = ...
                            data_column_one(doidx,1:3);
                    end
                end
            end
        else
            data_column_new = vertcat(data_column{:});
            max_data_column_length = list_cevent_length(1);
        end
        if max_data_column_length < 1
            tmp_len = length(data_column_length);
            data_column_new = nan(tmp_len, 3);
        end
        data_new{dsidx} = data_column_new;
        max_num_cvent_data_column(dsidx) = max(max_data_column_length, 1);
    end
    data = horzcat(data_new{:});
    tmp_count = 0;
    for tmpi = 1:length(max_num_cvent_data_column)
        prev_tmp_count = tmp_count + 1;
        tmp_count = tmp_count + max_num_cvent_data_column(tmpi);
        stream_position_new(prev_tmp_count:tmp_count) = ...
            tmpi;
    end
    if ~isfield(args, 'stream_position')
        args.stream_position = stream_position_new;
    end
end

% end
[rows, cols] = size(data);
if ~iscell(data)
    cols = cols / LENGTH_CEVENT;
end

if ~isfield(args, 'stream_position')
    args.stream_position = ones(1,cols);
end

if isfield(args, 'legend')
    if ~isfield(args, 'legend_location')
        if ~exist('cont_args', 'var')
            args.legend_location = 'NorthEastOutside';
        else
            args.legend_location = 'NorthWestOutside';
        end
    end
    if ~isfield(args, 'legend_orientation')
        args.legend_orientation = 'vertical';
    end
end

if isfield(args, 'ForceZero')
    if isfield(args, 'ref_index')
        ref_index = args.ref_index;
    elseif isfield(args, 'ref_column')
        ref_column = args.ref_column;
    else
        ref_column = 2;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~iscell(data)
        if isfield(args, 'time_ref')
            time_ref = args.time_ref;
        elseif exist('ref_column', 'var')
            time_ref = data(:,ref_column);
        else
            time_ref = data(ref_index(1), ref_index(2));
            time_ref = repmat(time_ref, size(data,1), 1);
        end
        
        tmp_ref_nan = sum(isnan(time_ref));
        if tmp_ref_nan > 0
            error('Error! There is nan data in the reference time column!');
        end
        data_mat = data;
    else
        data_mat = cell2mat(data);
        if isfield(args, 'time_ref')
            time_ref = args.time_ref;
        elseif exist('ref_column', 'var')
            time_ref = data(:,ref_column);
        else
            time_ref = data(ref_index(1), ref_index(2));
            time_ref = repmat(time_ref, size(data,1), 1);
        end
        if sum(isnan(time_ref)) > 0
%             time_idx_list = sort([1:3:size(data_mat,2) 2:3:size(data_mat,2)]);
            nan_count_data = sum(isnan(data_mat));
            [I J] = find(nan_count_data);
            ref_column = min(setdiff(1:size(data_mat,2), J));
            if isfield(args, 'ref_column')
                warning(['The reference column for ForceZero time has NaN ' ...
                    'values and thus is changd to column ' int2str(ref_column) '.']);
            end
            time_ref = data_mat(:,ref_column);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j = cols:-1:1
        data_mat(:,j*LENGTH_CEVENT-1) = data_mat(:,j*LENGTH_CEVENT-1) - time_ref;
        data_mat(:,j*LENGTH_CEVENT-2) = data_mat(:,j*LENGTH_CEVENT-2) - time_ref;
    end
else
    data_mat = data;
end

if strcmp(color_code, 'category')    
    value_idx_list = 3:LENGTH_CEVENT:size(data_mat,2);
    max_cevent_value = max(max(data_mat(:,value_idx_list)));
end

% to calculate how many figure will be needed in total
num_figures = floor(rows/MAX_ROWS)+ceil(mod(rows/MAX_ROWS, 1));

for fidx = 1:num_figures
    if isfield(args, 'figure_visible') && ~args.figure_visible
        h = figure('Visible','Off');
    else
        h = figure;
    end
    
    if exist('cont_data', 'var')
        subplot(1,2,1);
        
        if ~exist('cont_args', 'var')
            cont_args.info = 'No user input information here';
        end
        
        cont_args.stream_position = args.stream_position;
        
        if ~isfield(cont_args, 'colormap')
            cont_args.colormap = {};
        end
        
        if ~isfield(cont_args, 'LineWidth')
            cont_args.LineWidth = 1;
        end        
        
        if isfield(cont_args, 'legend') && ~isfield(cont_args, 'legend_location')
            cont_args.legend_location = 'NorthEastOutside';
        end
    end
    %% The first half of the figure
    hold on;
    
    % to get how many rows/instances will be in this figure
    if fidx == num_figures
        if mod(rows, MAX_ROWS) == 0
            rows_one = MAX_ROWS;
        else
            rows_one = mod(rows, MAX_ROWS);
        end
    else
        rows_one = MAX_ROWS;
    end
    
    if isfield(args, 'position_row_width')
        position_row_width = args.position_row_width;
    else
        position_row_width = 150;
    end
    
    if isfield(args, 'set_position')
        set(h, 'Position', args.set_position, 'Color', figure_bgcolor);
    else
        fig_position = [50 50 1600 (100+position_row_width*rows_one)];
        set(h, 'Position', fig_position, 'Color', figure_bgcolor);
    end
    
    % to get the sub chunk of data for this figure
    if fidx == num_figures
        sub_data_mat = data_mat((fidx-1)*MAX_ROWS+1:end,:);
    else
        sub_data_mat = data_mat((fidx-1)*MAX_ROWS+1:(fidx)*MAX_ROWS,:);
    end
    
    start_time_idx = 1:LENGTH_CEVENT:size(sub_data_mat,2);
    end_time_idx = 2:LENGTH_CEVENT:size(sub_data_mat,2);
    
    if isfield(args, 'xlim_list')
        xlim_list = args.xlim_list;
        min_x = xlim_list(1);
        max_x = xlim_list(2);
    else
        min_x = nanmin(nanmin(sub_data_mat(:,start_time_idx))) - 0.1;
        max_x = nanmax(nanmax(sub_data_mat(:,end_time_idx))) + 0.1;
        xlim_list = [min_x max_x];
        max_y = 0;
    end
    
    text_offset = min_x - (max_x-min_x)/100;
    length_of_streams = length(unique(args.stream_position));
    each_stream_space = 1/length_of_streams;
    
    % draw legend cubics
    if isfield(args, 'legend')
        for lidx = 1:length(args.legend)
            x = [min_x, min_x, min_x, min_x];
            y = [0.1, 1, 1, 0.1];
            if iscell(colormap)
                color = colormap{lidx};
            else
                color = colormap(lidx, :);
            end
            fill(x, y, color);
        end
    end

    if ~isempty(row_text)
        row_text_pos_y = nan(MAX_ROWS, 1);
    end
    
    % Draw the background bars - white / grey
    for rowidx = 1:MAX_ROWS
        % Draw left to right in each row
        x = [min_x, max_x, max_x, min_x];
        y = [(rowidx-1)*(1+each_stream_space), (rowidx-1)*(1+each_stream_space), ...
            rowidx*(1+each_stream_space), rowidx*(1+each_stream_space)];
        color = [1 1 1];
%         if mod(rowidx, 2) < 1
%             color = [1 1 1];
%         else
%             color = [0.8 0.8 0.8];
%         end
        fill(x, y, color);
    end
    
    % Draw actual instances row by row
    for rowidx = 1:rows_one
%         min_y_row = 99;
%         max_y_row = 0;
        % Draw left to right in each row
        pos_num_old = -1;
        for columnidx = 1:cols
            cevent_one = data_mat(rowidx+(fidx-1)*MAX_ROWS,(columnidx-1)*3+1:(columnidx-1)*3+3);
            pos_num_new = args.stream_position(columnidx);
            if isfield(args, 'annotation')
                if iscell(args.annotation)
                    var_text_one =  args.annotation{pos_num_new};
                elseif ischar(args.annotation)
                    var_text_one = sprintf('%s%d', args.annotation, pos_num_new);
                end
            end
            
            if ~(isempty(cevent_one) || sum(isnan(cevent_one)) > 0)
                start_time = cevent_one(1);
                end_time = cevent_one(2);
                
                if strcmp(color_code, 'category')
                    color = get_color(cevent_one(3), max_cevent_value, colormap);
                elseif strcmp(color_code, 'variable')
                    color = get_color(columnidx, cols, colormap); %get_color(cevent_one(3));
%                     args.edge_color = get_color(mod(cevent_one(3), 10), max_cevent_value, colormap);
                end
                [~, y] = create_square(start_time, end_time, rowidx, columnidx, color, args);
                text_color = [0 0 0];
            elseif (cevent_one(3) == 0)
                text_color = [1 0 0];
                [~, y] = create_square(0, 0, rowidx, columnidx, [1 1 1], args);
            else % if there is variable, but no data inside
                text_color = [1 1 1] * 0.8;
                [~, y] = create_square(0, 0, rowidx, columnidx, [1 1 1], args);
            end
            
            y_new = mean(y);
            if pos_num_old ~= pos_num_new && isfield(args, 'annotation')
                text(text_offset, y_new, var_text_one, 'FontSize', 8, 'Color', text_color, ...
                    'BackgroundColor', text_bgcolor, 'Interpreter', 'none', 'HorizontalAlignment', 'right');
            end
            pos_num_old = pos_num_new;
        end % end of columniedx
        if ~isempty(row_text)
            row_text_pos_y(rowidx) = y(1);
        end
        max_y = rowidx*(1+each_stream_space);
    end
    
    % draw verticle lines according to the user
    if isfield(args, 'vert_line')
        for vidx = 1:length(args.vert_line)
            x = [args.vert_line(vidx), args.vert_line(vidx), args.vert_line(vidx)+0.01, args.vert_line(vidx)+0.01];
            y = [0, max_y, max_y, 0];
            color = [1 0 0];
            fill(x, y, 'r', 'EdgeColor', color);
        end
    end

    % set transpenrency, so the overlaps between cevents can be shown    
    if isfield(args, 'transparency')
        alpha(args.transparency);
    end
    
    if isfield(args, 'legend')
        new_legend = cell(size(args.legend));
        for i = 1:length(args.legend)
            new_legend{i} = plot_no_underline(args.legend{i});
        end
        
        legend(new_legend, 'Location', args.legend_location, 'Orientation', args.legend_orientation);
        legend('boxoff');
    end
    
    if ~isempty(row_text)
        for rowidx = 1:rows_one
            txrowidx = rowidx+(fidx-1)*MAX_ROWS;
            if isfield(args, 'row_text_type') && strcmp(args.row_text_type, 'time')
                row_text_one = sprintf('%s: %.1f-%.1f', row_text{txrowidx}, args.trial_times(rowidx, 1), args.trial_times(rowidx, 2));
            elseif iscell(row_text)
                row_text_one = row_text{txrowidx};
            else
                row_text_one = row_text;
            end
            text(max_x+0.1, row_text_pos_y(rowidx), row_text_one, 'FontWeight', 'bold', 'Interpreter', 'none');%, 'FontSize', 12, 'BackgroundColor', [1 1 1]); -1*length(row_text_one)
        end
    end
    
    if isfield(args, 'ylim_list')
        ylim_list = args.ylim_list;
    else
        ylim_list = [0 max_y];
    end
    
    xlim(xlim_list);
    ylim(ylim_list);
    
    if isfield(args, 'title')
        title(plot_no_underline(args.title), 'FontWeight', 'bold'); %, 'FontSize', 12, 'BackgroundColor', [1 1 1]
    end
    
    if isfield(args, 'xlabel')
        xlabel(args.xlabel);
    end
    
    if isfield(args, 'ForceZero')
        set(gca,'xtick',[]);
    end
    
    %% the second half of the plot if applicable    
    if exist('cont_data', 'var')
        subplot(1,2,2);
        hold on;
        
        % draw legend cubics
        if isfield(cont_args, 'legend') && isfield(cont_args, 'colormap')
            for lidx = 1:length(cont_args.legend)
                color = get_color(lidx, length(cont_args.legend), colormap);
                line([0], [0], 'Color', color);
            end
        end
        
        % to get the sub chunk of cont_data for this figure
        if fidx == num_figures
            sub_cont_data_mat = cont_data((fidx-1)*MAX_ROWS+1:end,:);
            sub_time_ref = time_ref((fidx-1)*MAX_ROWS+1:end,:);
        else
            sub_cont_data_mat = cont_data((fidx-1)*MAX_ROWS+1:(fidx)*MAX_ROWS,:);
            sub_time_ref = time_ref((fidx-1)*MAX_ROWS+1:(fidx)*MAX_ROWS,:);
        end

        min_x = 99;
        max_x = -99;        
        for rowidx = 1:rows_one
            vec = sub_cont_data_mat{rowidx,1};
            tmp_min_x = nanmin(vec(:,1) - sub_time_ref(rowidx));
            tmp_max_x = nanmax(vec(:,1) - sub_time_ref(rowidx));
            if tmp_min_x < min_x
                min_x = tmp_min_x;
            end
            if tmp_max_x > max_x
                max_x = tmp_max_x;
            end
        end
        min_x = min_x - 0.2;
        max_x = max_x + 0.2;

        % Draw the background bars - white / grey
        for rowidx = 1:MAX_ROWS
            % Draw left to right in each row
            x = [min_x, max_x, max_x, min_x];
            y = [(rowidx-1)*(1+each_stream_space), (rowidx-1)*(1+each_stream_space), ...
                rowidx*(1+each_stream_space), rowidx*(1+each_stream_space)];
            if mod(rowidx, 2) < 1
                color = [1 1 1];
            else
                color = [0.8 0.8 0.8];
            end
            fill(x, y, color);
        end
        
        if isfield(cont_args, 'target_value_ref_column')
            target_value_ref_column = cont_args.target_value_ref_column;
            if mod(target_value_ref_column, LENGTH_CEVENT) ~= 0
                error('Invalid target_value_ref_column value!');
            end                

            value_column = sub_data_mat(:,target_value_ref_column);
        end
        
        % start draw lines one by one
        for rowidx = 1:rows_one
            if isfield(cont_args, 'target_value_ref_column')
                value_id = value_column(rowidx);                
                vec = sub_cont_data_mat{rowidx,value_id};
                
                if ~isempty(cont_args.colormap)
                    color = cont_args.colormap{value_id};
                else
                    color = get_color(value_id, size(sub_cont_data_mat, 2), colormap); %get_color(cevent_one(3));
                end
                
                create_line(vec, rowidx, sub_time_ref(rowidx), color, cont_args);
            else
                for cdmi = 1:size(sub_cont_data_mat, 2)                
                    if ~isempty(cont_args.colormap)
                        color = cont_args.colormap{cdmi};
                    else
                        color = get_color(cdmi, size(sub_cont_data_mat, 2), colormap); %get_color(cevent_one(3));
                    end

                    vec = sub_cont_data_mat{rowidx,cdmi};
                    create_line(vec, rowidx, sub_time_ref(rowidx), color, cont_args);
                end
            end
        end
        
        % draw verticle lines according to the user
        if isfield(cont_args, 'vert_line')
            for vidx = 1:length(cont_args.vert_line)
                x = [cont_args.vert_line(vidx), cont_args.vert_line(vidx), cont_args.vert_line(vidx)+0.01, cont_args.vert_line(vidx)+0.01];
                y = [0, max_y, max_y, 0];
                color = [1 1 1];
                fill(x, y, 'k', 'EdgeColor', color);
            end
        end

        xlim([min_x max_x]);
        ylim([0 max_y]);
        
        if isfield(cont_args, 'legend')
            new_legend = cell(size(cont_args.legend));
            for i = 1:length(cont_args.legend)
                new_legend{i} = plot_no_underline(cont_args.legend{i});
            end
            legend(new_legend, 'Location', cont_args.legend_location);
        end

        if isfield(cont_args, 'title')
            title(plot_no_underline(cont_args.title), 'FontSize', 14, 'FontWeight', 'bold');
        end
    end
    
    set(gca, 'ytick', []);
    hold off;
    
    %% all the plotting is done, start saving    
    if isfield(args, 'dir_plots')
        dir_plots = args.dir_plots;
        if ~exist(dir_plots, 'dir')
            mkdir(dir_plots);
        end
    else
        dir_plots = [];
    end
        
    if isfield(args, 'save_name')
        save_name = args.save_name;
    else
        save_name = sprintf('timevp_vis_streams_demo_%s', datestr(now,'mm-dd-yyyy_HH-MM'));
    end
        
    if ~isfield(args, 'save_format')
        save_format = 'png';
    else
        save_format = args.save_format;
    end
    
    set(h,'PaperPositionMode','auto');
%         if isfield(args, 'figure_visible') && ~args.figure_visible
    if num_figures < 2
        if ~isempty(dir_plots)
            plot_fullpath = fullfile(dir_plots, [save_name '.' save_format]);
        else
            plot_fullpath = [save_name '.' save_format];
        end
    else
        if ~isempty(dir_plots)
            plot_fullpath = fullfile(dir_plots, [save_name '_' int2str(fidx) '.' save_format]);
        else
            plot_fullpath = [save_name '_' int2str(fidx) '.' save_format];
        end
    end
    
    saveas(h, plot_fullpath)
    fprintf('Plot %s saved.\n', plot_fullpath);

    if isfield(args, 'pause_before_save') && args.pause_before_save
        pause
    end
%         print(h, '-dpsc', [save_name '_' int2str(fidx) '.' save_format]);
    if is_closeplot
        close(h);
    end
end

end

% Get color according to rainbow color cue pallet
function color = get_color(k, k_base, colormap)
    if ~isempty(colormap)
        if iscell(colormap)
            color = colormap{k};
        else
            color = colormap(k, :);
        end
    else
        color = hsv2rgb([k/k_base,1,0.85]);
    end
end

% Draw one rectangle
% x1: start time
% x2: end time
% y1: y axe coordinate (center)
% color: color of the shape
% height: the height of each rectangle, default value is 0.25
function [x, y] = create_square(x1, x2, y1, cidx, color, args)          
    length_of_streams = length(unique(args.stream_position));
    each_stream_space = 1/length_of_streams;
    position_value = args.stream_position(cidx);
%         color = color*(each_stream_space*position_value)+...
%             (1-each_stream_space*position_value);
    y1 = (y1-1)*(1+each_stream_space);
    y1 = y1 + (length_of_streams-position_value+1)*each_stream_space;    
    
    if ~isfield(args, 'height')
        height = each_stream_space*0.5; %0.2;
    else
        height = args.height;
    end
    if isfield(args, 'edge_color')
        edge_color = args.edge_color; %0.2;
    else
        edge_color = 'none';
    end
    
    x = [x1, x2, x2, x1];
    y = [y1-height, y1-height, y1+height, y1+height];
%     if position_value == 3
%         edge_color = color;
%         mask_ones = color == 1;
%         edge_color(mask_ones) = 0.7;
%         rect = fill(x, y, color, 'EdgeColor', edge_color, 'LineWidth', 1);
%     elseif position_value == 6
%         edge_color = color;
%         mask_ones = color == 1;
%         edge_color(mask_ones) = 0.7;
%         rect = fill(x, y, color, 'EdgeColor', edge_color, 'LineWidth', 2);
%     else
%         rect = fill(x, y, color, 'EdgeColor', edge_color);
%     end
    rect = fill(x, y, color, 'EdgeColor', edge_color);
%     rect = fill(x, y, color, 'EdgeColor', 'k');
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% create line
% 
% vec: one chunk of cont data, [time data]
% row: xth row this chunk at
% time_ref: the 0 time spot / offset
% 
function ln = create_line(vec, row, time_ref, color, args)
    length_of_streams = length(unique(args.stream_position));
    each_stream_space = 1/length_of_streams;
    
    x = vec(:,1) - time_ref;
    y = vec(:,2);
    max_y = nanmax(y);
    min_y = nanmin(y);
    alpha = (1+each_stream_space)/(max_y - min_y);
    y = (y - min_y)*alpha + (row-1)*(1+each_stream_space);
    ln = line(x, y, 'Color', color, 'LineWidth', args.LineWidth);
end

% Get test data
function ret = get_test_data()

ret = {
        [0.1 0.2 1], [0.3 0.43 2], [0.5 0.6 3], [0.36 0.7 4], [0.7 1.0 5];
        [0 0.3 1], [0.3 0.54 2], [0.5 0.6 3], [0.6 0.7 4], [0.7 1.0 5];
        [0.1 0.35 1], [0.3 0.5 2], [0.5 0.6 3], [0.6 0.7 4], [0.7 1.0 5];
        [0.1 0.2 1], [0.2 0.4 2], [0.5 0.6 3], [0.6 0.7 4], [0.7 1.0 5];
        [0 0.23 1], [0.3 0.4 2], [0.5 0.6 3], [0.6 0.7 4], [0.7 1.0 5];
        [0.13 0.21 1], [0.35 0.5 2], [0.5 0.65 3], [0.6 0.7 4], [0.7 1.0 5];
        [0.1 0.3 1], [0.3 0.4 2], [0.5 0.6 3], [0.6 0.79 4], [0.7 1.0 5];
        [0.1 0.32 1], [0.3 0.5 2], [0.5 0.6 3], [0.6 0.7 4], [0.7 1.0 5];
    };
end