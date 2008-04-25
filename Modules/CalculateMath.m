function handles = CalculateMath_DL(handles)

% TEST
% Help for the Calculate Math module:
% Category: Measurement
%
% SHORT DESCRIPTION:
% This module can take any measurements produced by previous modules and
% can manipulate the numbers using basic arithmetic operations.
% *************************************************************************
%
% The arithmetic operations available in this module include addition,
% subtraction, multiplication and division. The operation can be chosen
% by adjusting the operations setting. The resulting data can also be
% logged or raised to a power. This data can then be used in other
% calculations and can be used in Classify Objects.
%
% This module currently works on an object-by-object basis (it calculates
% the requested operation for each object) but can also apply the operation
% for measurements made for entire images (but only for measurements
% produced by the Correlation module).
%
% Feature Number:
% The feature number specifies which features from the Measure module(s)
% will be used for the operation. See each Measure module's help for the
% numbered list of the features measured by that module.
%
% See also CalculateRatios, all Measure modules.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Please see the AUTHORS file for credits.
%
% Website: http://www.cellprofiler.org
%
% $Revision$

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = Which object would you like to use as the first measurement (The option IMAGE currently only works with Correlation measurements)?
%choiceVAR01 = Image
%infotypeVAR01 = objectgroup
%inputtypeVAR01 = popupmenu
FirstObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,1});

%textVAR02 = Which category of measurements would you like to use?
%choiceVAR02 = AreaShape
%choiceVAR02 = Correlation
%choiceVAR02 = Intensity
%choiceVAR02 = Neighbors
%choiceVAR02 = Texture
%inputtypeVAR02 = popupmenu custom
FirstCategory = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = Which feature do you want to use? (Enter the feature number - see help for details)
%defaultVAR03 = 1
FirstFeatureNumber = str2double(handles.Settings.VariableValues{CurrentModuleNum,3});

%textVAR04 = For INTENSITY or TEXTURE features, which image's measurements would you like to use?
%infotypeVAR04 = imagegroup
%inputtypeVAR04 = popupmenu
FirstImage = char(handles.Settings.VariableValues{CurrentModuleNum,4});

%textVAR05 = Which object would you like to use as the second measurement? (The option IMAGE currently only works with Correlation measurements)?
%choiceVAR05 = Image
%infotypeVAR05 = objectgroup
%inputtypeVAR05 = popupmenu
SecondObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,5});

%textVAR06 = Which category of measurements would you like to use?
%choiceVAR06 = AreaShape
%choiceVAR06 = Correlation
%choiceVAR06 = Intensity
%choiceVAR06 = Neighbors
%choiceVAR06 = Texture
%inputtypeVAR06 = popupmenu custom
SecondCategory = char(handles.Settings.VariableValues{CurrentModuleNum,6});

%textVAR07 = Which feature do you want to use? (Enter the feature number - see help for details)
%defaultVAR07 = 1
SecondFeatureNumber = str2double(handles.Settings.VariableValues{CurrentModuleNum,7});

%textVAR08 = For INTENSITY or TEXTURE features, which image's measurements would you like to use?
%infotypeVAR08 = imagegroup
%inputtypeVAR08 = popupmenu
SecondImage = char(handles.Settings.VariableValues{CurrentModuleNum,8});

%textVAR09 = Do you want the log (base 10) of the ratio?
%choiceVAR09 = No
%choiceVAR09 = Yes
%inputtypeVAR09 = popupmenu
LogChoice = char(handles.Settings.VariableValues{CurrentModuleNum,9});

%textVAR10 = Raise to what power?
%defaultVAR10 = 1
Power = str2double(handles.Settings.VariableValues{CurrentModuleNum,10});

%textVAR11 = Operation?
%choiceVAR11 = Multiply
%choiceVAR11 = Divide
%choiceVAR11 = Add
%choiceVAR11 = Subtract
%inputtypeVAR11 = popupmenu
Operation = char(handles.Settings.VariableValues(CurrentModuleNum, 11));

%%%VariableRevisionNumber = 4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MAKE MEASUREMENTS & SAVE TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

SetBeingAnalyzed = handles.Current.SetBeingAnalyzed;

if strcmp(FirstCategory,'Intensity') || strcmp(FirstCategory,'Texture')
%     FirstCategory = [FirstCategory, '_', FirstImage];
    FirstCategory = CPjoinstrings(FirstCategory,FirstImage);
end

if strcmp(SecondCategory,'Intensity') || strcmp(SecondCategory,'Texture')
%     SecondCategory = [SecondCategory, '_', SecondImage];
    SecondCategory = CPjoinstrings(SecondCategory,SecondImage);
end

% Get measurements
FirstMeasurements = handles.Measurements.(FirstObjectName).(FirstCategory){SetBeingAnalyzed};
FirstMeasurements = FirstMeasurements(:,FirstFeatureNumber);
SecondMeasurements = handles.Measurements.(SecondObjectName).(SecondCategory){SetBeingAnalyzed};
SecondMeasurements = SecondMeasurements(:,SecondFeatureNumber);

if length(FirstMeasurements) ~= length(SecondMeasurements)
    error(['Image processing was canceled in the ', ModuleName, ' module because the specified object names ',FirstObjectName,' and ',SecondObjectName,' do not have the same object count.']);
end

FirstFeatureName = CPfeaturename(handles,FirstObjectName,FirstCategory,FirstFeatureNumber);
SecondFeatureName = CPfeaturename(handles,SecondObjectName,SecondCategory,SecondFeatureNumber);
NewFieldName = CPjoinstrings(FirstObjectName,FirstCategory,FirstFeatureName,Operation,SecondObjectName,SecondCategory,SecondFeatureName);

if( strcmpi(Operation, 'Multiply') )
    FinalMeasurements = FirstMeasurements.*SecondMeasurements;
elseif( strcmpi(Operation, 'Divide') )
    FinalMeasurements = FirstMeasurements./SecondMeasurements;
elseif( strcmpi(Operation, 'Add') )
    FinalMeasurements = FirstMeasurements + SecondMeasurements;
elseif( strcmpi(Operation, 'Subtract') )
    FinalMeasurements = FirstMeasurements - SecondMeasurements;
end
    
if strcmp(LogChoice,'Yes')
    FinalMeasurements = log10(FinalMeasurements);
end

if ~isnan(Power)
    FinalMeasurements = FinalMeasurements .^ Power;
end

handles = CPaddmeasurements(handles,'Math',NewFieldName,FinalMeasurements);

%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% The figure window display is unnecessary for this module, so it is
%%% closed during the starting image cycle.
CPclosefigure(handles,CurrentModule)