function drawStickFigure()
    global toes ankle knee hip shoulder elbow hand neck;
    scf(1);//clf();
    
    offset = 0.2
    
    data_tmp = [toes.x(1),toes.y(1);ankle.x(1),ankle.y(1);knee.x(1),knee.y(1);hip.x(1),hip.y(1);neck.x(1),neck.y(1);shoulder.x(1),shoulder.y(1);elbow.x(1),elbow.y(1);hand.x(1),hand.y(1)];
    plot(data_tmp(:,1), data_tmp(:,2))
    e = gce();
    h_stick = e.children;
    
    a = gca();
    a.data_bounds=[1,0;3,2];
    
    for i = 1 : 2 : size(toes.x,1)
        drawlater
        data_tmp = [toes.x(i) + offset,toes.y(i);ankle.x(i) + offset,ankle.y(i);knee.x(i) + offset,knee.y(i);hip.x(i) + offset,hip.y(i);neck.x(i) + offset,neck.y(i);shoulder.x(i) + offset,shoulder.y(i);elbow.x(i) + offset,elbow.y(i);hand.x(i) + offset,hand.y(i)];
        plot(data_tmp(:,1), data_tmp(:,2))
        //h_stick.data = data_tmp;
        sleep(100);
        drawnow
    end
endfunction

function drawallthesticks(body, speed)
    global toes ankle knee hip shoulder elbow hand neck;
    scf(1001);//clf();
    
    [toes, ankle, knee, hip, shoulder, elbow, hand, neck, foot, leg, thigh, leg_total, upperarm, forearm, arm_total, trunk] = setCurrentBody(body)
    
    offset = - speed / 3.6 * 0.02
    
    sca(axes_results)
    clear_plot(axes_results)
    
    
    drawlater
    for i = 1 : 2 : size(toes.x,1)
        
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
        plot(data_tmp2(:,1), data_tmp2(:,2), 'g')
        //h_stick.data = data_tmp;
        sleep(100);
        
    end
    
    legend(body.name)
    drawnow
    
endfunction
