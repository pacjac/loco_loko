function savesession()
    global forces body voltageToForce scaleDrift proband_mass;
    global cwd
    save(cwd + 'session.sod', 'forces', 'body', 'voltageToForce', 'scaleDrift', 'proband_mass')
endfunction

function loadsession()
    global forces body voltageToForce scaleDrift proband_mass;
    global cwd
    load(cwd + 'session.sod', 'forces', 'body', 'voltageToForce', 'scaleDrift', 'proband_mass')
endfunction

function clearData()
    global body forces ;
    body = [];
    forces = [];
endfunction
