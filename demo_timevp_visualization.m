function demo_timevp_visualization(demo_id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warning: Before use, set dataset location and sample rate in
% timevp_config_dataset_info.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODULE 1: Data Visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('timevp_lib')
num_demo_subs = 3;

%% Method 1: enter a list of csv files and visualize the data
if demo_id == 1
%     csvfile_list = {'yulab_data\1202\cevent_eye_roi_child.csv', ...
%         'yulab_data\1202\cevent_inhand_child.csv', ...
%         'yulab_data\1202\cevent_eye_roi_parent.csv', ...
%         'yulab_data\1202\cevent_inhand_parent.csv', ...
%         'yulab_data\1202\cevent_speech_naming_local-id.csv'
%         };
% 
%     % set parameters for generating visualization plots
%     vis_args.annotation = {'child eye', 'child hand', 'parent eye', 'parent hand', 'parent naming'};
%     vis_args.windows = [30 250; 250 500; 500 750];
%     vis_args.save_name = 'vis_streams\timevp_vis_streams_example';
% 
%     timevp_visualization(csvfile_list, vis_args);
    csvfile_list = {'yulab_data\1203\cevent_eye_roi_child.csv', ...
        'yulab_data\1205\cevent_eye_roi_child.csv', ...
        'yulab_data\1206\cevent_eye_roi_child.csv', ...
        'yulab_data\1208\cevent_eye_roi_child.csv', ...
        };

    % set parameters for generating visualization plots
    vis_args.annotation = {'1203' '1205' '1206' '1208'};
    vis_args.windows = [30 100; 101 200; 201 300; 301 400];
    vis_args.save_name = 'vis_streams\timevp_vis_streams_example2';
    
    % REMOVE THE X-AXIS
    % GET 8 subjects with good data
    % add a demo for converting between events and streams
    % save it as a different variable

    timevp_visualization(csvfile_list, vis_args);
    
%% Method 2: enter a list of subject or variables
% Plot multiple variables in one plot per subject
elseif demo_id == 2
    subject_list = yulab_list_subjects('toyroom');
    subject_list = subject_list(1:num_demo_subs);
    
    variable_list = {'cevent_eye_roi_child', 'cevent_inhand_child', ...
        'cevent_eye_roi_parent', 'cevent_inhand_parent', 'cevent_speech_naming_local-id'};

    % enter a directory for storing all visualization plots
    vis_args.dir_plots = 'vis_streams';
    vis_args.annotation = {'child eye', 'child hand', 'parent eye', 'parent hand', 'parent naming'};
    vis_args.windows = [30 280; 280 530; 530 780];
    % Create visualization by subject: one plot per subject with multiple
    % variables
    vis_args.is_plot_by_subject = true;

    timevp_visualization_by_subject_variable(subject_list, variable_list, vis_args)

% Plot multiple variables in one plot per subject
elseif demo_id == 3
    subject_list = yulab_list_subjects('toyroom');
    subject_list = subject_list(1:num_demo_subs);
    variable_list = {'cevent_eye_roi_child', 'cevent_eye_roi_parent'};

    % enter a directory for storing all visualization plots
    vis_args.dir_plots = 'vis_streams';
    vis_args.is_plot_by_variable = true;

    timevp_visualization_by_subject_variable(subject_list, variable_list, vis_args)
end
