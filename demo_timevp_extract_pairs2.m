clear;
addpath('timevp_lib');

variable1 = 'cevent_eye_roi_child';
variable2 = 'cevent_eye_roi_parent';
subject_list = [1203 1205 1206 1208];
timing_relation = 'more(on1, off2, 0.3) & less(off1, on2, 1)';
%mapping = [(1:25)' (1:25)'];

dir_savefiles = 'timevp_output_files';
timevp_extract_pairs_by_subject(subject_list, variable1, variable2, timing_relation, dir_savefiles);