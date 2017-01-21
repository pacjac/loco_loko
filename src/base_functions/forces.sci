function [forcesRaw] = readScaleFile (filepath)
    data = fscanfMat(filepath);
    index = 1
    while data(index,1) < 3.20
        index = index + 1
    end
    forcesRaw = data(index:$,: )
endfunction

function [forces] = combineChannels (data)
    b = 0.0575
    for i = 1 : size(data, 1)
    
    forces(i,1) = data(i,1);
    forces(i,2) = data(i,2) + data(i,3);
    // Channels parallel to walking direction
    forces(i,3) = data(i,4) + data(i,5);  
    // Z channels // Parallel Gravitation
    forces(i,4) = data(i,6) + data(i,7) + data(i,8) + data(i,9);
    forces(i,5) = ( ( data(i,6) + data(i,7)) / ( data(i,6) + data(i,7) + data(i,8) + data(i,9) ) )*2*b - b
    end
endfunction

function [forces] = combine_offset_data(data)
    for i = 1 : size(data, 1)
    
    forces(i,1) = data(i,1);
    forces(i,2) = data(i,2) + data(i,3);
    // Channels parallel to walking direction
    forces(i,3) = data(i,4) + data(i,5);  
    // Z channels // Parallel Gravitation
    forces(i,4) = data(i,6) + data(i,7) + data(i,8) + data(i,9);
    end
endfunction

function [scaledrift] = calcScaleDrift(data)
    [ scaleOffsetXSLOPE, scaleOffsetXOFFSET, scaleOffsetXSIGMA ]= reglin( data(:,1)', data(:,2)' );
    [ scaleOffsetYSLOPE, scaleOffsetYOFFSET, scaleOffsetYSIGMA ]= reglin( data(:,1)', data(:,3)' );
    [ scaleOffsetZSLOPE, scaleOffsetZOFFSET, scaleOffsetZSIGMA ]= reglin( data(:,1)', data(:,4)' );
    scaledrift.x = scaleOffsetXSLOPE
    scaledrift.y = scaleOffsetYSLOPE
    scaledrift.z = scaleOffsetZSLOPE
endfunction

function [voltageToForce] = convertVoltageToForce(xCal, yCal, zCal)
    
    kg = [0, 1, 3.6, 7.75];  //kalibrationsgewichte
    
    meanVoltageX = [ mean(xCal(2000:5000, 2)), mean(xCal(8000:11000, 2)), mean(xCal(14000:17000, 2)), mean(xCal(20000:23000, 2)) ];
    meanVoltageY = [ mean(yCal(2000:5000, 3)), mean(yCal(8000:11000, 3)), mean(yCal(14000:17000, 3)), mean(yCal(20000:23000, 3)) ];
    meanVoltageZ = [ mean(zCal(2000:5000, 4)), mean(zCal(11000:14000, 4)), mean(zCal(18000:21000, 4)), mean(zCal(27000:30000, 4)) ];

    [ scaleVoltageXSLOPE, scaleVoltageXOFFSET, scaleVoltageXSIGMA ] = reglin( meanVoltageX, kg * 9.81);
    [ scaleVoltageYSLOPE, scaleVoltageYOFFSET, scaleVoltageYSIGMA ] = reglin( meanVoltageY, kg * 9.81);
    [ scaleVoltageZSLOPE, scaleVoltageZOFFSET, scaleVoltageZSIGMA ] = reglin( meanVoltageZ, kg * 9.81);

    voltageToForce.x = scaleVoltageXSLOPE;
    voltageToForce.y = scaleVoltageYSLOPE;
    voltageToForce.z = scaleVoltageZSLOPE;
    
endfunction

function [offset] = getOffset (data)
    offset.x = mean(data(400:500,2))
    offset.y = mean(data(400:500,3))
    offset.z = mean(data(400:500,4))
endfunction


function [smoothData] = calculateForces (data, scaledrift, voltageToForce)
    
    offsetX = mean(data(100:200,2))
    offsetY = mean(data(100:200,3)) 
    offsetZ = mean(data(100:200,4))

    smoothData.t = data(:,1)
    smoothData.Fx = WeightedMovingMean4(((data(:,2) - (data(:,1) * scaledrift(1) + offsetX  )) * voltageToForce(1)), 0.0, 1, 1, 1, 0.0)
    smoothData.Fy = WeightedMovingMean4(((data(:,3) - (data(:,1) * scaledrift(2) + offsetY  )) * voltageToForce(2)), 0.25, 0.5, 0.75, 0.5, 0.25)
    smoothData.Fz = WeightedMovingMean4(((data(:,4) - (data(:,1) * scaledrift(3) + offsetZ  )) * voltageToForce(3)), 0.25, 0.5, 0.75, 0.5, 0.25)
    smoothData.offsetX = offsetX
    smoothData.offsetY = offsetY
    smoothData.offsetZ = offsetZ
    smoothData.CoF_y = data(:,5)
endfunction

function plotForces (data, num, title, resolution )
    plotHandle = scf(num)
    plot(data.t, data.x, 'r')
    plot(data.t, data.y, 'g')
    plot(data.t, data.z, 'b')
    plotHandle.figure_size = resolution
    plotHandle.figure_name = title
    axes = gca()
    xlabel(axes, "Zeit [s]")
    ylabel(axes, "Gewicht [kg]")    
    xs2svg(plotHandle, title+'.svg')
endfunction
