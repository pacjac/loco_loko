// CLEAR PATH
clear();
clearglobal();

global T
T = 1
global X
T = 2
global Y
T = 3
global Z
T = 4
global S_TIME
S_TIME = 3.20

global a
a = 0.03
global b
b = 0.0575
global CoB
CoB = b

cwd = get_absolute_file_path('scale.sce')
getd(cwd);



driftfile = cwd + '../data/Waage/Kalibrierung/Waagendrift_clean.txt';
offsetDataRaw = readScaleFile(driftfile);
xCalFile = cwd + '../data/Waage/Kalibrierung/XKali_clean.txt';
xCalRaw = readScaleFile(xCalFile)
yCalFile = cwd + '../data/Waage/Kalibrierung/YKali_clean.txt';
yCalRaw = readScaleFile(yCalFile);
zCalFile = cwd + '../data/Waage/Kalibrierung/ZKali_clean.txt';
zCalRaw = readScaleFile(zCalFile);
langsamFile = cwd + '../data/Waage/Kraftmessungen_Loko_WS16/Aljoscha/langsam.txt';
langsamRaw = readScaleFile(langsamFile)
normalFile = cwd + '../data/Waage/Kraftmessungen_Loko_WS16/Aljoscha/angenehm.txt';
normalRaw = readScaleFile(normalFile);
schnellFile = cwd + '../data/Waage/Kraftmessungen_Loko_WS16/Aljoscha/schnell.txt';
schnellRaw = readScaleFile(schnellFile);

offsetData = combineChannels(offsetDataRaw, a, b, CoB)
xCal = combineChannels(xCalRaw, a, b, CoB)
yCal = combineChannels(yCalRaw, a, b, CoB)
zCal = combineChannels(zCalRaw, a, b, CoB)
langsam = combineChannels(langsamRaw, a, b, CoB)
normal = combineChannels(normalRaw, a, b, CoB)
schnell = combineChannels(schnellRaw, a, b, CoB)

scaledrift = calcScaleDrift(offsetData)
voltageToForce = convertVoltageToForce(xCal, yCal, zCal)

langsamSmooth = calculateForces(langsam, scaledrift, voltageToForce)
normalSmooth = calculateForces(normal, scaledrift, voltageToForce)
schnellSmooth = calculateForces(schnell, scaledrift, voltageToForce)

plotForces(langsamSmooth, 0, "langsam", [1366,768])
plotForces(normalSmooth, 1, "normal", [1366,768])
plotForces(schnellSmooth, 2, "schnell", [1366,768])



/// DEPRECATED!
//plotSchnell = scf(2)
//plot(schnellSmooth.t, schnellSmooth.x, 'r')
//plot(schnellSmooth.t, ((schnell(:,2) - (schnell(:,1) * scaledrift.x + schnellSmooth.offsetX  )) * voltageToForce.x), 'rx')
//plot(schnellSmooth.t, schnellSmooth.y, 'g')
//plot(schnellSmooth.t, ((schnell(:,3) - (schnell(:,1) * scaledrift.y + schnellSmooth.offsetY  )) * voltageToForce.y), 'gx')
//plot(schnellSmooth.t, schnellSmooth.z, 'b')
//plot(schnellSmooth.t, ((schnell(:,4) - (schnell(:,1) * scaledrift.z + schnellSmooth.offsetZ  )) * voltageToForce.z), 'bx')
//plotSchnell.figure_size = [1366,768]
//plotSchnell.figure_name = "schnell"
//axes = gca()
//xlabel(axes, "Zeit [s]")
//ylabel(axes, "Gewicht [kg]")
//xs2svg(plotSchnell, 'schnell.svg')
