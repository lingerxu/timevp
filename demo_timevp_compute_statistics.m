function demo_timevp_compute_statistics(demo_id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODULE 2: Compute statistics
% E.g. compare infant looking behavior vs parent looking behavior vs
%       parent holding behavior
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('timevp_lib')

if demo_id == 1
    % Get subject list
    subject_list = yulab_list_subjects('toyroom');
    variable_child_eye = 'cevent_eye_roi_child';
    stats_child_eye_toyroom = timevp_compute_statistics(variable_child_eye, subject_list)

    % Example result:
    % stats_child_eye = 
    % 
    %   struct with fields:
    % 
    %                       categories: [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
    %                     total_number: 6161
    %                individual_number: [35×1 double]
    %              total_number_by_cat: [262 256 285 113 209 245 203 262 204 284 214 149 207 156 451 180 406 166 190 383 332 292 282 234 196]
    %         individual_number_by_cat: [35×25 double]
    %                         mean_dur: 1.8371
    %              individual_mean_dur: [35×1 double]
    %               individual_std_dur: [35×1 double]
    %                  mean_dur_by_cat: [1×25 double]
    %       individual_mean_dur_by_cat: [35×25 double]
    %                       median_dur: 0.9670
    %            individual_median_dur: [35×1 double]
    %                median_dur_by_cat: [1×25 double]
    %     individual_median_dur_by_cat: [35×25 double]
    %                         switches: 5614
    %              individual_switches: [35×1 double]
    %                     trans_matrix: [25×25 double]
    %          individual_trans_matrix: {36×625 cell}
    %                trans_freq_matrix: [25×25 double]
    %                        data_list: {35×1 cell}
    
elseif demo_id == 2
    subject_list = yulab_list_subjects('storybook');
    variable_child_eye = 'cstream_eye_roi_child';
    stats_child_eye_storybook = timevp_compute_statistics(variable_child_eye, subject_list)
    
    % Example result:
    % stats_child_eye_storybook = 
    % 
    %   struct with fields:
    % 
    %                subject_list: [45×1 double]
    %                  categories: [1×43 double]
    %                        prop: 0.6937
    %                 prop_by_cat: [1×43 double]
    %             individual_prop: [45×1 double]
    %      individual_prop_by_cat: [45×43 double]
    %                trans_matrix: [42×42 double]
    %     individual_trans_matrix: {46×1764 cell}
    %                 EVENT_STATS: '----------convert to events from here-----------'
    %                 event_stats: [1×1 struct]
    %                   data_list: {45×1 cell}
    
    
elseif demo_id == 3
    subject_list = yulab_list_subjects('toyroom');
    variable_parent_naming = 'cevent_speech_naming_local-id';
    stats_parent_naming = timevp_compute_statistics(variable_parent_naming, subject_list)
    
    % Example result:
    % stats_parent_naming = 
    % 
    %   struct with fields:
    % 
    %                       categories: [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
    %                     total_number: 1287
    %                individual_number: [35×1 double]
    %              total_number_by_cat: [85 84 64 29 61 49 72 43 46 64 71 33 52 43 117 39 39 50 39 61 31 31 59 25]
    %         individual_number_by_cat: [35×24 double]
    %                         mean_dur: 1.7407
    %              individual_mean_dur: [35×1 double]
    %               individual_std_dur: [35×1 double]
    %                  mean_dur_by_cat: [1×24 double]
    %       individual_mean_dur_by_cat: [35×24 double]
    %                       median_dur: 1.3600
    %            individual_median_dur: [35×1 double]
    %                median_dur_by_cat: [1×24 double]
    %     individual_median_dur_by_cat: [35×24 double]
    %                         switches: 747
    %              individual_switches: [35×1 double]
    %                     trans_matrix: [24×24 double]
    %          individual_trans_matrix: {36×576 cell}
    %                trans_freq_matrix: [24×24 double]
    %                        data_list: {35×1 cell}
end