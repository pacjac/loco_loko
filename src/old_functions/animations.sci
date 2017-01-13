function drawStickFigure()
    scf(1);//clf();
    
    data_tmp = [toes.x(1),toes.y(1);ankle.x(1),ankle.y(1);knee.x(1),knee.y(1);hip.x(1),hip.y(1);neck.x(1),neck.y(1);shoulder.x(1),shoulder.y(1);elbow.x(1),elbow.y(1);hand.x(1),hand.y(1)];
    plot(data_tmp(:,1), data_tmp(:,2))
    e = gce();
    h_stick = e.children;
    
    a = gca();
    a.data_bounds=[1,0;3,2];
    
    for i = 1 : size(toes.x,1)
        drawlater
        data_tmp = [toes.x(i),toes.y(i);ankle.x(i),ankle.y(i);knee.x(i),knee.y(i);hip.x(i),hip.y(i);neck.x(i),neck.y(i);shoulder.x(i),shoulder.y(i);elbow.x(i),elbow.y(i);hand.x(i),hand.y(i)];
        h_stick.data = data_tmp;
        sleep(100);
        drawnow
    end
endfunction

function drawallthesticks()
endfunction
