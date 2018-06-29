%% demo of visualization
%  enter a list of csv files of the same variable from a set of subjects

clear;
addpath('timevp_lib')

% a list of csv files
csvfile_list = {'yulab_data\7002\cevent_eye_roi_child.csv', ...
    'yulab_data\7003\cevent_eye_roi_child.csv', ...
    'yulab_data\7005\cevent_eye_roi_child.csv', ...
     'yulab_data\7006\cevent_eye_roi_child.csv', ...
   'yulab_data\7008\cevent_eye_roi_child.csv', ...
    };
% set parameters for generating visualization plots
vis_args.annotation = {'7002' '7003' '7005' '7006' '7008'};
vis_args.windows = [30 130; 131 230; 231 330];
vis_args.save_name = 'timevp_output_files/timevp_vis_streams_example3';

timevp_visualization(csvfile_list, vis_args);