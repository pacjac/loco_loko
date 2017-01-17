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

function save_result_fig()
    global results_figure savedir;
    name = save_entry.string
    savestring = savedir + "/" + name + ".pdf"
    figure_id = results_figure.figure_id
    xs2pdf(figure_id, savestring)
endfunction


function set_result_dir(cwd)
    global savedir cwd;
    savedir = uigetdir(cwd + "../results/")
endfunction 

function getProbandMass()
    global proband_mass
    proband_mass = strtod(mass_entry.string)
endfunction

function toggle_help()
    global enable_help;
    if enable_help == %f then
        enable_help = %t
    else enable_help = %f
    end
endfunction

function [cob] = getCobValues()
    value_string = cob_value.string;
    split_string = tokens(value_string, [",", " "])
    cob.x = strtod(split_string(1))
    cob.y = strtod(split_string(2))
endfunction
