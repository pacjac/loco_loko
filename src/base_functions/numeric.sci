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

function [x_neu] = gewichteterMittelwert(x)
    // x = Liste von Werten
    // i = Index der List
    // Ende der Liste
    listEnde = length(x)
    // Gewichtungsfaktoren
    a = 1;
    b = 2;
    c = 1;
    
    for i = 2 : listEnde - 1 
        x_neu(i) = (a * x(i - 1) + b * x(i) + c * x(i +1) ) / (a + b + c)
    end
    
    x_neu(1) = x(1)
    x_neu(listEnde) = x(listEnde)
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
