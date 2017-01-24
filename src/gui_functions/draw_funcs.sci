function setAxes(axes, xLabel, xFontSize, yLabel, yFontSize)
    axes.x_label.text = xLabel;
    axes.x_label.font_size = xFontSize;
    axes.y_label.text = yLabel;
    axes.y_label.font_size = yFontSize; 
endfunction

function scalePlotAxes(axes)
    j = 1 
    for i = 1 : size(axes.children, 1)
        if axes.children(i).type == 'Compound' then
            data = axes.children(i).children.data
            all_xmin(j) = min(data(:,1));
            all_xmax(j) = max(data(:,1));
            all_ymin(j) = min(data(:,2));
            all_ymax(j) = max(data(:,2));
            j = j + 1;
        end
    end
    xmin = min(all_xmin)
    xmax = max(all_xmax)
    ymin = min(all_ymin)
    ymax = max(all_ymax)
    axes.data_bounds = [xmin, ymin; xmax, ymax]
endfunction

function rescaleplots()
    scalePlotAxes(axes_frame)
    scalePlotAxes(results_frame)
endfunction

function clear_plot(axes)
    index = 1
    while (index <= size(axes.children, 1))
        if axes.children(index).type == 'Compound' | axes.children(index).type == 'Legend' then 
            delete(axes.children(index));
            else index = index + 1;
            end
    end
endfunction

