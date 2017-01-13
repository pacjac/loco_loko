function calc_forces()
    global voltageToForce scaleDrift forces forcefile
    forcefile = uigetfile(["*.*", "Force files"], cwd + "/../data/Waage/","Select force data",%t)
    
   
    for i = 1 : size(forcefile, 2)
        forceRaw = readScaleFile(forcefile(i));
        force_sum = combineChannels(forceRaw, 2.5)
        force_smooth = calculateForces(force_sum, scaleDrift, voltageToForce)
        forces(i) = force_smooth // this shit doesnt work
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
    
    global toes ankle knee hip shoulder elbow hand neck;
    global foot leg  thigh  leg_total  upperarm  forearm  arm_total  trunk;
    global forces
    global g
    global axes_frame
    
    for i = 1 : size(forces, 1)
    
        grfBalance = forces(i)
        // Determine initial Contact from force Data
        force_window = scf(100)
        plot2d(grfBalance.Fz)
        forceStart = locate(1)
        startBalance = int(forceStart(1))
        
        // Determine initial Contact from Kinematic Data
        delete(gca())
        plot2d(ankle.y)
        startContact = locate(1)
        initialContact = int(startContact(1))
 
 //     force_window.visible = "off"       
        delete(force_window)
        
       
        
        // Create Ground reaction force object
        grf.Fx = grfBalance.Fy(startBalance:2:$)
        grf.Fy = grfBalance.Fz(startBalance:2:$)
        grf.x = grfBalance.CoF_y(startBalance:2:$)
        grf.y = 1.5
        
        
        // INVERSE KINETICS
        
        liftOff = size(foot.x, 1)
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
        for i = 1 : contactLength
            grf.Fx(i) = - grf.Fx(i)
            
            // Kräfte beim Einlesen umschreiben um Koordinatensystem anzupassen!
            
            // Calculate Joint forces and moments
            ankle.Fx(i) = foot.mass * foot.acc.x(i) - grf.Fx(i)
            ankle.Fy(i) = foot.mass * (foot.acc.y(i) + g) + grf.Fy(i)
            ankle.M(i) = foot.MoI * foot.angacc(i) - ankle.Fy(i) * (ankle.x(i) - foot.x(i)) ...
                      - ankle.Fx(i) * (foot.y(i) - ankle.y(i)) - grf.Fx(i) * ( foot.y(i) - grf.y ) - grf.Fy(i) * (grf.x(i) - foot.x(i))
                      
            //knee.Fx(i) = leg.mass * leg.acc.x(i) - ankle.Fx(i) * (-1)
            knee.Fx(i) = leg.mass * leg.acc.x(i) - ankle.Fx(i) * (-1)
            knee.Fy(i) = leg.mass * (leg.acc.y(i) + g) + ankle.Fy(i)
            knee.M(i) = ankle.M(i) + leg.MoI * leg.angacc(i) - knee.Fy(i) * (knee.x(i) - leg.x(i))...
                     - knee.Fx(i) * (leg.y(i) - knee.y(i)) + ankle.Fx(i) * (leg.y(i) - ankle.y(i)) + ankle.Fy(i) * (ankle.x(i) - leg.y(i))
                     
            hip.Fx(i) = thigh.mass * thigh.acc.x(i) + knee.Fx(i)
            hip.Fy(i) = thigh.mass * (thigh.acc.y(i) + g) + knee.Fy(i)
            hip.M(i) = knee.M(i) + thigh.MoI * thigh.angacc(i) - hip.Fy(i) * (hip.x(i) - thigh.x(i))...
                     - hip.Fx(i) * (thigh.y(i) - hip.y(i)) + knee.Fx(i) * (thigh.y(i) - knee.y(i)) + knee.Fy(i) * (knee.x(i) - thigh.y(i))
                 
         end
                 
//        force_window.visible = "on"
        
//        delete(gca())
        
        timesteps = contactLength
        time = linspace(0, 1, timesteps)
        
        sca(axes_frame)
        clear_plot()
        setAxes(gca(), "Belastungsdauer", 5, "Kraft [N]", 5);
        plot2d(time, [ankle.Fy, knee.Fy, hip.Fy, shoulder.Fy, elbow.Fy],... 
                style = [color("red"), color("green"), color("blue"), color("orange"), color("purple")])
        legend("Knöchel", "Knie", "Hüfte", "Schulter", "Ellenbogen")
    end
endfunction
