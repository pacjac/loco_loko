//********************************************
//              NUMERICS
//********************************************

// Ableiten per Vorwärtsdifferenz, erster Wert wird gesetzt
// Übergabe: 1 Spaltige Matrix, Skalares Delta-t
// Rückgabe: 1 Spaltige Matrix
function [fdiff] = ForwardDiff (values, delta)
    fdiff(1) = (values(2) - values(1)) / delta;
    for i = 2 : size(values, 1)
        fdiff(i, 1) = (values(i) - values(i - 1)) / delta;
    end
endfunction

// Ableiten per Rückwärtsdifferenz, letzter Wert wird gesetzt
// Übergabe: 1 Spaltige Matrix, Skalares Delta-t
// Rückgabe: 1 Spaltige Matrix
function [bdiff] = BackwardDiff (values, delta)
    endofdata = size(values,1)
    for i = 1 : endofdata - 1
        bdiff(i) = (values(i + 1) - values(i)) / delta;
    end
    bdiff(endofdata) = (values(endofdata) - values(endofdata - 1)) / delta;
endfunction

// Ableiten per Zentraldifferenz, Mittelwert aus Vorwärts und Rückwärtsdifferenz
// Übergabe: 1 Spaltige Matrix, Skalares Delta-t
// Rückgabe: 1 Spaltige Matrix
function [cdiff]= CentralDiff (values, delta)
    cdiff = (BackwardDiff(values, delta) + ForwardDiff(values, delta)) / 2
endfunction

// Vektorielle Größe in Skalare Größe umwandeln
// Übergabe: Struct mit 1 Spalte x und 1 Spalte y Werten
// Rückgabe: Matrix mit 1 Spalte absoluten Werten
function [scalarValues] = GetScalar(jointData)
    for i = 1 : size(jointData.x, 1)
        scalarValues(i) = sqrt(jointData.x(i)^2 + jointData.y(i)^2);
    end
endfunction

// Gleitenden Mittelwert eines Datensatzes berechnen
// Übergabe: Eine 1 spaltige Matrix
// Rückgabewert: Eine 1 spaltige Matrix
// Erster und letzter Wert werden nicht verändert, Länge der Matrix wird 
// beibehalten
function [movingMean] = MovingMean (values)
    movingMean(1) = values(1);
    endofdata = size(values,1)
    for i = 2 : endofdata - 1
        movingMean(i) = (values(i-1) + values(i) + values(i+1)) / 3;
    end
    movingMean(endofdata) = values(endofdata);
endfunction

// Gewichteter Mittelwert eines Datensatzes berechnen
// Übergabe: Eine 1 spaltige Matrix, drei Gewichtungswerte für vorhergehenden
//           aktuellen und nachfolgenden Wert
// Rückgabe: Eine 1 spaltige Matrix 
function [weightedMovingMean] = WeightedMovingMean (values, weightA, weightB, weightC)
    weightedMovingMean(1) = values(1);
    endofdata = size(values,1)
    for i = 2 : endofdata - 1
        weightedMovingMean(i) = (values(i-1) * weightA + values(i) * weightB + values(i+1) * weightC) / (weightA + weightB + weightC);
    end
    weightedMovingMean(endofdata) = values(endofdata);
endfunction

function [weightedMovingMean] = WeightedMovingMean4 (values, weightA, weightB, weightC, weightD, weightE)
    weightedMovingMean(1) = values(1);
    weightedMovingMean(2) = values(2);
    endofdata = size(values,1);
    for i = 3 : endofdata - 2
        weightedMovingMean(i) = (values(i - 2) * weightA + values(i - 1) * weightB + values(i) * weightC + values(i + 1) * weightD + values(i + 2) * weightE) / (weightA + weightB + weightC + weightD + weightE);
    end
    weightedMovingMean(endofdata - 1) = values(endofdata - 1);
    weightedMovingMean(endofdata) = values(endofdata);
endfunction

// Abstand zwischen zwei Punkten über Satz des Pythagoras
// Übergabe: Zwei 2 Spaltige Matrizen
// Rückgabe: Eine 1 Spaltige Matrix mit Skalaren Entfernungswerten
function [limbLength] = GetLimbLength (proximalJoint, distalJoint)
    for i = 1 : size(proximalJoint.x, 1)
        dx = distalJoint.x(i) - proximalJoint.x(i);
        dy = distalJoint.y(i) - proximalJoint.y(i);
        limbLength(i) = sqrt((dx)^2 + (dy)^2);
    end
endfunction

function [cusumSumPos] = posCUSUM (values, threshold)
    cusumSumPos (1) = 0
    len = size(values,1)
    for i = 2 : len
        cusumSumPos(i) = max(0, cusumSumPos(i - 1) + values(i) - threshold)
    end
endfunction

function [cusumSumNeg] = negCUSUM (values, threshold)
    cusumSumNeg (1) = 0
    len = size(values,1)
    for i = 2 : len
        cusumSumNeg(i) = -1 * min(0, -1*(cusumSumNeg(i - 1) - values(i) + threshold))
    end
endfunction

