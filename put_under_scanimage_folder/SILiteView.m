classdef SILiteView < handle
% CYCLEMANAGER Model class for cycle mode
    properties
        gui
        model
        controller
    end
    methods
        function obj = SILiteView(controller)
            obj.controller = controller;
            obj.model = controller.model;
            obj.gui = SIdmGUI('controller',obj.controller);
            % Initialization call goes here
            obj.initializeGUIFromModel(obj.gui);
            addlistener(obj.model.hScan_ResScanner,'logFileStem',...
                'PostSet',@(src,evnt)scanimage.SILiteView.handlePropEvents(obj,src,evnt));
            addlistener(obj.model.hChannels,'loggingEnable',...
                'PostSet',@(src,evnt)scanimage.SILiteView.handlePropEvents(obj,src,evnt));
        end
        function delete(obj)
            disp('View destructor');
            if ishandle(obj.gui)
                close(obj.gui);
            end
        end
        function initializeGUIFromModel(obj, hGUI)
            handles = guidata(hGUI);
            % Check the model's initial state
            %set(handles.cbEnableLogging, 'Value', obj.model.hChannels.loggingEnable);
            %set(handles.etLogFileName, 'String', obj.model.hScan_LinScanner.logFileStem);
        end
    end
    methods (Static)
        function handlePropEvents(obj,src,evnt)
            evntobj = evnt.AffectedObject;
            handles = guidata(obj.gui);
            switch src.Name
                case 'logFileName'
                    set(handles.etLogFileName, 'Value', evntobj.logFileStem);
                case 'loggingEnable'
                    set(handles.cbEnableLogging, 'Value', evntobj.loggingEnable);
            end
        end
    end
end