function new_cevents = cevent_reassign_categories(cevents, old_roi_list, new_roi_list)
%This function reassign/regroup cevents with new roi values that are
%specified by the users. So that statistics can be calculated based on new
%groups.
% 
% example for ressigning cevent category values for an experiment.
% 
% exp_id = 53;
% sub_list = list_subjects(exp_id);
% input.sub_list = sub_list;
% input.var_name = 'cevent_eye_roi_follow_nao';
% chunks_follow_tmp = get_variable_by_grouping('sub', sub_list, follow_name, grouping, input);
% 
% old_roi_list = {[1 2 3]; [4]; [10 25]}
% new_roi_list = {[1]; [4]; [99]}
% 
% chunks_follow = cellfun(@(chunk_one) ...
%     cevent_reassign_categories(chunk_one, old_roi_list, new_roi_list), ...
%     chunks_follow_tmp, ...
%     'UniformOutput', false);
% 
% results = cevent_cal_stats(chunks_follow, input);

if ~isempty(cevents)
    new_cevents = cevents(:,:);

    if isempty(old_roi_list)
        if ~iscell(new_roi_list) && (length(new_roi_list) == 1)
            assign_mask = cevents(:,3) > 0;
            new_cevents(assign_mask,3) = new_roi_list;
        else
            error(['Invalid_parameter: when old_roi_list is empty, ' ...
                'the new_roi_list must not be one number']);
        end
    else

        for i = 1:length(old_roi_list)
            old_rois = old_roi_list{i};
            new_roi = new_roi_list{i};

            if length(new_roi) > 1
                error('New roi can only be length 1');
            end

            assign_mask = ismember(cevents(:,3), old_rois);
            new_cevents(assign_mask,3) = new_roi;
        end
    end
else
    new_cevents = cevents;
end