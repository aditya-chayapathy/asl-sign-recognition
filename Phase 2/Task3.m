gesture_list = ["about", "and", "can", "cop", "decide", "deaf", "father", "find", "go out", "hearing"];

% Reading Task2 output
X_table = readtable("Task2Output.csv");
X = table2array(X_table);

%Performing PCA on the feature matrix
[coeff, score, latent, T2, explained] = pca(X(:,2:end));

%{
Biplot for representing the contribution of each feature in the Top 3
Principal Components 
%}
Bar_List = {'DWT-ARX[6]' , 'DWT-ARX[12]' , 'DWT-ALY[8]', 'DWT-ALY[9]', 'DWT-ALY[10]', 'DWT-OPR[8]', 'RMS-EMG0R', 'RMS-EMG2R' , 'RMS-EMG3R' , 'RMS-EMG4R' , 'STD-ARZ' , 'STD-OPL' , 'STD-ORR'};
figure();
title('Feature Contribution to Top 2 Components');
biplot(coeff(:, 1:3), 'varlabels', Bar_List);

%Creating directory if it doesn't exist
if ~exist("Graphs", 'dir')
    mkdir(char("Graphs"));
end
filename = char(strcat("Graphs/","Biplot"));
saveas(gcf, filename, 'png');

%Extracting the first three principal components
principle_components = [score(:,[1,2,3]) X(:, 1)];

%Creating directory if it doesn't exist
if ~exist("PrincipalComponents", 'dir')
    mkdir(char("PrincipalComponents"));
end
for current_pc=1:3
    for class = 1:10
        pc_per_class = principle_components(principle_components(:,end)==class, [current_pc]);
        %Plotting a histogram for each principal component
        histogram(pc_per_class, 25);
        title(strcat(strcat(gesture_list(class), '-PrincipalComponent-'), num2str(current_pc)));
        xlabel('Component Value');
        ylabel('Frequency');
        filename = char(strcat('PrincipalComponents/', strcat(strcat(gesture_list(class), '_PrincipalComponent_'), num2str(current_pc))));
        saveas(gcf, filename, 'png');
    end
 
end