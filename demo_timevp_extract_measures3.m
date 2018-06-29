clear; 
addpath('timevp_lib')

%%
subject_list = [7002 7003 7005 7006];
variable_list = {'cevent_eye_roi_child'};
segment_event = 'cevent_speech_naming_local-id';
num_categories = 3; 
args.event_category = 1:num_categories;
args.var_category = 1:num_categories;
args.groupid_matrix = [1 2 2; 
                       2 1 2;
                       2 2 1];
args.group_label = {'target', 'distractor'};
save_filename = 'timevp_output_files/example_extract_measures3.csv';

%%
timevp_extract_measures(subject_list, variable_list, segment_event, save_filename, args);