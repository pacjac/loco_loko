function setAxes(axes, xLabel, xFontSize, yLabel, yFontSize)
    axes.x_label.text = xLabel;
    axes.x_label.font_size = xFontSize;
    axes.y_label.text = yLabel;
    axes.y_label.font_size = yFontSize; 
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

function drawallthesticks()
    global toes ankle knee hip shoulder elbow hand neck;
    scf(1);//clf();
    
    offset = - 0.2
    
    data_tmp = [...
        toes.x(1), toes.y(1);...
        ankle.x(1), ankle.y(1);...
        knee.x(1), knee.y(1);...
        hip.x(1), hip.y(1);...
        neck.x(1), neck.y(1);...
        shoulder.x(1), shoulder.y(1);...
        elbow.x(1), elbow.y(1);...
        hand.x(1), hand.y(1)];
        
    plot(data_tmp(:,1), data_tmp(:,2))
    e = gce();
    h_stick = e.children;
    
    a = gca();
    a.data_bounds=[1,0;3,2];
    
    for i = 1 : 2 : size(toes.x,1)
        data_tmp = [...
        toes.x(i) + offset * i, toes.y(i);...
        ankle.x(i) + offset * i, ankle.y(i);...
        knee.x(i) + offset* i, knee.y(i);...
        hip.x(i) + offset* i, hip.y(i);...
        neck.x(i) + offset * i, neck.y(i);...
        shoulder.x(i) + offset* i, shoulder.y(i);...
        elbow.x(i) + offset* i, elbow.y(i);...
        hand.x(i) + offset * i, hand.y(i)];
        
        
        //h_stick.data = data_tmp;
        sleep(100);
        
    end
    plot(data_tmp(:,1), data_tmp(:,2))
endfunction


function plot_forces()
    // figures to work with
    global results_figure axes_frame;
    // data to work with 
    global forces;
    
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


