
classdef SILiteController < handle
% CYCLEMANAGERCONTROLLER Controller class for cycle mode
    properties
        model
        view
    end
    % CONSTRUCTOR
    methods
        function obj = SILiteController(model)
            obj.model = model;
            obj.view = scanimage.SILiteView(obj);
        end
    end
    % USER METHODS
    methods
        function setLogFileName(obj,val)
            obj.model.hScan_LinScanner.logFileStem = val;
        end
        function setEnableLoggingMode(obj,val)
            obj.model.hChannels.loggingEnable = logical(val);
        end
        function startGrabAcquisition(obj)
            obj.model.startGrab();
        end
        function abortAcquisition(obj)
            obj.model.abort();
        end
    end
end