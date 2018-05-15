%filePath = "D:\Kevin Thomas\ASU\2nd Semester\DM\Project\InputData";
prompt = "Enter Filepath\n";
filePath = input(char(prompt), 's');
outputFilePath = "Task1Output";

%Creating output directory if it doesn't exist
if ~exist(outputFilePath, 'dir')
    mkdir(char(outputFilePath));
end

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
%For each pattern
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
        
        noOfColumnTransposedTable = size(transposedTable, 2);
        if noOfColumnTransposedTable > 50
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
    outputFilename = outputFilePath + "\" + pattern + ".csv";
    writetable(gestureTable, outputFilename);
end