function graphParams(iteration,newParams)
% Show plot on SIdmGUI
handles=getappdata(0,'handles');
stem(handles,iteration,newParams)
hold(handles,'on')
end