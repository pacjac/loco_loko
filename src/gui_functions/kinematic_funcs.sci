function load_conveyorbelt_data()
    global toes ankle knee hip shoulder elbow hand neck;
    global foot leg thigh leg_total upperarm forearm arm_total trunk;
    global imgfiles
    imgfiles = uigetfile(["*.mdf", "Output from ImageJ"], cwd + "/../data/Laufen/felix/","Select CSV data",%t);
    
    [toes, ankle, knee, hip, shoulder, elbow, hand, neck] = readFromMDF(imgfiles(1))
    
    // Calculate speeds, acceleration, abs speed, abs acc, smoothed speed (double moving mean)n angle and 
    toes = anal(toes)
    ankle = anal(ankle)
    knee = anal(knee)
    hip = anal(hip)
    shoulder = anal(shoulder)
    elbow = anal(elbow)
    neck = anal(neck)
     
    foot = anal(foot)
    leg = anal(leg)
    thigh = anal(thigh)
    leg_total = anal(leg_total)
    upperarm = anal(upperarm)
    forearm = anal(forearm)
    arm_total = anal(arm_total)
    trunk = anal(trunk)
  
endfunction 

function load_image_data()
    global body
    global imgfiles
    imgfiles = uigetfile(["*.mdf", "Output from ImageJ"], cwd + "/../data/Laufen/felix/","Select CSV data",%t);
    
    for i = 1 : size(imgfiles, 2)
    
        [toes, ankle, knee, hip, shoulder, elbow, hand, neck] = readFromMDF(imgfiles(i))
        [foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = createLimbs(toes, ankle, knee, hip, shoulder, elbow, hand, neck)
        
        // Calculate speeds, acceleration, abs speed, abs acc, smoothed speed (double moving mean)n angle and 
        toes = anal(toes)
        ankle = anal(ankle)
        knee = anal(knee)
        hip = anal(hip)
        shoulder = anal(shoulder)
        elbow = anal(elbow)
        neck = anal(neck)
         
        foot = anal(foot)
        leg = anal(leg)
        thigh = anal(thigh)
        leg_total = anal(leg_total)
        upperarm = anal(upperarm)
        forearm = anal(forearm)
        arm_total = anal(arm_total)
        trunk = anal(trunk)
        
        body(i).toes = toes
        body(i).ankle = ankle
        body(i).knee = knee
        body(i).hip = hip
        body(i).shoulder = shoulder
        body(i).elbow = elbow
        body(i).neck = neck
        body(i).foot = foot
        body(i).leg = leg
        body(i).thigh = thigh
        body(i).leg_total = leg_total
        body(i).upperarm = upperarm
        body(i).forearm = forearm
        body(i).arm_total = arm_total
        body(i).trunk = trunk
        
        tmp = tokens(imgfiles(i), ['/','.'])
        body(i).name = tmp($ - 1)
    end
endfunction 
    
function setCurrentBody(body)
    global toes ankle knee hip shoulder elbow hand neck;
    global foot leg thigh leg_total upperarm forearm arm_total trunk;
    
    toes = body.toes
    ankle = body.ankle
    knee = body.knee
    hip = body.hip
    shoulder = body.shoulder
    elbow = body.elbow
    neck = body.neck
    foot = body.foot
    leg = body.leg
    thigh = body.thigh
    leg_total = body.leg_total
    upperarm = body.upperarm
    forerarm = body.forearm
    arm_total = body.forearm
    trunk = body.trunk
    
endfunction

function analzye_images()
    global toes ankle knee hip shoulder elbow hand neck;
    global foot leg thigh leg_total upperarm forearm arm_total trunk;
    
    [foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = createLimbs(toes, ankle, knee, hip, shoulder, elbow, hand, neck)
    
    // Calculate speeds, acceleration, abs speed, abs acc, smoothed speed (double moving mean)n angle and 
    toes = anal(toes)
    ankle = anal(ankle)
    knee = anal(knee)
    hip = anal(hip)
    shoulder = anal(shoulder)
    elbow = anal(elbow)
    neck = anal(neck)
     
    foot = anal(foot)
    leg = anal(leg)
    thigh = anal(thigh)
    leg_total = anal(leg_total)
    upperarm = anal(upperarm)
    forearm = anal(forearm)
    arm_total = anal(arm_total)
    trunk = anal(trunk)
    
endfunction
