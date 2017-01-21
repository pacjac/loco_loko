function calc_forces()
    global voltageToForce scaleDrift forces 
    global forcefile // Muss das?
    
    forcefile = uigetfile(["*.*", "Force files"], cwd + "/../data/Waage/","Select force data",%t)
    
   
    for i = 1 : size(forcefile, 2)
        forceRaw = readScaleFile(forcefile(i));
        force_sum = combineChannels(forceRaw)
        force_smooth = calculateForces(force_sum, scaleDrift, voltageToForce)
        forces(i) = force_smooth 
        tmp = tokens(forcefile(i), ['/','.'])
        forces(i).name = tmp($ - 1)
    end
    
    //forces = force_smooth(1)
endfunction

function [force] = load_forces(path)
    forceRaw = readScaleFile(path);
    force_sum = combineChannels(forceRaw, 2.5)
    force = calculateForces(force_sum, scaleDrift, voltageToForce)
endfunction


function inverse_kinetic()
    
    global body 
    global forces
    global g
    global axes_frame
    global results_figure
    global enable_help
    
    
    for i = 1 : size(forces, 1)
        
        [toes, ankle, knee, hip, shoulder, elbow, hand, neck, foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = setCurrentBody(body(i))
    
        grfBalance = forces(i)
        // Determine initial Contact from force Data
        force_window = scf(100)
        force_axes = force_window.children
        
        if enable_help == %t then
            messagebox(["Synchronisation:" "Klicke auf den Fuß" "des ersten Kraftpeaks"])
        end
        
        plot2d(grfBalance.Fz)
        forceStart = locate(1)
        startBalance = int(forceStart(1))
        force_axes.title.text = "Waagenkraft senkrecht"
        
        // Determine initial Contact from Kinematic Data
        delete(gca())
        plot2d(ankle.y)
        force_axes = gca()
        force_axes.title.text = "Knöchel, Y-Koordinate bei v = " + body(i).name 
        
        if enable_help == %t then
            messagebox(["Synchronisation:" "Klicke auf initialen minimalen" "y-Wert der Hacke"])
        end
        
        startContact = locate(1)
        initialContact = floor(startContact(1))
        
        delete(gca())
        plot2d(toes.y)
        force_axes = gca()
        force_axes.title.text = "Zehen, Y-Koordinate bei v = " + body(i).name
        
        if enable_help == %t then
            messagebox(["Synchronisation:" "Klicke auf letzten minimalen" "y-Wert der Zehen"])
        end
        
        tmp = locate(1)
        liftOff = ceil(tmp(1))
     
        delete(force_window)
        
        center_of_balance = getCobValues()
        
        
        // Create Ground reaction force object
        grf.Fx = grfBalance.Fy(startBalance:2:$)
        grf.Fy = grfBalance.Fz(startBalance:2:$)
        grf.x = grfBalance.CoF_y(startBalance:2:$) + center_of_balance.x
        grf.y = center_of_balance.y
        
        
        // INVERSE KINETICS
        
        contactLength = liftOff - initialContact
        
        // Slice data that is needed for inverse kinetics to frames with ground contact
        
        foot.acc.x = foot.acc.x(initialContact: liftOff)
        foot.acc.y = foot.acc.y(initialContact: liftOff)
        foot.angacc = foot.angacc(initialContact : liftOff)
        foot.x = foot.x(initialContact : liftOff)
        foot.y = foot.y(initialContact : liftOff)
        ankle.x = ankle.x(initialContact : liftOff)
        ankle.y = ankle.y(initialContact : liftOff)
        
        leg.acc.x = leg.acc.x(initialContact : liftOff)
        leg.acc.y = leg.acc.y(initialContact : liftOff)
        leg.angacc = leg.angacc(initialContact : liftOff)
        leg.x = leg.x(initialContact : liftOff)
        leg.y = leg.y(initialContact : liftOff)
        knee.x = knee.x(initialContact : liftOff)
        knee.y = knee.y(initialContact : liftOff)
        
        thigh.acc.x = thigh.acc.x(initialContact : liftOff)
        thigh.acc.y = thigh.acc.y(initialContact : liftOff)
        thigh.angacc = thigh.angacc(initialContact : liftOff)
        thigh.x = thigh.x(initialContact : liftOff)
        thigh.y = thigh.y(initialContact : liftOff)
        hip.x = hip.x(initialContact : liftOff)
        hip.y = hip.y(initialContact : liftOff)
        
        // Iterate over ground contact duration
        for j = 1 : contactLength
            // Waagewerte Fy positiv, wenn positive Belastung
            // Waagenwerte Fx negativ, wenn Bremsen --> Umdrehen
            grf.Fx(j) = - grf.Fx(j)
            
            // Kräfte beim Einlesen umschreiben um Koordinatensystem anzupassen!
            
            // Calculate Joint forces and moments
            ankle.Fx(j) = foot.mass * foot.acc.x(j) - grf.Fx(j)
            ankle.Fy(j) = foot.mass * (foot.acc.y(j) - g) - grf.Fy(j)
            ankle.M(j) = foot.MoI * foot.angacc(j)...
                      - ankle.Fy(j) * (ankle.x(j) - foot.x(j)) - ankle.Fx(j) * (foot.y(j) - ankle.y(j))...
                      - grf.Fx(j) * ( foot.y(j) - grf.y ) - grf.Fy(j) * (grf.x(j) - foot.x(j))
                      
            //knee.Fx(j) = leg.mass * leg.acc.x(j) - ankle.Fx(j) * (-1)
            knee.Fx(j) = leg.mass * leg.acc.x(j) - ankle.Fx(j) * (-1)
            knee.Fy(j) = leg.mass * (leg.acc.y(j) - g) - ankle.Fy(j) * (-1)
            knee.M(j) = leg.MoI * leg.angacc(j) - ankle.M(j) * (-1)...
                     - knee.Fy(j) * (knee.x(j) - leg.x(j)) - knee.Fx(j) * (leg.y(j) - knee.y(j))...
                     - ankle.Fx(j) * (-1) * (leg.y(j) - ankle.y(j)) - ankle.Fy(j) * (-1) * (ankle.x(j) - leg.x(j))
                     
            hip.Fx(j) = thigh.mass * thigh.acc.x(j) - knee.Fx(j) * (-1)
            hip.Fy(j) = thigh.mass * (thigh.acc.y(j) - g) - knee.Fy(j) * (-1)
            hip.M(j) = thigh.MoI * thigh.angacc(j) - knee.M(j) * (-1)...
                     - hip.Fy(j) * (hip.x(j) - thigh.x(j)) - hip.Fx(j) * (thigh.y(j) - hip.y(j))...
                     - knee.Fx(j) * (-1) * (thigh.y(j) - knee.y(j)) - knee.Fy(j) * (-1) * (knee.x(j) - thigh.x(j))
                 
         end
         
         body(i).ankle.Fx = ankle.Fx
         body(i).ankle.Fy = ankle.Fy
         body(i).ankle.M = ankle.M
         
         body(i).knee.Fx = knee.Fx
         body(i).knee.Fy = knee.Fy
         body(i).knee.M = knee.M
         
         body(i).hip.Fx = hip.Fx
         body(i).hip.Fy = hip.Fy
         body(i).hip.M = hip.M
                 
//        force_window.visible = "on"
        
//        delete(gca())
        
        timesteps = contactLength
        time = linspace(0, 1, timesteps)
        
        sca(axes_results)
        clear_plot(axes_results)
        
        setAxes(gca(), "Belastungsdauer", 5, "Kraft [N]", 5);
        plot(time, ankle.Fy, 'r')
        plot(time, knee.Fy, 'b')
        plot(time, hip.Fy, 'g')
          
        legend("Knöchel", "Knie", "Hüfte")
        
        results_figure.visible = "on"
    end
endfunction
