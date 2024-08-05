function showWarningMessageBox(msg)
    persistent shown;
    if isempty(shown) || ~shown
        msgbox(msg, 'Warning', 'warn');
        shown = true;
        uiwait; 
        shown = []; % Reset point
    end
end
