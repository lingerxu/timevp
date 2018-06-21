% function demo_timevp_extract_measures(demo_id)
clearvars;
addpath('timevp_lib')
num_demo_subs = 10;

demo_id = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODULE 3: Extract variable measures based on one type of events
% E.g. where the infant or the parent was looking at when the parent was
% displaying the toy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if demo_id == 1
    % Get subject list
    subject_list = yulab_list_subjects('toyroom');
    subject_list = subject_list(1:num_demo_subs);
    
    variable_list = {'cevent_eye_roi_child', 'cevent_eye_roi_parent'};
    save_filename = 'example_extract_measures.csv';

    segment_event = 'cevent_speech_naming_local-id';
    timevp_extract_measures(subject_list, variable_list, segment_event, save_filename);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By enabling input parameters of WHENCE and INTERVAL, one can extract
% measures before, during or after a certain event.
% E.g. where the infant or the parent was looking at from 5 seconds before
% to the onset of parent naming an object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif demo_id == 2
    subject_list = yulab_list_subjects('toyroom');
    subject_list = subject_list(1:num_demo_subs);
    variable_list = {'cevent_eye_roi_child', 'cevent_eye_roi_parent'};
    segment_event = 'cevent_speech_naming_local-id';
    
    stats_args.whence = 'start';
    stats_args.interval = [-5 0];
    save_filename = 'example_extract_measures_whence.csv';

    timevp_extract_measures(subject_list, variable_list, segment_event, save_filename, stats_args);
    
elseif demo_id == 3
    
    subject_list = yulab_list_subjects('toyroom');
    subject_list = subject_list(1:num_demo_subs);
    
    num_categories = 25;
    variable_list = {'cevent_eye_roi_child', 'cevent_eye_roi_parent'};
    segment_event = 'cevent_speech_naming_local-id';
    args.event_category = 1:num_categories;
    args.var_category = 1:num_categories;
    
    args.groupid_matrix = ones(num_categories, num_categories) * 2;
    for i = 1:num_categories
        args.groupid_matrix(i,i) = 1;
    end
    args.group_label = {'target', 'distractor'};
%     args.convert_event2stream = true;
    save_filename = 'example_extract_measures_regroup_target_distractor.csv';
    
    timevp_extract_measures(subject_list, variable_list, segment_event, save_filename, args);
    
elseif demo_id == 4
    subject_list = [7002 7003 7005 7006];
    num_categories = 3;
    variable_list = {'cevent_eye_roi_child', 'cevent_eye_roi_parent'};
    segment_event = 'cevent_speech_naming_local-id';

    args.event_category = 1:num_categories;
    args.var_category = 1:num_categories;
    args.groupid_matrix = [1 2 2;
                           2 1 2;
                           2 2 1];

    args.group_label = {'target', 'distractor'};
    save_filename = 'example_extract_measures_regroup_target_distractor.csv';

    timevp_extract_measures(subject_list, variable_list, segment_event, save_filename, args);
end
