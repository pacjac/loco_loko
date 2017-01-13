clear(); // Löschen aller Variablen
clearglobal(); // Löschen aller globalen Variablen

// Global window parameters
global margin_x margin_y;
global frame_w frame_h plot_w plot_h;

// Global data
global img_data
global toes ankle knee hip shoulder elbow hand neck;
global foot leg  thigh  leg_total  upperarm  forearm  arm_total  trunk;
global forces body;
global proband_mass DELTA_T g;
DELTA_T = 0.02; g = -9.81

// Global calibration
global voltageToForce scaleDrift;

// Global image handle
global axes_frame;

// Global files
global savedir caldir;
global forcefile imgfiles;
global cwd;

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
win_size = main_handle.figure_size;

axes_frame = newaxes(main_handle);
axes_frame.axes_bounds  = [0.2,0,0.8,1];
//axes_frame.axes_visible = ["off","off","off"];
axes_frame.tight_limits = "on";
axes_frame.auto_scale = "on";
axes_frame.Visible      = "on";
title("Video Sequence");
//Matplot(256);
//axes_frame.children(1).user_data = 'image';

results_figure = scf(999)
// Change dimensions of the figure
results_figure.axes_size = [axes_w axes_h]
results_figure.background      = -2;
results_figure.figure_position = [100 100];
results_figure.figure_name     = gettext("Ergebnisbild");
results_figure.visible        = "off";

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
    "callback"              ,"set_result_dir()");

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
    "callback"              ,"load_conveyorbelt_data()");
analyze_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Bilder analysieren"),...
    "callback"              ,"analzye_images()");
pendulum_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Pendel berechnen"),...
    "callback"              ,"calc_pendulum()");  
stickfig_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Stickplot"),...
    "callback"              ,"drawallthesticks()");   
    
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
    
inversekin_handle = uimenu(kinetik_handle,...
    "label"                 ,gettext("Inverse Kinetik"),...
    "callback"              ,"inverse_kinetic()");
    
    
    
// BUTTONS
// ================     
mass_text = uicontrol(main_handle,...
    "style"                  ,"pushbutton",...
    "string"                  ,gettext("Proband mass"),...
    "position"              ,[40,50,100,20],...
    "callback"              ,"getProbandMass()");
    
mass_entry = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"85",...
    "position"              ,[160, 50, 50, 20]);
    





function calc_pendulum()
    global savedir
    global imgfiles
    
    idealpendulum = []
    cycleTime = []
    frequency = []
    difference = []
    
    for i = 1 : size(imgfiles, 1)
        
        [toes, ankle, knee, hip, shoulder, elbow, hand, neck] = readFromMDF(imgfiles(i))
        [foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = createLimbs(toes, ankle, knee, hip, shoulder, elbow, hand, neck)
    
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

function plot_force_comparison()
    
endfunction

function set_result_dir()
    global savedir cwd;
    savedir = uigetdir(cwd + "../results/")
endfunction 
