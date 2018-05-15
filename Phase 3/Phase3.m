%Phase 2 - Task 1
%Prompt to enter base directory
%baseFilePath = "InputData";
prompt = "Enter Filepath\n";
baseFilePath = input(char(prompt), 's');
group_array = ["DM05", "DM11", "DM16", "DM20", "DM22", "DM24", "DM26", "DM28", "DM32", "DM36"];

%Creating Phase3Output directory if it doesn't exist
phase3FilePath = "Phase3Output";
if ~exist(phase3FilePath, 'dir')
    mkdir(char(phase3FilePath));
end

%Creating phase2Task1OutputFilePath directory if it doesn't exist
phase2Task1OutputFilePath = "Task1Output";
if ~exist(phase2Task1OutputFilePath, 'dir')
    mkdir(char(phase2Task1OutputFilePath));
end

%For each group in the group list
for groupName = group_array
    filePath = baseFilePath + "\" + groupName;

    %Fetching all the files in the given directory
    modifiedFilePath = strcat(filePath, "\**\*.csv");
    dirInfo = dir(char(modifiedFilePath));
    subDirFilesCellArray = {};
    for K = 1:length(dirInfo)
        subDirName = dirInfo(K).name;
        subDirFolder = dirInfo(K).folder;
        fileName = strcat(subDirFolder,"\",subDirName);
        subDirFilesCellArray = [subDirFilesCellArray; {fileName}];
    end
    subDirFilesStringArray = string(subDirFilesCellArray);

    patternArray = ["about", "and", "can", "cop", "deaf", "decide", "father", "go out", "find", "hearing"];
    %For each gesture in the gesture list
    for pattern = patternArray
        %Fetching relevant files
        TF = contains(subDirFilesStringArray, pattern, 'IgnoreCase', true);
        files = subDirFilesStringArray(TF);

        gestureTable = cell2table({});
        finalTable = cell2table({});
        for K = 1:length(files)
            %Read table from file
            table = readtable(files{K});

            %Transposing the table
            first34columns = table(1:end, 1:34);
            tableArray = table2array(first34columns);
            transposedTable = array2table(tableArray.');

            %Condition to check is the no. of columns is more than 50
            noOfColumnTransposedTable = size(transposedTable, 2);
            if noOfColumnTransposedTable > 50
                disp("Action Name: " + pattern);
                disp("Group Name: " + groupName);
                continue;
            end

            %Adding Sensor column
            sensorColumn = cell2table(cellstr(['ALX  ';'ALY  ';'ALZ  ';'ARX  ';'ARY  ';'ARZ  ';'EMG0L';'EMG1L';'EMG2L';'EMG3L';'EMG4L';'EMG5L';'EMG6L';'EMG7L';'EMG0R';'EMG1R';'EMG2R';'EMG3R';'EMG4R';'EMG5R';'EMG6R';'EMG7R';'GLX  ';'GLY  ';'GLZ  ';'GRX  ';'GRY  ';'GRZ  ';'ORL  ';'OPL  ';'OYL  ';'ORR  ';'OPR  ';'OYR  ']));
            sensorColumn.Properties.VariableNames = {'Sensor'};

            %Adding Action column
            actionNo = "Action " + K;
            actionCellArray = cell(1, 34);
            actionCellArray(:) = {actionNo};
            actionRowTable = cell2table(actionCellArray);
            actionRowArray = table2array(actionRowTable);
            actionColumn= array2table(actionRowArray.');
            actionColumn.Properties.VariableNames = {'ActionCount'};

            %Adding column names to the table
            finalTable = [actionColumn sensorColumn transposedTable];
            headerCellArray = {'ActionCount', 'Sensor'};
            for J = 1:noOfColumnTransposedTable
                headerCellArray{end + 1} = char("time" + num2str(J));
            end
            finalTable.Properties.VariableNames = headerCellArray;

            %Adding final table to main table
            if K==1 || isempty(gestureTable)
                gestureTable = finalTable;
            else
                noOfColumnsGestureTable = size(gestureTable, 2);
                noOfColumnsFinalTable = size(finalTable, 2);

                if noOfColumnsGestureTable == noOfColumnsFinalTable    %if both the tables have same no. of columns
                    gestureTable = [gestureTable; finalTable];
                else    %add padding of NaNs
                    if noOfColumnsGestureTable < noOfColumnsFinalTable
                        diff = noOfColumnsFinalTable - noOfColumnsGestureTable;
                        noOfRowsGestureTable = size(gestureTable, 1);
                        %nanColumn = NaN(noOfRowsGestureTable, 1, 'double');
                        nanColumn = zeros(noOfRowsGestureTable, 1);
                        nanColumnTable = array2table(nanColumn);
                        nanMatrix = repmat(nanColumnTable, 1, diff);

                        nanMatrixHeader = {};
                        start = noOfColumnsGestureTable - 1;
                        finish = noOfColumnsFinalTable - 2;
                        for J = start:finish
                            nanMatrixHeader{end + 1} = char("time" + num2str(J));
                        end
                        nanMatrix.Properties.VariableNames = nanMatrixHeader;

                        gestureTable = [gestureTable nanMatrix];
                        gestureTable = [gestureTable; finalTable];
                    else
                        diff = noOfColumnsGestureTable - noOfColumnsFinalTable;
                        noOfRowsFinalTable = size(finalTable, 1);
                        %nanColumn = NaN(noOfRowsFinalTable, 1, 'double');
                        nanColumn = zeros(noOfRowsFinalTable, 1);
                        nanColumnTable = array2table(nanColumn);
                        nanMatrix = repmat(nanColumnTable, 1, diff);

                        nanMatrixHeader = {};
                        start = noOfColumnsFinalTable - 1;
                        finish = noOfColumnsGestureTable - 2;
                        for J = start:finish
                            nanMatrixHeader{end + 1} = char("time" + num2str(J));
                        end
                        nanMatrix.Properties.VariableNames = nanMatrixHeader;

                        finalTable = [finalTable nanMatrix];
                        gestureTable = [gestureTable; finalTable];
                    end
                end
            end
        end

        %Writing table to CSV file
        outputFilename = phase2Task1OutputFilePath + "\" + pattern + ".csv";
        writetable(gestureTable, outputFilename);
    end

    %Phase 2 - Task 2
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
        final_table = [final_table; [gesture_name cur_table(:, 1:45)]];
    end


    %Applying DWT on all the selected sensors and extracting data from selected points 
    for j=1:numel(dwt_column_list)
        sensor_table = final_table(strcmp(final_table.Sensor,cellstr(dwt_column_list(j))), :);
        dwt_array = [];
        if j==1
            label_table = sensor_table(:, 1);
        end
        for k=1:size(sensor_table, 1)
            row_array = table2array(sensor_table(k, 4:46));  

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
            row_array = table2array(sensor_table(k, 4:46));   
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
            row_array = table2array(sensor_table(k, 4:46));   
            std_val =std(row_array);
            std_array = [std_array; std_val];
        end
        pca_input = [pca_input std_array];

    end

    % Converting the feature matrix of the extracted data to a table  and writing it to a csv
    pca_table = array2table(pca_input);
    final_pca_table = [label_table pca_table];
    writetable(final_pca_table, "Task2Output.csv");


    %Phase 2 - Task 3

    gesture_list = ["about", "and", "can", "cop", "decide", "deaf", "father", "find", "go out", "hearing"];

    % Reading Task2 output
    X_table = readtable("Task2Output.csv");
    X = table2array(X_table);

    %Performing PCA on the feature matrix
    [coeff, score, latent, T2, explained] = pca(X(:,2:end));
    %score_table = array2table( [score(:,:) X(:,1)]);
    score_table = array2table([(X(:,2:end)*coeff) X(:,1)]);
    writetable(score_table, "Task3Output.csv");


    % Phase 3 - Processing
    pca_table = readtable("Task3Output.csv");
    PCAheaderCellArray = {'PC1' , 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', 'PC8', 'PC9', 'PC10', 'PC11', 'PC12', 'PC13', 'Class'};
    finalTableHeaderArray = {'PC1' , 'PC2', 'PC3', 'PC4', 'PC5', 'Class'};
    pca_table.Properties.VariableNames = PCAheaderCellArray;
    gesture_list = ["about", "and", "can", "cop", "decide", "deaf", "father", "find", "go out", "hearing"];

    phase3OutputFilePath = phase3FilePath + "\" + groupName;
    %Creating output directory if it doesn't exist
    if ~exist(phase3OutputFilePath, 'dir')
        mkdir(char(phase3OutputFilePath));
    end

    for i=1:10
        current_class_array = zeros(height(pca_table), 1);
        for j = 1:height(pca_table)
            if pca_table.Class(j) == i
                current_class_array(j,1)=1;
            end 
        end
        final_table = [pca_table(:, 1:5) array2table(current_class_array)];
        final_array_ordered = table2array(final_table);
        final_array_shuffled =  final_array_ordered(randperm(size(final_array_ordered,1)),:);
        final_table = array2table(final_array_shuffled);
        outputFilename = phase3OutputFilePath + "\" + gesture_list(i) + ".csv";
        final_table.Properties.VariableNames = finalTableHeaderArray;
        writetable(final_table, outputFilename);
    end
end