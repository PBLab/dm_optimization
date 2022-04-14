function disable_user_functions(varargin)
%SETUP_USER_FUNCTIONS prepares the user function configuration to run with
%the DMoptimization
%   Detailed explanation goes here
%We greate a structure corresponding to the user function settings and
%update.
%Pablo

%%
UserFcnName = {'DMoptimization','DMoptimization','DMoptimization','DMoptimization'};
EventName = {'acqModeStart','acqModeDone','acqAbort','frameAcquired'};
Enable = {0, 0, 0, 0};
Arguments={{},{},{},{}};
cfg = struct('UserFcnName',UserFcnName,'EventName',EventName,...
    'Arguments',Arguments,'Enable',Enable);
assignin('base','cfg',cfg);
evalin('base','hSI.hUserFunctions.userFunctionsCfg=cfg;');

end

