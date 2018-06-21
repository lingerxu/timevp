function stream = csv2stream(csv_filename)
% This function reads data from a csv file and converts the data into time
% stream.

if ~exist(csv_filename, 'file')
    error('Cannot locate file %s.\n', csv_filename);
end

stream = csvread(csv_filename);