function timevp_visualization_by_subject_variable(subject_list, variable_list, vis_args)

if isfield(vis_args, 'windows')
    windows = vis_args.windows;
    is_multi_rows = true;
    num_windows = size(windows, 1);
    vis_args.ForceZero = true;
%     vis_args.ref_column = 1;
    vis_args.time_ref = windows(:,1);
else
    windows = [];
    is_multi_rows = false;
    num_windows = 1;
end

if isfield(vis_args, 'is_plot_by_variable')
    is_plot_by_variable = vis_args.is_plot_by_variable;
else
    is_plot_by_variable = false;
end

if isfield(vis_args, 'is_plot_by_subject')
    is_plot_by_subject = vis_args.is_plot_by_subject;
elseif is_plot_by_variable
    is_plot_by_subject = false;
else
    is_plot_by_subject = true;
end

if ~is_plot_by_subject && ~is_plot_by_variable
    Warning('Invalid input argument setting. The function will by-default visualize streams by subject.');
    is_plot_by_subject = true;
end

num_subs = length(subject_list);
num_vars = length(variable_list);

% By default, the visualization function plots multiple streams from
% the same subject in one plot.
if is_plot_by_subject
    for sidx = 1:num_subs
        sub_id = subject_list(sidx);
        plot_data = cell(num_windows, num_vars);

        for vidx = 1:num_vars
            var_name = variable_list{vidx};
            var_data = get_variable_data(sub_id, var_name);

            if is_multi_rows
                extracted_data = extract_ranges(var_data, windows);
                if ~isempty(extracted_data)
                    plot_data(:, vidx) = extracted_data';
                end
            else
                plot_data{1, vidx} = var_data;
            end
        end

        vis_args.save_name = sprintf('timevp_vis_streams_%d', sub_id);
        visualize_streams(plot_data, vis_args);
    end
else
    plot_data = cell(num_windows, num_subs);
    
    if ~isfield(vis_args, 'annotation')
        vis_args.annotation = arrayfun(@(sid) num2str(sid), subject_list, 'UniformOutput', false);
    end

    for vidx = 1:num_vars
        var_name = variable_list{vidx};

        for sidx = 1:num_subs
            sub_id = subject_list(sidx);
            var_data = get_variable_data(sub_id, var_name);

            if is_multi_rows
                extracted_data = extract_ranges(var_data, windows);
                if ~isempty(extracted_data)
                    plot_data(:, sidx) = extracted_data';
                end
            else
                plot_data{1, sidx} = var_data;
            end
        end

        vis_args.save_name = sprintf('timevp_vis_streams_%s', var_name);
        visualize_streams(plot_data, vis_args);
    end
end



    