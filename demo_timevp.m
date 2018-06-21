clearvars;
addpath('timevp_lib')

subject_list = yulab_list_subjects('toyroom');
variable_child_eye = 'cevent_eye_joint-attend_both';
args.ranges = [30 180];

stats_child_eye_toyroom = timevp_compute_statistics(variable_child_eye, subject_list, args)

