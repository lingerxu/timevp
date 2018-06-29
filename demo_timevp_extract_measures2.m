clear;
addpath('timevp_lib'); 

%%
subject_list = [7002 7003 7005 7006];
variable_list = {'cevent_eye_roi_child'};
segment_event = 'cevent_speech_naming_local-id';
stats_args.whence = 'start';
stats_args.interval = [-3 0];
save_filename = 'timevp_output_files/example_extract_measures2.csv';

%%
timevp_extract_measures(subject_list, variable_list, segment_event, save_filename, stats_args);

