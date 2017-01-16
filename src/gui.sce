clear(); // Löschen aller Variablen
clearglobal(); // Löschen aller globalen Variablen

// Global window parameters
global margin_x margin_y;
global frame_w frame_h plot_w plot_h;

// Global data
//global img_data
//global toes ankle knee hip shoulder elbow hand neck;
//global foot leg  thigh  leg_total  upperarm  forearm  arm_total  trunk;
global forces body;
global proband_mass;
global DELTA_T g;
DELTA_T = 0.02; g = -9.81

// Global calibration
global voltageToForce scaleDrift;

// Global image handle
global axes_frame;
global results_fig;

// Global files
global savedir caldir;
global forcefile imgfiles;

cwd = get_absolute_file_path('gui.sce')
getd(cwd + "/base_functions");
getd(cwd + "/gui_functions");
//getd(cwd);


// Window Parameters initialization
// Frame width and height
frame_w = 300; 
frame_h = 550;
// Plot width and heigh 
margin_x = 15; margin_y = 15;// Horizontal and vertical margin for elements
plot_w = 600; 
plot_h = frame_h;
defaultfont = "arial"; // Default Font
axes_w = 3*margin_x + frame_w + plot_w;// axes width
axes_h = 2*margin_y + frame_h; // axes height (100 => toolbar height)


main_handle = scf(100001);// Create window with id=100001 and make it the current one

// Background and text
main_handle.background      = -2;
main_handle.figure_position = [100 100];
main_handle.figure_name     = gettext("Lokomotion Auswertung");
main_handle.tag             = "main";
win_size = main_handle.figure_size;

axes_frame = newaxes(main_handle);
axes_frame.axes_bounds  = [0.2,0,0.8,1];
axes_frame.tight_limits = "on";
axes_frame.auto_scale = "on";
axes_frame.Visible      = "on";
title("Working frame");


results_figure = scf(999)

// Change dimensions of the figure
results_figure.axes_size        = [axes_w axes_h]
results_figure.background       = -2;
results_figure.figure_position  = [100 100];
results_figure.figure_name      = gettext("Ergebnisbild");
results_figure.visible          = "off";

axes_results = newaxes(results_figure);
axes_results.axes_bounds = [0, 0, 1, 1]
axes_results.auto_scale = "on";
axes_results.tight_limits = "on";
//axes_results.visible = "off";


// Remove Scilab graphics menus & toolbar
delmenu(main_handle.figure_id,gettext("&File"));
delmenu(main_handle.figure_id,gettext("&Tools"));
delmenu(main_handle.figure_id,gettext("&Edit"));
delmenu(main_handle.figure_id,gettext("&?"));
toolbar(main_handle.figure_id,"off");

// FILE MENU
// ================
file_handle = uimenu(main_handle,...
    "label"                 ,gettext("File"));
        
resultdir_handle = uimenu(file_handle,...
    "label"                 ,gettext("Ergebnisordner setzen"),...
    "callback"              ,"set_result_dir(cwd)");
    
save_handle = uimenu(file_handle,...
    "label"                 ,gettext("Session speichern"),...
    "callback"              ,"savesession()");
    
load_handle = uimenu(file_handle,...
    "label"                 ,gettext("Session laden"),...
    "callback"              ,"loadsession()");
    
cleardata_handle = uimenu(file_handle,...
    "label"                 ,gettext("Bild und Kraftdaten löschen"),...
    "callback"              ,"clearData()");

// CALIBRATION MENU
// ================
calibration_handle = uimenu(main_handle,...
    "label"                 ,gettext("Kalibration"));
        
calibrate_handle = uimenu(calibration_handle,...
    "label"                 ,gettext("Kalibrieren"),...
    "callback"              ,"calibrate()");
    
calload_handle = uimenu(calibration_handle,...
    "label"                 ,gettext("Kalibration laden"),...
    "callback"              ,"load_calibration()");

// KINEMATIC MENU
// ================    
kinematik_handle = uimenu(main_handle,...
    "label"                 ,gettext("Kinematik"));    
imgseq_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Bildsequenz laden"),...
    "callback"              ,"load_image_data(strtod(conversion_value.string))");
pendulum_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Pendel berechnen"),...
    "callback"              ,"calc_pendulum()");  
stickfig_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Stickplot"),...
    "callback"              ,"drawallthesticks()");  
body_axis_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Körperachse plotten"),...
    "callback"              ,"plot_body_axis()");  
arm_swing_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Armbewegung plotten"),...
    "callback"              ,"plot_arm_schwung()");  
    
    
    
// KINETIC MENU
// ================     
kinetik_handle = uimenu(main_handle,...
    "label"                 ,gettext("Kinetik"));    
force_handle = uimenu(kinetik_handle,...
    "label"                 ,gettext("Kraftfiles laden"),...
    "callback"              ,"calc_forces()");
plot_handle = uimenu(kinetik_handle,...
    "label"                 ,gettext("Kräfte plotten"),...
    "callback"              ,"plot_forces()");
    
inversedyn_handle = uimenu(kinetik_handle,...
    "label"                 ,gettext("Inverse Dynamik"));
    
