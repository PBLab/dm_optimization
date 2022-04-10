function graphParams(iteration,newParams)
% Show plot on SIdmGUI
handles=getappdata(0,'axes_fitness');

if iteration==1
    cla(handles)
   
    xlabel(handles,'Frame')
    ylabel(handles,'Fitness')
end
hold(handles,'on')
stem(handles,iteration,newParams)