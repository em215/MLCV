clear all
close all
clc

% Load training and testing data saved from the getData_RF.m function
load data_train_256.mat
load data_test_256.mat

%% Setting the parameter of the tree
param.s = size(data_train,1)*(1 - 1/exp(1)); %size of bags s
param.replacement = 1; % 0 for no replacement and 1 for replacement

%% Training Tree
AccTot = [];

%Find the size of the training data (i.e. size of vocabulary)
param.dimensions = size(data_train,2)-1;

% Optional parameter sweep loops
for n = 25
    param.n = n;
    [bags] = bagging(param, data_train);
    for numlevels = 8
        param.numlevels = numlevels;
        for numfunct = 15
            param.numfunct= numfunct;
            
            %Train the forest using the bags and parameters defined
            tic
            [leaves, nodes] = trainForest3(bags, param);
            param.trainingtime = toc;
            
            % Test the trees and evaluate the accuracy of the classification of
            % the test images.
            [classPred] = testForest3(param, data_test, leaves, nodes, 0, 0);
            Acc = [param.n, param.numlevels, param.numfunct,accuracy(param, data_test, classPred)];
            AccTot = [AccTot; Acc];
            clear Acc
            
            % Calculate the confussion matrix for the image categories
            [Conf, order] = confusionmat(data_test(:,param.dimensions+1),classPred(:,1));
            Conf = 100/15.*Conf;
            
            clear leaves
            clear nodes
        end
    end
    clear bags
end