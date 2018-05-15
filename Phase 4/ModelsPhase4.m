%Prompt to enter base directory
%prompt = "Enter the base directory folder = ";
%baseDirectory = input(char(prompt), 's');
baseDirectory = "Phase3Output";

%Data Lists
gestures = ["about", "and", "can", "cop", "deaf", "decide", "father", "go out", "find", "hearing"];
csvData = ["Gesture" "Model" "Precision" "Recall" "F1"];

%For each geasture in the gesture list
for j = 1:numel(gestures)
       pathOfFile = baseDirectory + "\" + gestures(j) + ".csv";
       disp(pathOfFile);
       fileContent = readtable(pathOfFile);
       featureMatrix = table2array(fileContent);
       
       [numRows, numColumns] = size(featureMatrix);
       numTrainingRows = int16(0.6 * numRows);
       trainData = featureMatrix(1:numTrainingRows,1:end-1);
       trainLabels = featureMatrix(1:numTrainingRows,end);
       testData = featureMatrix(numTrainingRows + 1:end, 1: end-1);
       actualLabels = featureMatrix(numTrainingRows + 1:end, end);
       
       %Decision Tree Classification
       dt = fitctree(trainData, trainLabels);
       predictedLabels = predict(dt, testData);
       confusionMatrix = confusionmat(actualLabels', predictedLabels');
       TP = confusionMatrix(2,2);
       FP = confusionMatrix(1,2);
       FN = confusionMatrix(2,1);
       precision = TP/(TP+FP);
       recall = TP/(TP+FN);
       F1 = 2 * recall * precision / (precision + recall);
       newCsvData = [gestures(j) "Decision Tree" num2str(precision) num2str(recall) num2str(F1)];
       csvData = [csvData; newCsvData];
       
       %SVM Classification
       %svm = fitcsvm(trainData, trainLabels, 'KernelFunction', 'polynomial', 'PolynomialOrder', 10);
       svm = fitcsvm(trainData, trainLabels, 'KernelFunction','RBF', 'KernelScale','auto');
       predictedLabels = predict(svm, testData);
       confusionMatrix = confusionmat(actualLabels', predictedLabels');
       TP = confusionMatrix(2,2);
       FP = confusionMatrix(1,2);
       FN = confusionMatrix(2,1);
       precision = TP/(TP+FP);
       recall = TP/(TP+FN);
       F1 = 2 * recall * precision / (precision + recall);
       newCsvData = [gestures(j) "SVM" num2str(precision) num2str(recall) num2str(F1)];
       csvData = [csvData; newCsvData];
       
       %Neural Network Classificiation
       neuralNet = feedforwardnet([10 10 10 10 10]);
       trainedNeuralNet = train(neuralNet, trainData', trainLabels');
       predictedOutputs = trainedNeuralNet(testData');
       predictedLabels = zeros(1, numel(predictedOutputs));
       for k = 1:numel(predictedOutputs)
           if predictedOutputs(k) >= 0.5
               predictedLabels(k) = 1;
           end
       end
       predictedLabels = predictedLabels';
       confusionMatrix = confusionmat(actualLabels', predictedLabels');
       TP = confusionMatrix(2,2);
       FP = confusionMatrix(1,2);
       FN = confusionMatrix(2,1);
       precision = TP/(TP+FP);
       recall = TP/(TP+FN);
       F1 = 2 * recall * precision / (precision + recall);
       newCsvData = [gestures(j) "Neural Network" num2str(precision) num2str(recall) num2str(F1)];
       csvData = [csvData; newCsvData];
end

%Writing all the data to the CSV
table = array2table(csvData);
writetable(table, "Statistics.csv");