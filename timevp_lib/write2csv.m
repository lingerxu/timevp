function write2csv(data, filename, headers, precision)
% data is a numeric matrix of NxN size
% filename is a .csv string indicating where to save data
% (optional) headers is a cellarray of strings, or a comma separated string
% (optional) precision, e.g., '%.3f' to add precision (decimal places)
% after each number
% e.g. write2csv(rand(3,3), '/scratch/sbf/test.csv', 'mom,dad,cat')

if exist('headers', 'var') && ~isempty(headers)
    if ~iscell(headers)
        headers = {headers};
    end
    
    %write headers to file
    fid = fopen(filename, 'w');
    for h = 1:numel(headers)
        thisheader = headers{h};
        if ~strcmp(thisheader(1), '#')
            this = thisheader;
            thisheader = ['#' this]; %append # to beginning of each header for easy-to-read syntax in get_csv_* functions
        end
        formheader = thisheader(~isspace(thisheader)); %remove spaces
        fprintf(fid,'%s\n', formheader);
    end
    fclose(fid);
    
    %append data to file
    if exist('precision', 'var') && ~isempty(precision)
        dlmwrite(filename, data, '-append', 'delimiter', ',', 'precision', precision);
    else
        dlmwrite(filename, data, '-append', 'delimiter', ',');
    end
else
    %write data to file
    if exist('precision', 'var') && ~isempty(precision)
        dlmwrite(filename, data, 'delimiter', ',', 'precision', precision);
    else
        dlmwrite(filename, data, 'delimiter', ',');
    end
end
fprintf('\nSaved file: %s\n', filename);
[~, attrib] = fileattrib(filename);
if attrib.OtherWrite == 0 || isnan(attrib.OtherWrite)
    try
        fileattrib(filename, '+w');
    catch ME
        disp(ME.message);
    end
end
end