function [cusumSum] = CUSUM (values, threshold)
    cusumSum(1) = 0
    len = size(values,1)
    for i = 2 : len
        cusumSum(i) = cusumSum(i - 1) + values(i) - threshold
    end
endfunction

//********************************************
//              LOKO-FUNCTIONS
//********************************************

// Massenschwerpunkt eines Körperteils berechnen per Anthroprometrie
// Übergabe: Zwei 2 Spaltige Matrizen und skalarer Wert aus Tabelle
// Rückgabe: Eine Zweispaltige Matrix mit Koordinaten des Masseschwerpunkts
function [CoM] = CalcCoM(proximalJoint, distalJoint, anthrof)
    for i = 1 : size(proximalJoint.x,1)
        dx = distalJoint.x(i) - proximalJoint.x(i);
        dy = distalJoint.y(i) - proximalJoint.y(i);
        CoM.x(i) = dx * anthrof + proximalJoint.x(i);
        CoM.y(i) = dy * anthrof + proximalJoint.y(i);
    end
endfunction

// Translative Geschwindigkeit eines Punktes / Gelenks berechnen per Zentraldiff
// Übergabe: Eine 2 Spaltige Matrix mit Ortskoordinaten
// Rückgabe: Eine 2 Spaltige Matrix mit Geschwindigkeitsvektoren
function [speed]= CalcSpeed (joint)
    speed.x = CentralDiff(joint.x, DELTA_T);
    speed.y = CentralDiff(joint.y, DELTA_T);
endfunction

// Translative Beschleunigung eines Punktes per Zentraldifferenz
// Übergabe: Eine 2 spaltige Matrix mit Ortskoordinaten
// Rückgabe: Eine 2 spaltige Matrix mit Beschleunigungsvektoren
function [transAcc] = CalcAcceleration (joint)
    speed = CalcSpeed(joint);
    transAcc = CalcSpeed(speed);
endfunction


// Winkel der am mittleren Gelenk von drei übergebenen Gelenken anliegt
// Übergabe: Drei 2 spaltige Matrizen mit Koordinaten
// Rückgabe: Eine 1 spaltige Matrix mit skalaren Winkelwerten (Einheit Grad)
function [angle] = CalcAngle(proximalJoint, middleJoint, distalJoint)
    dxProx = proximalJoint.x - middleJoint.x;
    dyProx = proximalJoint.y - middleJoint.y;
    dxDist = middleJoint.x - distalJoint.x;
    dyDist = middleJoint.y - distalJoint.y;
    angle = (atan(dyProx, dxProx) - atan(dxDist, dyDist)) * 180 / PI;
    //if angle > 180 then angle = 360 - angle
    //end
endfunction

function [angle] = LawOfCosines(A, B, C)
    aT = GetLimbLength(B, C)
    bT = GetLimbLength(A, C)
    cT = GetLimbLength(A, B)
    for i = 1 : size(aT, 1)
        a = aT(i)
        b = bT(i)
        c = cT(i)
        angle(i) = acos((b*b - a*a - c*c) / (-2 * a * c)) * 180 / PI
    end
  
endfunction


// Winkelgeschwindigkeit am mittleren Gelenk von drei übergebenen Gelenken
// Übergabe: Drei 2 spaltige Matrizen mit Koordinaten
// Rückgabe: Eine 1 spaltige Matrix mit skalaren Winkelgeschw.werten (Einheit Grad/s)
function [angSpeed]= CalcAngSpeed (proximalJoint, middleJoint, distalJoint)
    angle = CalcAngle(proximalJoint, middleJoint, distalJoint);
    angSpeed = CentralDiff(angle, DELTA_T);
endfunction

function [limb] = anal(limb)
    limb.speed = CalcSpeed(limb)
    limb.acc = CalcAcceleration(limb)
    limb.absspeed = GetScalar(limb.speed)
    limb.absacc = GetScalar(limb.acc)
    limb.smoothspeed = MovingMean(MovingMean(limb.absspeed))
endfunction

function calculateAllAngles()
    ankle.angle = LawOfCosines(knee, ankle, toes)
    knee.angle = LawOfCosines(hip, knee, ankle)
    hip.angle = LawOfCosines(shoulder, hip, knee)
    elbow.angle = LawOfCosines(shoulder, elbow, hand)   
endfunction


// WAAAAAAAAGENSTUFF
// BECAUSE IT SUCKS DONKEY BALLS IN HELL
// IRGENDWANN SCHREIBE ICH MAL NOCH NE DOKU WAS DIE FUNKTIONUEN TUEN 
// ABER NICHT JETZT

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
    smoothData.Fx = WeightedMovingMean4(((data(:,2) - (data(:,1) * scaledrift.x + offsetX  )) * voltageToForce.x), 0.0, 1, 1, 1, 0.0)
    smoothData.Fy = WeightedMovingMean4(((data(:,3) - (data(:,1) * scaledrift.y + offsetY  )) * voltageToForce.y), 0.25, 0.5, 0.75, 0.5, 0.25)
    smoothData.Fz = WeightedMovingMean4(((data(:,4) - (data(:,1) * scaledrift.z + offsetZ  )) * voltageToForce.z), 0.25, 0.5, 0.75, 0.5, 0.25)
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
