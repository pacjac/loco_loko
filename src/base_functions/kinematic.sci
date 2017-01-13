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

function [relangle] = calcLimbangle(jointA, jointB)
    
    for i = 1 : size(jointA.x, 1)
    
        dx = jointA.x(i) - jointB.x(i)
        dy = jointA.y(i) - jointB.y(i)
        PI = 3.1415
        hyp = sqrt(dx.^2 + dy.^2)
        angle = asin(dy/hyp)
        if dx < 0 & dy > 0  then
            relangle(i) = PI - angle
        elseif dx < 0 & dy < 0 then
            relangle(i) = PI - angle
        elseif dx > 0 & dy < 0 then
            relangle(i) = 2 * PI + angle
        else relangle(i) = angle
        end
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
