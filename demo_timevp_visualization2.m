%% demo of visualization
%  enter a list of csv files of the same variable from a set of subjects

clear;
addpath('timevp_lib')

% a list of csv files
csvfile_list = {'yulab_data\1203\cevent_eye_roi_child.csv', ...
    'yulab_data\1205\cevent_eye_roi_child.csv', ...
    'yulab_data\1206\cevent_eye_roi_child.csv', ...
    'yulab_data\1208\cevent_eye_roi_child.csv', ...
    };

% set parameters for generating visualization plots
vis_args.annotation = {'1203' '1205' '1206' '1208'};
vis_args.windows = [0 100; 101 200; 201 300; 301 400];
vis_args.save_name = 'vis_streams\timevp_vis_streams_example2';

timevp_visualization(csvfile_list, vis_args);