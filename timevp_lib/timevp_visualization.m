function timevp_visualization(csvfile_list, vis_args)

if isfield(vis_args, 'windows')
    windows = vis_args.windows;
    is_multi_rows = true;
    num_windows = size(windows, 1);
    vis_args.ForceZero = true;
    vis_args.time_ref = windows(:,1);
    
    windows_dur = windows(:,2) - windows(:,1);
    dur_min = min(windows_dur);
    dur_max = max(windows_dur);
    if abs(dur_max - dur_min) > 10
        warning('The window sizes are different from each other, so there will be blank space in the visualization.');
    end
else
    windows = [];
    is_multi_rows = false;
    num_windows = 1;
end

% visualize streams by csv data
num_files = length(csvfile_list);
plot_data = cell(num_windows, num_files);

for fidx = 1:num_files
    file_one = csvfile_list{fidx};
    data_one = csv2stream(file_one);

    if is_multi_rows
        extracted_data = extract_ranges(data_one, windows);
        if ~isempty(extracted_data)
            plot_data(:, fidx) = extracted_data';
        end
    else
        plot_data{1, fidx} = data_one;
    end
end
visualize_streams(plot_data, vis_args);


    