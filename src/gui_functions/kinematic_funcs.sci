function load_image_data(pix_to_m)
    // Set result global
    global body
    
    imgfiles = uigetfile(["*.mdf", "Output from ImageJ"], cwd + "/../data/Laufen/felix/","Select CSV data",%t);
    
    for i = 1 : size(imgfiles, 2)
        
        // Read mass data from field
        getProbandMass();
    
        [toes, ankle, knee, hip, shoulder, elbow, hand, neck] = readFromMDF(imgfiles(i), pix_to_m)
        
        [foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = createLimbs(toes, ankle, knee, hip, shoulder, elbow, hand, neck)
        
//        heel = calcHeel(foot, toes, strtod(heel_distance.string), strtod(heel_angle.string))
        
        // Calculate speeds, acceleration, abs speed, abs acc, smoothed speed (double moving mean)n angle and 
        toes = anal(toes)
        ankle = anal(ankle)
        knee = anal(knee)
        hip = anal(hip)
        shoulder = anal(shoulder)
        elbow = anal(elbow)
        hand = anal(hand)
        neck = anal(neck)
         
        foot = anal(foot)
        leg = anal(leg)
        thigh = anal(thigh)
        leg_total = anal(leg_total)
        upperarm = anal(upperarm)
        forearm = anal(forearm)
        arm_total = anal(arm_total)
        trunk = anal(trunk)
        
        index = size(body, 1) + 1
        
        body(index).toes = toes
        body(index).ankle = ankle
        body(index).knee = knee
        body(index).hip = hip
        body(index).shoulder = shoulder
        body(index).elbow = elbow
        body(index).hand = hand
        body(index).neck = neck
        
        body(index).foot = foot
        body(index).leg = leg
        body(index).thigh = thigh
        body(index).leg_total = leg_total
        body(index).upperarm = upperarm
        body(index).forearm = forearm
        body(index).arm_total = arm_total
        body(index).trunk = trunk
        
        tmp = tokens(imgfiles(i), ['/','.'])
        body(index).name = tmp($ - 1)
    end
    
endfunction 
    
function [toes, ankle, knee, hip, shoulder, elbow, hand, neck, foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = setCurrentBody(body)
        
    // If function uses old syntax, get limb data from body container
    toes = body.toes
    ankle = body.ankle
    knee = body.knee
    hip = body.hip
    shoulder = body.shoulder
    elbow = body.elbow
    hand = body.hand
    neck = body.neck
    foot = body.foot
    leg = body.leg
    thigh = body.thigh
    leg_total = body.leg_total
    upperarm = body.upperarm
    forearm = body.forearm
    arm_total = body.forearm
    trunk = body.trunk
    
endfunction



function calc_pendulum()
    global savedir
    global body
    
    idealpendulum = []
    cycleTime = []
    frequency = []
    difference = []
    
    for i = 1 : size(body, 1)
        
        [toes, ankle, knee, hip, shoulder, elbow, hand, neck, foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = setCurrentBody(body(i))
    
        timesteps = size(ankle.x, 1)
        
        Cycle_T = timesteps * DELTA_T
        Pendulum_T = 2 * PI * sqrt(mean(GetLimbLength(leg_total, hip)) / 9.81)
    
        idealpendulum(i) = Pendulum_T
        cycleTime(i) = Cycle_T
        frequency(i) = 1 / Cycle_T
        difference(i) = Pendulum_T / Cycle_T * 100 - 100
    end
    
    fprintfMat(savedir + "/pendulum.txt",...
           [idealpendulum, cycleTime, frequency, difference],...
           "%5.2f",...
           "Idealpendel_T Beinpendel_T Beinpendel_f rel_diff");

endfunction

