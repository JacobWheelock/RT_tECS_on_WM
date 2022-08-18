function initPy()
pyStr = pyenv;
pyTCL = fullfile(pyStr.Home, 'tcl', 'tcl8.6');
pyTK = fullfile(pyStr.Home, 'tcl', 'tk8.6');
setenv('TCL_LIBRARY', pyTCL);
setenv('TK_LIBRARY', pyTK);
if (matlab.engine.isEngineShared == 0)
    matlab.engine.shareEngine;
end
end

