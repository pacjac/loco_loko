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
global proband_mass pix_to_m;
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

// Global helpmessages
global enable_help;
enable_help = %f;

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
main_handle.axes_size       = [axes_w axes_h]
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
results_figure
results_figure.background       = -2;
results_figure.figure_position  = [100 100];
results_figure.figure_name      = gettext("Ergebnisbild");
results_figure.visible          = "off";

axes_results = newaxes(results_figure);
axes_results.axes_bounds = [0, 0, 1, 1]
axes_results.auto_scale = "on";
axes_results.tight_limits = "on";


// Remove Scilab graphics menus & toolbar
delmenu(main_handle.figure_id,gettext("&File"));
delmenu(main_handle.figure_id,gettext("&Tools"));
delmenu(main_handle.figure_id,gettext("&Edit"));
delmenu(main_handle.figure_id,gettext("&?"));
toolbar(main_handle.figure_id,"off");

my_frame = uicontrol(main_handle,... 
    "relief"                ,"groove", ... 
    "style"                 ,"frame",... 
    "units"                 ,"pixels", ...
    "position",             [ margin_x margin_y frame_w frame_h], ... 
    "horizontalalignment"   ,"center",...
    "background"            ,[1 1 1], ... 
    "tag",                  "frame_control");

my_frame_title = uicontrol(main_handle,... 
    "style"                 ,"text", ... 
    "string"                ,"Benutzereingaben",... 
    "units"                 ,"pixels", ... 
    "position"              ,[30+margin_x margin_y+frame_h-10 frame_w-60 20],...
    "fontname"              ,defaultfont,... 
    "fontunits"             ,"points", ...
    "fontsize"              ,16,... 
    "horizontalalignment"   ,"center", ...
    "background"            ,[1 1 1],... 
    "tag"                   ,"title_frame_control");

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
    "callback"              ,"load_image_data()");
pendulum_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Pendel berechnen"),...
    "callback"              ,"calc_pendulum()");  
dutyfactor_handle = uimenu(kinematik_handle,...
    "label"                 ,gettext("Dutyfactor berechnen"),...
    "callback"              ,"writeDutyFactor()");  
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
    
// KINETIC MENU
// ================     
help_handle = uimenu(main_handle,...
    "label"                 ,gettext("Hilfe"));    
help_dialogue_handle = uimenu(help_handle,...
    "label"                 ,gettext("Hilfe (de)aktivieren"),...
    "callback"              ,"toggle_help()");
    
    
    
    
// BUTTONS
// ================     

offset = frame_h

// PROBAND MASS
mass_text = uicontrol(main_handle,...
    "style"                  ,"text",...
    "background"            ,[1 1 1],... 
    "string"                  ,gettext("Proband mass"),...
    "position"              ,[20,offset - 30,100,20]);
    
mass_entry = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"85",...
    "position"              ,[140, offset - 30, 50, 20]);
    
// Calibration 
conversion_text = uicontrol(main_handle,...
    "style"                  ,"text",...
    "background"            ,[1 1 1],... 
    "string"                  ,gettext("pix / m"),...
    "position"              ,[20, offset - 60, 120, 20]);
    
conversion_value = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"227",...
    "position"              ,[140, offset - 60, 90, 20]);
    
    
// Calibration 
cob_text = uicontrol(main_handle,...
    "style"                  ,"text",...
    "background"            ,[1 1 1],... 
    "string"                  ,gettext("balance center"),...
    "position"              ,[20, offset - 90, 120, 20]);
    
cob_value = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"1.878, 0.13",...
    "position"              ,[140, offset - 90, 90, 20]);
    
// SAVE FIGURE
save_button = uicontrol(main_handle,...
    "style"                  ,"pushbutton",...
    "string"                  ,gettext("Save figure"),...
    "position"              ,[20, offset - 200, 70, 20],...
    "callback"              ,"save_result_fig()");
    
save_entry = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"figure_name",...
    "position"              ,[140, offset - 200, 90, 20]);
    
// PLOT CONTROL
plot_text = uicontrol(main_handle,...
    "style"                  ,"text",...
    "background"            ,[1 1 1],... 
    "string"                  ,gettext("Enter joint"),...
    "position"              ,[20, offset - 230, 120, 20]);
    
plot_entry = uicontrol(main_handle,...
    "style"                  ,"edit",...
    "string"                ,"knee",...
    "position"              ,[140, offset - 230, 90, 20]);

   
// RESCALE
rescale_button = uicontrol(main_handle,...
    "style"                  ,"pushbutton",...
    "string"                  ,gettext("Rescale plots"),...
    "position"              ,[20, offset - 260, 120, 20],...
    "callback"              ,"scalePlotAxes(gca())");   
   


function strideLength()
    global body;
    global savedir;
    
    if savedir == [] then
        messagebox("Wir brauchen einen Ergebnisordner!");
    else
        for i = 1 : size(body, 1)
            xmin = min(body(i).toes.x)
            xmax = max(body(i).toes.x)
            strideLength(i) = xmax - xmin
        end
        
        fprintfMat(savedir + "/stridelength.txt",...
                strideLength);
    end
    
endfunction

function stride = getstrideLength()
    global body;
    
    
    for i = 1 : size(body, 1)
        xmin = min(body(i).toes.x)
        xmax = max(body(i).toes.x)
        stride(i) = xmax - xmin
    end
    
endfunction

function proband_mass = getProbandMass()
    global proband_mass
    proband_mass = strtod(mass_entry.string)
endfunction

function pix_to_m = getPixToM()
    global pix_to_m
    pix_to_m = strtod(conversion_value.string)
endfunction

function plotFrequencyduo()

    frequency = [0.47, 0.66, 0.72, 0.86, 0.9, 1.02, 1.04]
    
    sl = [ 0.3703012, 0.4992139, 0.6884489, 0.7507958, 0.8522696, 0.8777071, 0.966458] 
    
    clf() 
    
    plot(speed, sl,"b") 
    a=gca(); 
    b = newaxes(); 
    b.y_location = "right"; 
    b.filled = "off"; 
    b.axes_visible = ["off","on","on"]; 
    b.axes_bounds = a.axes_bounds; 
    b.font_size = a.font_size; 
    plot(speed, frequency,"g") 
    a.y_label.text = "Schrittweite [m]"
    a.x_label.text = "Geschwindigkeit [km/h]"
    b.y_label.text = "Schrittfrequenz [Hz]"
endfunction

function calcNeckSpeed()
    global body;
    for i = 1 : 3
        speed = mean(body(i).neck.speed.x);
        body(i).speed = speed;
    end
endfunction

