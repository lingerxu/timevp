function demo_timevp_stream_event_conversion(demo_id)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warning: Before use, set dataset location and sample rate in
% timevp_config_dataset_info.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('timevp_lib')

if demo_id == 1
    %% Use subject id and variable name
    subject_id = 1203;
    var_name_events = 'cevent_eye_roi_child';
    data_events = get_variable_data(subject_id, var_name_events);
    
    % use default parameter settings
    data_stream = event2stream(data_events);

    % specify all parameters
    sample_rate = timevp_config_dataset_info();
    default_value = 0;
    start_time = 30;
    end_time = 750;
    data_stream2 = event2stream(data_events, sample_rate, default_value, start_time, end_time);

    var_name_stream = 'cstream_eye_roi_child';
    % save_variable_data(subject_id, var_name_stream, data_stream2)

elseif demo_id == 2
    %% Use full csv file names.
    csv_stream = 'yulab_data\7002\cstream_eye_roi_child.csv';
    data_stream = csv2stream(csv_stream);

    % use default parameter settings
    data_events = stream2event(data_stream);

    % specify all parameters
    sample_rate = timevp_config_dataset_info();
    include_zero = false;
    data_events2 = stream2event(data_stream, sample_rate, include_zero);

    csv_events = 'yulab_data\7002\cevent_eye_roi_child_new.csv';
    % write2csv(data_events, csv_events)
end