function drawallthesticks(body, speed)
    global axes_results results_figure
    
    sca(axes_results);
    clear_plot(axes_results);
    
    // Calculate offset for Conveyor belt
    // deltaX = v [kmh] / 3.6 * deltaT
    offset = speed / 3.6 * 0.02;
    
    [toes, ankle, knee, hip, shoulder, elbow, hand, neck, foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = setCurrentBody(body)

    num_of_images = size(toes.x,1)
    snapshots = 20
    inkrement = floor(num_of_images / snapshots)
    
    for i = 1 : inkrement : num_of_images
        data_tmp1 = [...
        toes.x(i) + offset * i, toes.y(i);...
        ankle.x(i) + offset * i, ankle.y(i);...
        knee.x(i) + offset* i, knee.y(i);...
        hip.x(i) + offset* i, hip.y(i);...
        neck.x(i) + offset * i, neck.y(i)];
        
        data_tmp2 = [...
        shoulder.x(i) + offset* i, shoulder.y(i);...
        elbow.x(i) + offset* i, elbow.y(i);...
        hand.x(i) + offset * i, hand.y(i)];
        
        plot(data_tmp1(:,1), data_tmp1(:,2), 'b')
        plot(data_tmp2(:,1), data_tmp2(:,2), 'r')
        
    end
    
    results_figure.visible = "on"
endfunction


function plot_forces()
    // figures to work with
    global results_figure axes_frame;
    // data to work with 
    global forces forcefile;
    
    colors = [color("red"), color("blue"), color("green")];
    
    // Work on main frame
    sca(axes_frame)
    clear_plot(axes_frame)
    setAxes(gca(), "Messungen", 5, "Kraft [N]", 5);
    axes_frame.title.text = "Kraft beginn und Ende auswählen"
    
    for i = 1 : size(forces, 1)
        // Work on working frame
        scf(main_handle)
        sca(axes_frame)
        force = forces(i)
        
        // Plot complete force
        plot2d(force.Fz)
        
        tmp = int(locate(2))
        begin_plot = tmp(1,1)
        end_plot = tmp(1,2)
        clear_plot(axes_frame)
        
        
        // Create Plot variables
        time = linspace(0, 1, end_plot - begin_plot + 1)
        cutforces = force.Fz(begin_plot:end_plot, 1)
        
        // Change to results frame
        scf(results_figure)
        sca(axes_results)
        
        leg(i) = forces(i).name
        
        // Plot result = cut force
        plot2d(time, cutforces, style = [colors(i)])
        
    end
    
    // Clear working frame
    axes_frame.title.text = ""
    clear_plot(axes_frame)
    
    // Show results frame
    results_figure.visible = "on";
    setAxes(gca(), "Kontaktzeit", 5, "Kraft [N]", 5);
    legend(leg)
    //axes_frame.title.visible = "off"
    
    
endfunction




function plot_body_axis()
    global body;
    global axes_frame results_figure axes_results;
    
    styles = [':r', 'xg', ':b', '--k', '-.m', ':c', '--b']

    sca(axes_results)
    clear_plot(axes_results)
    
    for i = 1 : size(body, 1)
        
        body_axis_angle = body(i).trunk.angle * 180 / %pi
        
        
        
        // Create Plot variables
        time = linspace(0, 1, length(body_axis_angle))
        plot(time, body_axis_angle, styles(i))
        leg(i) = body(i).name
           
    end
    
    setAxes(axes_results, "Schrittzyklus", 5, "Winkel in Grad", 5)
     
    legend(leg)
    
    results_figure.visible = "on"
   
endfunction

function plot_arm_schwung()
    global body;
    global axes_frame results_figure axes_results;
    
    styles = [':r', 'xg', ':b', '--k', '-.m', ':c', '--b']
    
    sca(axes_results)
    clear_plot(axes_results)
    
    for i = 1 : size(body, 1)
        rel_hand.x = body(i).hand.x - body(i).neck.x
        rel_hand.y = body(i).hand.y - body(i).neck.y
        
        plot(rel_hand.x, rel_hand.y, styles(i))
        leg(i) = body(i).name
    end
    
    
    setAxes(axes_results, "X", 5, "Y", 5)
     
    legend(leg)
    
    results_figure.visible = "on"
endfunction


function plot_armAmplitude()
    global body;
    global axes_frame results_figure axes_results;
    
    styles = [':r', 'xg', ':b', '--k', '-.m', ':c', '--b'];
    
    sca(axes_results);
    clear_plot(axes_results);
    
    for i = 1 : size(body, 1)
        time = linspace(0, 1, size(body(i).arm_total.angle, 1));  
        angle = (body(i).arm_total.angle * 180 / %pi - 90) * (-1)      
        plot(time, angle, styles(i))
        leg(i) = body(i).name
    end
    
    
    setAxes(axes_results, "Schrittzyklus", 5, "Winkel des Armes", 5)
     
    legend(leg)
    
    results_figure.visible = "on"
endfunction


function plot_forces_limb(limb_name)
    global body forces;
    global results_figure;
    
    styles = [-1, -2, -3]
    
    sca(axes_results)
    clear_plot(axes_results)
    
    
    execstr("limb = body(1)." + limb_name);       
    time = linspace(0, 1, length(limb.Fx));
    plot(time, limb.Fx, 'r');
    plot(time , limb.Fy, 'b');
    plot(time, limb.M, 'g');
    name = body(1).name + " " + limb_name;
    legend(name + " Fx", name + " Fy", name + " M", 4)
        
    results_figure.visible = "on";
endfunction

function changeLineThickness(axes, thickness)
    L = size(axes.children, 1)
    for i = 1 : L
        if axes.children(i).type == "Compound" then
            disp("Cleaning " + axes.children(i).type);
            axes.children(i).children.thickness = thickness;
            axes.children(i).children.line_mode = "on";
            axes.children(i).children.line_style = 1;
            axes.children(i).children.mark_mode = "off";   
        end 
    end
endfunction

function setFancyLegend()
legend("$\mathrm{Laufband\: 2\: km\cdot{h}}^{-1}$",...
       "$\mathrm{Laufband\: 4\:km\cdot{h}}^{-1}$",... 
       "$\mathrm{Laufband\: 7\: km\cdot{h}}^{-1}$",...
       "$\mathrm{Laufstrecke\: 1,6\: km\cdot{h}}^{-1}$",...
       "$\mathrm{Laufstrecke\: 4,5\: km\cdot{h}}^{-1}$",...
       "$\mathrm{Laufstrecke\: 8,6\: km\cdot{h}}^{-1}$",...
       5) 
endfunction

function changeColors(axes)
    L = size(axes.children, 1)
    colors = [color("scilabred4"), color("scilabred2"), color("darkorange"),  color("blue"), color("lightblue"), color("cyan")]
    for i = 1 : L
            if axes.children(i).type == "Compound" then
            axes.children(i).children.line_mode = "on";
            axes.children(i).children.line_style = 1;
            axes.children(i).children.mark_mode = "off";
            axes.children(i).children.foreground = colors(i - 1);
            end
    end
endfunction

function smoothLive(axes)
    L = size(axes.children, 1)
    for i = 1 : L
        if axes.children(i).type == "Compound" then
        axes.children(i).children.data(:,2) = MovingMean(axes.children(i).children.data(:,2));
        end
    end
endfunction

function [inverseVergleich] = inversePendulum()
    global body;
    schrittfrequenz = [ 0.47 , 0.66 , 0.72 , 0.86 , 0.90 , 1.02 , 1.04];
    dutyFaktor = [0.78 , 0.71 , 0.68 , 0.66 , 0.60 , 0.59 , 0.58];
    schrittdauer = schrittfrequenz.^(-1);
    for i = 1 : 7
        standdauer(i) = schrittdauer(i) * dutyFaktor(i);
        T_stand(i) = 2 * standdauer(i);
    end
    for i = 1 : size(body, 1)
        p_length = mean(GetLimbLength(body(i).foot, body(i).hip)) + 0.05;
        disp(p_length);
        T_inverse(i) = 2 * %pi * sqrt(p_length / 9.81)
    end
    
    inverseVergleich.model = T_inverse;
    inverseVergleich.proband = T_stand;
endfunction

function plotJointComparison(joint_name, force_name)
    rgb = ['r','b','g'];
    sca(axes_results);
    clear_plot(axes_results);
    
    for i = 1 : size(body, 1)
        execstr("force = body(i)." + joint_name + "." + force_name)
        time = linspace(0, 1, size(force, 1));
        plot(time, force, rgb(i))
    end
    
    changeLineThickness(axes_results, 3);
endfunction

function twoClickDistance()
    clicks = locate(2);
    x1 = clicks(1,1);
    y1 = clicks(2,1);
    x2 = clicks(1,2);
    y2 = clicks(2,2);
    distance = sqrt((x2 - x1)**2 + (y2 - y1)**2);
    disp(distance);
endfunction

function liveChangeYValues(axes, offset)
    L = size(axes.children, 1)
    for i = 1 : L
            if axes.children(i).type == "Compound" then
            axes.children(i).children.data(:,2) = axes.children(i).children.data(:,2) + offset
            end
    end
endfunction
