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
    global forces;
    
    colors = [color("red"), color("blue"), color("green")];
    
    dutyfactor = [0.76, 0.64, 0.53]
    
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
//        time = linspace(0, 1, end_plot - begin_plot + 1)
        time = linspace(0, dutyfactor(i), end_plot - begin_plot + 1)
        cutforces = force.Fz(begin_plot:end_plot, 1)
        
        // Change to results frame
        scf(results_figure)
        sca(axes_results)
        
        tmp = tokens(forcefile(i), ['/','.'])
        leg(i) = tmp($ - 1)
        
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
        rel_hand.x = body(i).hand.x - body(i).shoulder.x
        rel_hand.y = body(i).hand.y - body(i).shoulder.y
        
        plot(rel_hand.x, rel_hand.y, styles(i))
        leg(i) = body(i).name
    end
    
    
    setAxes(axes_results, "X", 5, "Y", 5)
     
    legend(leg)
    
    results_figure.visible = "on"
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
