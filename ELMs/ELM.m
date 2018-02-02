% ELM - Extreme Learning Machine Class
%   Train and Predict a SLFN based on Extreme Learning Machine
%
%   This code was implemented based on the following paper:
%
%   [1] Guang-Bin Huang, Qin-Yu Zhu, Chee-Kheong Siew, Extreme learning
%       machine: Theory and applications, Neurocomputing,Volume 70, 
%       Issues 1–3, 2006, Pages 489-501, ISSN 0925-2312, 
%       https://doi.org/10.1016/j.neucom.2005.12.126.
%       (http://www.sciencedirect.com/science/article/pii/S0925231206000385)
%
%   Attributes: 
%       Attributes between *.* must be informed. 
%       ELM objects must be created using name-value pair arguments (see the Usage Example).
%
%       *numberOfInputNeurons*:     Number of neurons in the input layer.
%              Accepted Values:     Any positive integer.
%
%        numberOfHiddenNeurons:     Number of neurons in the hidden layer
%              Accepted Values:     Any positive integer (defaut = 1000).
%
%           activationFunction:     Activation funcion for hidden layer   
%              Accepted Values:     Function handle (see [1]) or one of these strings:
%                                       'sig':     Sigmoid (default)
%                                       'sin':     Sine
%                                       'hardlim': Hard Limit
%                                       'tribas':  Triangular basis function
%                                       'radbas':  Radial basis function
%
%                         seed:     Seed to generate the pseudo-random values.
%                                   This attribute is for reproducible research.
%              Accepted Values:     RandStream object or a integer seed for RandStream.
%
%       Attributes generated by the code:
%       
%                  inputWeight:     Weight matrix that connects the input 
%                                   layer to the hidden layer
%
%          biasOfHiddenNeurons:     Bias of hidden units
%
%                 outputWeight:     Weight matrix that connects the hidden
%                                   layer to the output layer
%
%   Methods:
%
%          obj = ELM(varargin):     Creates ELM objects. varargin should be in
%                                   pairs. Look attributes
%
%         obj = obj.train(X,Y):     Method for training. X is the input of size N x n,
%                                   where N is (# of samples) and n is the (# of features).
%                                   Y is the output of size N x m, where m is (# of multiple outputs)
%                            
%        Yhat = obj.predict(X):     Predicts the output for X.
%
%   Usage Example:
%
%       load iris_dataset.mat
%       X    = irisInputs';
%       Y    = irisTargets';
%       elm  = ELM('numberOfInputNeurons', 4, 'numberOfHiddenNeurons',100);
%       elm  = elm.train(X, Y);
%       Yhat = elm.predict(X)

%   License:
%
%   Permission to use, copy, or modify this software and its documentation
%   for educational and research purposes only and without fee is here
%   granted, provided that this copyright notice and the original authors'
%   names appear on all copies and supporting documentation. This program
%   shall not be used, rewritten, or adapted as the basis of a commercial
%   software or hardware product without first obtaining permission of the
%   authors. The authors make no representations about the suitability of
%   this software for any purpose. It is provided "as is" without express
%   or implied warranty.
%
%       Federal University of Espirito Santo (UFES), Brazil
%       Computers and Neural Systems Lab. (LabCISNE)
%       Authors:    F. K. Inaba, B. L. S. Silva, D. L. Cosmo 
%       email:      labcisne@gmail.com
%       website:    github.com/labcisne/ELMToolbox
%       date:       Jan/2018

classdef ELM
    properties
        numberOfHiddenNeurons = 1000                
        activationFunction = 'sig'
        numberOfInputNeurons = []        
        inputWeight = []
        biasOfHiddenNeurons = []
        outputWeight = []
        seed = []
    end
    methods
        function obj = ELM(varargin)
            for i = 1:2:nargin
                obj.(varargin{i}) = varargin{i+1};
            end
            if isnumeric(obj.seed) && ~isempty(obj.seed)
                obj.seed = RandStream('mt19937ar','Seed', obj.seed);
            elseif ~isa(obj.seed, 'RandStream')
                obj.seed = RandStream.getGlobalStream();
            end
            if isempty(obj.numberOfInputNeurons)
                throw(MException('ELM:emptynumberOfInputNeurons','Empty Number of Input Neurons'));
            end
            obj.inputWeight = rand(obj.seed, obj.numberOfInputNeurons, obj.numberOfHiddenNeurons)*2-1;
            obj.biasOfHiddenNeurons = rand(obj.seed, 1, obj.numberOfHiddenNeurons);
            
            if ~isa(obj.activationFunction,'function_handle') && ischar(obj.activationFunction)
                switch lower(obj.activationFunction)
                    case {'sig','sigmoid'}
                        %%%%%%%% Sigmoid
                        obj.activationFunction = @(tempH) 1 ./ (1 + exp(-tempH));
                    case {'sin','sine'}
                        %%%%%%%% Sine
                        obj.activationFunction = @(tempH) sin(tempH);
                    case {'hardlim'}
                        %%%%%%%% Hard Limit
                        obj.activationFunction = @(tempH) double(hardlim(tempH));
                    case {'tribas'}
                        %%%%%%%% Triangular basis function
                        obj.activationFunction = @(tempH) tribas(tempH);
                    case {'radbas'}
                        %%%%%%%% Radial basis function
                        obj.activationFunction = @(tempH) radbas(tempH);
                        %%%%%%%% More activation functions can be added here
                end
            else
                throw(MException('ELM:activationFunctionError','Error Activation Function'));
            end
        end
        function self = train(self, X, Y)
            tempH = X*self.inputWeight + repmat(self.biasOfHiddenNeurons,size(X,1),1);
            clear X;
            H = self.activationFunction(tempH);
            self.outputWeight = pinv(H) * Y;
        end
        function Yhat = predict(self, X)
            tempH = X*self.inputWeight + repmat(self.biasOfHiddenNeurons,size(X,1),1);
            clear X;
            H = self.activationFunction(tempH);
            Yhat = H * self.outputWeight;
        end
    end
end