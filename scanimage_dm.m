function [hSI_,hSICtl_,hSInew_] = scanimage(varargin)
% SCANIMAGE     starts ScanImage application and its GUI(s)
%
%   It places two variables in the base workspace.
%   hSI is a scanimage.SI object that gives access to the operation and
%   configuration of the microscope.  hSICtl gives access to the user
%   interface elements.  There is implicit synchronization between the
%   microscope configuration and the user interface, so most of the time,
%   hSICtl can be safely ignored.
%
%   See also scanimage.SI and scanimage.SIController

if nargout > 0
    hSI_ = [];
    hSICtl_ = [];
    hSInew_= [];
end

mdf = '';
usr = '';
hidegui = false;

scanimage.util.checkSystemRequirements();

if nargin > 0 && ischar(varargin{1})
    mdf = varargin{1};
    assert(logical(exist(mdf,'file')), 'Specified machine data file not found.');
end

if nargin > 1 && ischar(varargin{2})
    usr = varargin{2};
    if ~isempty(usr)
        assert(logical(exist(usr,'file')), 'Specified usr file not found.');
    end
end

if nargin > 2
    for i = 3:nargin
        if ischar(varargin{i}) && strcmp(varargin{i}, '-hidegui')
            hidegui = true;
        end
    end
end

hSI = [];
if evalin('base','exist(''hSI'')')
    hSI = evalin('base','hSI');
end

hSICtl = [];
if evalin('base','exist(''hSICtl'')')
    hSICtl = evalin('base','hSICtl');
end

hSInew = [];
if evalin('base','exist(''hSInew'')')
    hSInew = evalin('base','hSInew');
end

if isempty(hSI)    
    hCE = scanimage.guis.ConfigurationEditor([],false,true); %ConfigurationEditor(mdfPath,initNow,persist)
    
    if isempty(mdf) && isempty(usr)
        [mdf,usr,runSI] = scanimage.guis.StartupConfig.doModalConfigPrompt(mdf,usr,hCE);
        if ~runSI
            most.idioms.safeDeleteObj(hCE);
            return;
        end
    end
    
    try
        fprintf('Initializing ScanImage engine...\n');
        hSI = scanimage.SI(mdf,hCE);
        hSIBasename = 'hSI';
        assignin('base',hSIBasename,hSI); % assign object in base as soon as it is constructed
        hSI.initialize();
        fprintf('ScanImage engine initialized.\n');
        
        fprintf('Initializing user interface...\n');
        hSInew = scanimage.SIController(hSI);
        hSInew.hConfigEditor = hCE;
        hSICtl = scanimage.SILiteController(hSI);
        assignin('base','hSInew',hSI.hController{1}); % assign object in base as soon as it is constructed
        hSInew.initialize(usr,hidegui);
        hSInew.attachPropBindingsToToolTipStrings(['Command line: ' hSIBasename '.']);
        fprintf('User interface intialized.\n');
    catch ME
        if exist('hSI', 'var')
            most.idioms.safeDeleteObj(hSI);
        end
        
        most.idioms.safeDeleteObj(hCE);
        evalin('base','clear hSI hSICtl MachineDataFile');
        
        if strcmp(ME.message, 'MachineDateFile: Operation canceled.')
            most.idioms.warn(ME.message);
        else
            ME.rethrow;
        end
    end
elseif isempty(hSICtl)
    try
        fprintf('Initializing user interface...\n');
        hSICtl = scanimage.SIController(hSI);
        assignin('base','hSICtl',hSICtl);
        hSICtl.initialize(usr,hidegui);
        hSICtl.attachPropBindingsToToolTipStrings('Command line: hSI.');
        fprintf('User interface intialized.\n');
    catch ME
        evalin('base','clear hSICtl');
        ME.rethrow;
    end
else
    most.idioms.warn('ScanImage is already running.');
    evalin('base','hSICtl.raiseAllGUIs')
end

if nargout > 0
    hSI_ = hSI;
    hSICtl_ = hSICtl;
end

end


%--------------------------------------------------------------------------%
% scanimage.m                                                              %
% Copyright © 2019 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage is licensed under the Apache License, Version 2.0              %
% (the "License"); you may not use any files contained within the          %
% ScanImage release  except in compliance with the License.                %
% You may obtain a copy of the License at                                  %
% http://www.apache.org/licenses/LICENSE-2.0                               %
%                                                                          %
% Unless required by applicable law or agreed to in writing, software      %
% distributed under the License is distributed on an "AS IS" BASIS,        %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. %
% See the License for the specific language governing permissions and      %
% limitations under the License.                                           %
%--------------------------------------------------------------------------%
