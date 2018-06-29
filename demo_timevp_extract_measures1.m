clear;
addpath('timevp_lib')

%%
subject_list = [7002 7003 7005 7006];
variable_list = {'cevent_eye_roi_child'};
segment_event = 'cevent_speech_naming_local-id';
save_filename = 'timevp_output_files/example_extract_measures1.csv';

%%
timevp_extract_measures(subject_list, variable_list, segment_event, save_filename);