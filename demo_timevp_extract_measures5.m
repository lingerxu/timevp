clear;
addpath('timevp_lib'); 

%%
subject_list = [7002 7003 7005 7006];
variable_list = {'cevent_eye_roi_child'};
segment_event = 'cevent_inhand_child';
save_filename = 'timevp_output_files/example_extract_measures5.csv';

%%
timevp_extract_measures(subject_list, variable_list, segment_event, save_filename);

