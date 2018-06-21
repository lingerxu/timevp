function new_cstream = cstream_reassign_categories(cstream, old_roi_list, new_roi_list)
% old_roi_list = {[1 2 3 10 25]; [4]}
% new_roi_list = {[1]; [4]}

% when old_roi_list is empty, the function sets all non-NaN non-zero
% rois to be new_roi.

if ~isempty(cstream)
    new_cstream = cstream(:,:);
    
    if isempty(old_roi_list)
        if ~iscell(new_roi_list) && (length(new_roi_list) == 1)
            assign_mask = cstream(:,2) > 0;
            new_cstream(assign_mask,2) = new_roi_list;
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

            assign_mask = ismember(cstream(:,2), old_rois);
            new_cstream(assign_mask,2) = new_roi;
        end
    end
else
    new_cstream = cstream;
end