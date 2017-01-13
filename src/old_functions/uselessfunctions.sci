



function plotTrajectory(joint)
        // plot x - y curve of joint
endfunction
    
function plotKinematics(limb)
        
endfunction


function plotAngles(i)
    scf(i)
    ax(i) = newaxes()
    plot2d(time / Cycle_T, [ankle.angle,knee.angle,  hip.angle, elbow.angle], style=[color("red"), color("green"), color("blue"), color("purple")]) //,
    ax(i).title.text = "Winkelverläufe, Geschwindigkeit " + speeds(i)
    ax(i).x_label.text = "Entdimensionierter Schrittzyklus"
    ax(i).y_label.text = "Winkel in Grad"
    h1 = legend(["Sprunggelenk", "Kniegelenk", "Hüfte", "Ellenbogen"], [-1], [%t])
endfunction
// Leon writes functions

// Statistics? Correlation

// WRITE RESULTS

    
function saveResults(joints, savetarget)
    
    for i = 1 : joints(size, 1)
        fprintfMat(savetarget, [joints(i).smoothspeed, joints(i).absacc]); // Speichern fprintfMat(Zielpfad, Daten)
    end
endfunction    
    
    
function plotSpeeds()
    scf(10)
    ax = gca()
    
    
    for j = 1 : size(limbs, 2)
    subplot(size(limbs, 2), 1, j);
                
        plot2d(time / Cycle_T, limbs(j).smoothspeed);    //nowcolor]);
        ax2 = gca()
        e = gce()
        graph = e.children(1)
        graph.foreground = limbs(j).color
        ax2.title.text = limbs(j).name
    end
endfunction

    
    
