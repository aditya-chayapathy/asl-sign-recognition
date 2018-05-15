% Features selected for DWT transformation
dwt_column_list = {'ARX', 'ALY', 'OPR'};
% Features selected for RMS transformation 
rms_column_list = {"EMG0R", "EMG2R", "EMG3R", "EMG4R"};
% Features selected for STD transformation
std_column_list = {"ARZ", "OPL", "ORR"};
% Gestures List
gesture_list = ["about", "and", "can", "cop", "decide", "deaf", "father", "find", "go out", "hearing"];
final_table = cell2table({});
pca_input = [];
label_array = [];

%{ 
Reading the ouput of task 1 from csv files and tranforming the data to a format suitable for 
   Task 2 implementation 
%}
   
for i=1:numel(gesture_list)
    file_name = strcat("Task1Output",'/',gesture_list(i),'.csv');
    cur_table = readtable(file_name,'ReadVariableNames',true);
    gesture_name = array2table(repmat(i,size(cur_table,1),1));
    final_table = [final_table; [gesture_name cur_table(:, 1:48)]];
end


%Applying DWT on all the selected sensors and extracting data from selected points 
for j=1:numel(dwt_column_list)
    sensor_table = final_table(strcmp(final_table.Sensor,cellstr(dwt_column_list(j))), :);
    dwt_array = [];
    if j==1
        label_table = sensor_table(:, 1);
    end
    for k=1:size(sensor_table, 1)
        row_array = table2array(sensor_table(k, 4:49));  
         
        Y = dwt(row_array,'sym4');
        Y = dwt(Y,'sym4');
        if strcmp(cellstr(dwt_column_list(j)), 'ARX')
            row_y = [Y(6), Y(12)];
        elseif strcmp(cellstr(dwt_column_list(j)), 'ALY')
            row_y = [Y(8), Y(9), Y(10)];
        else
            row_y = [Y(8)];
        end
        dwt_array = [ dwt_array; row_y];
    end
    pca_input = [pca_input dwt_array];
end

%{ Applying RMS on all the selected sensors and extracting data %}
for j=1:numel(rms_column_list)
    sensor_table = final_table(strcmp(final_table.Sensor,cellstr(rms_column_list(j))), :);
    rms_array = [];
    for k=1:size(sensor_table, 1)
        row_array = table2array(sensor_table(k, 4:49));   
        rms_val =rms(row_array, 2);
        rms_array = [rms_array; rms_val];
    end
    pca_input = [pca_input rms_array];
end

% Applying STD on all the selected sensors and extracting data
for j=1:numel(std_column_list)
    sensor_table = final_table(strcmp(final_table.Sensor,cellstr(std_column_list(j))), :);
    std_array = [];
    for k=1:size(sensor_table, 1)
        row_array = table2array(sensor_table(k, 4:49));   
        std_val =std(row_array);
        std_array = [std_array; std_val];
    end
    pca_input = [pca_input std_array];

end

% Converting the feature matrix of the extracted data to a table  and writing it to a csv
pca_table = array2table(pca_input);
final_pca_table = [label_table pca_table];
writetable(final_pca_table, "Task2Output.csv");


