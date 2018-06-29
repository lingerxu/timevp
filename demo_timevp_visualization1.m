
%% demo of visualization
%  enter a list of csv files from one subject and visualize multiple data
%  streams

clear;
addpath('timevp_lib')


%% a list of csv files 
csvfile_list = {'yulab_data\1202\cevent_eye_roi_child.csv', ...
    'yulab_data\1202\cevent_eye_roi_parent.csv'};
vis_args.annotation = {'child eye', 'parent eye'};
vis_args.windows = [0 250; 250 500; 500 750];
vis_args.save_name = 'timevp_output_files/timevp_vis_streams_example1';

%% call the function 
timevp_visualization(csvfile_list, vis_args);