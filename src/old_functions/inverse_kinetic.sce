clear(); // Löschen aller Variablen
clearglobal(); // Löschen aller globalen Variablen

// Set up working variables
global PI
PI = 3.1415
global DELTA_T
DELTA_T = 0.02
global g
g = 9.81

// Set up proband varibales
proband_mass = 85

// Current working directory, load all functions from .sci filess
cwd = get_absolute_file_path('inverse_kinetic.sce')
getd(cwd);

// GET DATA PATH
data_path = uigetfile(["*.mdf", "Output from ImageJ"], cwd + "/../data/Laufen/felix/","Select CSV data",%t);



for i = 1 : size(data_path, 2)

    // READ DATA
    
    [toes, ankle, knee, hip, shoulder, elbow, hand, neck] = readFromMDF(data_path(i))
    
    [foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = createLimbs(toes, ankle, knee, hip, shoulder, elbow, hand, neck)
    
       
    // ANALYZE DATA
    
    // Calculate speeds, acceleration, abs speed, abs acc, smoothed speed (double moving mean)n angle and 
    foot = anal(foot)
    leg = anal(leg)
    thigh = anal(thigh)
    leg_total = anal(leg_total)
    upperarm = anal(upperarm)
    forearm = anal(forearm)
    arm_total = anal(arm_total)
    
    // Create Container for iteration
    //limbs = [foot, leg, thigh, leg_total, upperarm, forearm, arm_total]
    
    // Calculate ground reaction force
    
    Waage.x = 2.0
    Waage.y = 0.23
    
    
    a = 0.03
    b = 0.0575
    CoB = b
    CoBx = 1.5
    
    // GET CALIBRATION AND FORCE MEASUREMENTS
    
    caldir = uigetdir(cwd + "../data/", "Select Calibration Directory")
    forcefile = uigetfile("*.*", cwd + "../data/", "Select force measurement",%t)
    
    //forcefile = cwd + "../data/Waage/felix/schnell.txt"
    //caldir = cwd + "../data/Waage/Kalibrierung/"
    
    
    
    driftfile = caldir + '/Waagendrift_clean.txt';
    offsetDataRaw = readScaleFile(driftfile);
    xCalFile = caldir + '/XKali_clean.txt';
    xCalRaw = readScaleFile(xCalFile)
    yCalFile = caldir + '/YKali_clean.txt';
    yCalRaw = readScaleFile(yCalFile);
    zCalFile = caldir + '/ZKali_clean.txt';
    zCalRaw = readScaleFile(zCalFile);
    
    grfRaw = readScaleFile(forcefile)
    
    
    offsetData = combineChannels(offsetDataRaw, b, CoB)
    xCal = combineChannels(xCalRaw, b, CoB)
    yCal = combineChannels(yCalRaw, b, CoB)
    zCal = combineChannels(zCalRaw, b, CoB)
    grfRaw = combineChannels(grfRaw, b, CoB)
    
    scaledrift = calcScaleDrift(offsetData)
    voltageToForce = convertVoltageToForce(xCal, yCal, zCal)
    
    grfBalance = calculateForces(grfRaw, scaledrift, voltageToForce)
    
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
    
    force_window.visible = "off"
    
    
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

        
        // Calculate Joint forces and moments
        ankle.Fx(i) = foot.mass * foot.acc.x(i) + grf.Fx(i)
        ankle.Fy(i) = foot.mass * (foot.acc.y(i) - g) + grf.Fy(i)
        ankle.M(i) = foot.MoI * foot.angacc(i) - ankle.Fy(i) * (ankle.x(i) - foot.x(i)) ...
                  - ankle.Fx(i) * (foot.y(i) - ankle.y(i)) - grf.Fx(i) * ( foot.y(i) - grf.y ) - grf.Fy(i) * (grf.x(i) - foot.x(i))
                  
                  
        knee.Fx(i) = leg.mass * leg.acc.x(i) + ankle.Fx(i)
        knee.Fy(i) = leg.mass * (leg.acc.y(i) - g) + ankle.Fy(i)
        knee.M(i) = ankle.M(i) + leg.MoI * leg.angacc(i) - knee.Fy(i) * (knee.x(i) - leg.x(i))...
                 - knee.Fx(i) * (leg.y(i) - knee.y(i)) + ankle.Fx(i) * (leg.y(i) - ankle.y(i)) + ankle.Fy(i) * (ankle.x(i) - leg.y(i))
                 
        hip.Fx(i) = thigh.mass * thigh.acc.x(i) + knee.Fx(i)
        hip.Fy(i) = thigh.mass * (thigh.acc.y(i) - g) + knee.Fy(i)
        hip.M(i) = knee.M(i) + thigh.MoI * thigh.angacc(i) - hip.Fy(i) * (hip.x(i) - thigh.x(i))...
                 - hip.Fx(i) * (thigh.y(i) - hip.y(i)) + knee.Fx(i) * (thigh.y(i) - knee.y(i)) + knee.Fy(i) * (knee.x(i) - thigh.y(i))
     end
             
    force_window.visible = "on"
    
    delete(gca())
    
    plot(ankle.Fy, "r")
    plot(knee.Fy, "b")
    plot(hip.Fy, "g")
    legend("Knöchel", "Knie", "Hüfte")
    
end
