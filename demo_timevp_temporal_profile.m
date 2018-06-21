clearvars;

addpath('timevp_lib')
num_demo_subs = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODULE 4: Plot temporal profiles
% This component computes the probabilities of certain behaviors prior, 
% during or after another type of events. E.g. the probability that the 
% infant's looking behavior matches with their manual behavior. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subject_list = yulab_list_subjects('toyroom');
subject_list = subject_list(1:num_demo_subs);
num_categories = 25;

profile_input.sub_list = subject_list;
profile_input.segment_event = 'cevent_speech_naming_local-id';
profile_input.whence = 'start';
profile_input.interval = [-5 5];

profile_input.var_name = 'cevent_eye_roi_child';
profile_input.var_category = 1:num_categories;
profile_input.event_category = 1:num_categories;

% Each row corresponding to a cstream value
% Each column corresponding to a cevent value
profile_input.groupid_matrix = ones(num_categories, num_categories) * 2;
for i = 1:num_categories
    profile_input.groupid_matrix(i,i) = 1;
end
profile_input.groupid_label = {'match', 'not match'};

input = profile_input;

profile_data = timevp_construct_temporal_profile(profile_input);
temporal_profile_save_csv_plot(profile_data, '.')