calc_dynamic_handle = uimenu(inversedyn_handle,...
    "label"                 ,gettext("Kräfte berechnen"),...
    "callback"              ,"inverse_kinetic()");
    
plot_dynamic_handle = uimenu(inversedyn_handle,...
    "label"                 ,gettext("Kräfte in Gelenk berechnen"),...
    "callback"              ,"plot_forces_limb(plot_entry.string)");
    
    
    
// BUTTONS
// ================     

// PROBAND MASS
mass_text = uicontrol(main_handle,...
    "style"                  ,"text",...
    "string"                  ,gettext("Proband mass"),...
    "position"              ,[20,50,100,20]);
    
mass_entry = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"85",...
    "position"              ,[140, 50, 50, 20]);
    
// SAVE FIGURE
save_button = uicontrol(main_handle,...
    "style"                  ,"pushbutton",...
    "string"                  ,gettext("Save figure"),...
    "position"              ,[20, 400, 70, 20],...
    "callback"              ,"save_result_fig()");
    
save_entry = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"figure_name",...
    "position"              ,[110, 400, 90, 20]);
    
// PLOT CONTROL
plot_text = uicontrol(main_handle,...
    "style"                  ,"text",...
    "string"                  ,gettext("Enter joint"),...
    "position"              ,[20, 360, 120, 20]);
    
plot_entry = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"joint_name",...
    "position"              ,[110, 360, 90, 20]);
// Calibration 
conversion_text = uicontrol(main_handle,...
    "style"                  ,"text",...
    "string"                  ,gettext("pix / m"),...
    "position"              ,[20, 320, 120, 20]);
    
conversion_value = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"227",...
    "position"              ,[110, 320, 90, 20]);
   
// HEEL ANGLE
rescale_button = uicontrol(main_handle,...
    "style"                  ,"pushbutton",...
    "string"                  ,gettext("Rescale plots"),...
    "position"              ,[20, 280, 120, 20],...
    "callback"              ,"scalePlotAxes(gca())");   
   
    
//// HEEL DISTANCE
//heel_length_text = uicontrol(main_handle,...
//    "style"                  ,"text",...
//    "string"                  ,gettext("foot base in m"),...
//    "position"              ,[20, 320, 120, 20]);
//    
//heel_distance = uicontrol(main_handle,...
//    "style"                  ,"edit",...
//    "string"                ,"0.2",...
//    "position"              ,[110, 320, 90, 20]);
//    
//// HEEL ANGLE
//heel_angle_text = uicontrol(main_handle,...
//    "style"                  ,"text",...
//    "string"                  ,gettext("heel angle"),...
//    "position"              ,[20, 280, 120, 20]);
//    
//heel_angle = uicontrol(main_handle,...
//    "style"                  ,"edit",...
//    "string"                ,"15",...
//    "position"              ,[110, 280, 90, 20]);




function save_result_fig()
    global results_figure savedir;
    name = save_entry.string
    savestring = savedir + "/" + name + ".pdf"
    figure_id = results_figure.figure_id
    xs2pdf(figure_id, savestring)
endfunction




function plot_force_comparison()
    
endfunction

function set_result_dir(cwd)
    global savedir cwd;
    savedir = uigetdir(cwd + "../results/")
endfunction 

function getProbandMass()
    global proband_mass
    proband_mass = strtod(mass_entry.string)
endfunction

function plot_forces_limb(limb_name)
    global body forces;
    global results_figure;
    
    styles = [-1, -2, -3]
    
    sca(axes_results)
    clear_plot(axes_results)
    
    
    execstr("limb = body(1)." + limb_name)        
    time = linspace(0, 1, length(limb.Fx))
    plot(time, limb.Fx, 'r')
    plot(time , limb.Fy, 'b')
    plot(time, limb.M, 'g')
    name = body(1).name + " " + limb_name
    legend(name + " Fx", name + " Fy", name + " M")
        
    results_figure.visible = "on";
endfunction





function [dutyFactor, contactDuration, cycleDuration] = calcDutyFactor(body, tolerance)
    ankle = body.ankle
    toes = body.toes
    
    threshold_ankle = min(ankle.y) + tolerance;
    threshold_toes = min(toes.y) + tolerance;
    
    all_img = size(ankle.y, 1)
    
    initialContactFound = %f
    liftOffFound = %f
    initialContact = 0
    liftOff = 0
    for i = 1 : all_img
        if ankle.y(i) < threshold_ankle & initialContactFound == %f then
            initialContact = i
            initialContactFound = %t
        elseif toes.y(i) > threshold_toes & initialContactFound == %t & liftOffFound == %f then
            liftOff = i
            liftOffFound = %t
        elseif ankle.y(i) < threshold_ankle & initialContactFound == %t & liftOffFound == %t then
            nextContact = i
        end
    end
    
    contactDuration = liftOff - initialContact;
    cycleDuration = nextContact -initialContact
    
    dutyFactor = contactDuration / cycleDuration
endfunction

calcDutyFactor(body(1), 0.02)
