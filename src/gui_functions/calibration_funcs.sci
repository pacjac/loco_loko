function calibrate()
    // Working frame
    global axes_frame;
    
    // Make calibration results global
    global voltageToForce scaleDrift;
    
    sca(axes_frame)
    caldir = uigetdir(cwd + "../data/", "Select Calibration Directory")
    
    driftfile = caldir + '/Waagendrift_clean.txt';
    offsetDataRaw = readScaleFile(driftfile);
    xCalFile = caldir + '/XKali_clean.txt';
    xCalRaw = readScaleFile(xCalFile)
    yCalFile = caldir + '/YKali_clean.txt';
    yCalRaw = readScaleFile(yCalFile);
    zCalFile = caldir + '/ZKali_clean.txt';
    zCalRaw = readScaleFile(zCalFile);
    
    offsetData = combine_offset_data(offsetDataRaw)
    xCal = combine_offset_data(xCalRaw)
    yCal = combine_offset_data(yCalRaw)
    zCal = combine_offset_data(zCalRaw)
    
    // Plot xcal
    sca(axes_frame)
    clear_plot(axes_frame)
    plot2d(xCal(:,2), style = [color("blue")]);
    legend("xCalibration")
    
    // Get boundaries for each weight
    tmpLocation = locate(8)
    tmpLocation = int(tmpLocation)
    xLimits = tmpLocation(1,:)
    
    clear_plot(axes_frame)
    
    // Plot ycal
    plot2d(yCal(:,3), style = [color("green")]);
    legend("yCalibration")
    
    // Get boundaries for each weight
    tmpLocation = locate(8)
    tmpLocation = int(tmpLocation)
    yLimits = tmpLocation(1,:)
    
    clear_plot(axes_frame)
    
    // Plot zcal
    plot2d(zCal(:,4), style = [color("red")]);
    legend("zCalibration")
    
    // Get boundaries for each weight
    tmpLocation = locate(8)
    tmpLocation = int(tmpLocation)
    zLimits = tmpLocation(1,:)
    
    kg = [0, 1, 3.6, 7.75];  //kalibrationsgewichte
   
    
    meanVoltageX = [ mean(xCal(xLimits(1):xLimits(2), 2)), mean(xCal(xLimits(3):xLimits(4), 2)), mean(xCal(xLimits(5):xLimits(6), 2)), mean(xCal(xLimits(7):xLimits(8), 2)) ];
    meanVoltageY = [ mean(yCal(yLimits(1):yLimits(2), 3)), mean(yCal(yLimits(3):yLimits(4), 3)), mean(yCal(yLimits(5):yLimits(6), 3)), mean(yCal(yLimits(7):yLimits(8), 3)) ];
    meanVoltageZ = [ mean(zCal(zLimits(1):zLimits(2), 4)), mean(zCal(xLimits(3):zLimits(4), 4)), mean(zCal(zLimits(5):zLimits(6), 4)), mean(zCal(zLimits(7):zLimits(8), 4)) ];

    // Linear regression Voltage output to Newton 
    [ scaleVoltageXSLOPE, scaleVoltageXOFFSET, scaleVoltageXSIGMA ] = reglin( meanVoltageX, kg * 9.81);
    [ scaleVoltageYSLOPE, scaleVoltageYOFFSET, scaleVoltageYSIGMA ] = reglin( meanVoltageY, kg * 9.81);
    [ scaleVoltageZSLOPE, scaleVoltageZOFFSET, scaleVoltageZSIGMA ] = reglin( meanVoltageZ, kg * 9.81);

    voltageToForce(1) = scaleVoltageXSLOPE;
    voltageToForce(2) = scaleVoltageYSLOPE;
    voltageToForce(3) = scaleVoltageZSLOPE;
    
    [ scaleOffsetXSLOPE, scaleOffsetXOFFSET, scaleOffsetXSIGMA ]= reglin( offsetData(:,1)', offsetData(:,2)' );
    [ scaleOffsetYSLOPE, scaleOffsetYOFFSET, scaleOffsetYSIGMA ]= reglin( offsetData(:,1)', offsetData(:,3)' );
    [ scaleOffsetZSLOPE, scaleOffsetZOFFSET, scaleOffsetZSIGMA ]= reglin( offsetData(:,1)', offsetData(:,4)' );
    scaleDrift(1) = scaleOffsetXSLOPE
    scaleDrift(2) = scaleOffsetYSLOPE
    scaleDrift(3) = scaleOffsetZSLOPE
    
    // Save calibration for later use
    fprintfMat(caldir + '/voltagetoforce.txt', [voltageToForce]) 
    fprintfMat(caldir + '/drift.txt', [scaleDrift])
    
endfunction

function load_calibration()
    // Set function results global
    global voltageToForce scaleDrift
    
    // Load calibration that was created using calibrate()
    caldir = uigetdir(cwd + "../data/", "Select Calibration Directory")
    voltageToForce = fscanfMat(caldir + '/voltagetoforce.txt')
    scaleDrift = fscanfMat(caldir + '/drift.txt')    
endfunction
