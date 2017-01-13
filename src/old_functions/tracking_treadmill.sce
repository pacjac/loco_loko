clear(); // Löschen aller Variablen
clearglobal(); // Löschen aller globalen Variablen

//********************************************
//              CONSTANTS
//********************************************

PI = 3.14;


//********************************************
//      READ IN THE FUNCTIONS.SCI FIlE 
//  containing numiercal and plotting routines
//********************************************

// not sure what's the cleaner way, but i'll go with getd()
cwd = get_absolute_file_path('tracking_treadmill.sce')
getd(cwd);
exec(cwd + '/readData.sci')
//exec('./functions.sci');

//********************************************
//              DATA-IMPORT
//********************************************

// Öffnendialog starten
data_path = uigetfile(["*.mdf", "Output from ImageJ"], cwd + "/../data/","Select CSV data",%t);

// For testing only
//data_path = absolute_path + "/../data/aljoscha/5_kmh.mdf"

for i = 1 : size(data_path, 1)
    [toes, ankle, knee, hip, shoulder, elbow, hand, neck] = readFromMDF(data_path(i))
end

//scf(0);
//plot(toes.x,toes.y);
//toes.speed = CalcSpeed(toes)  //FIXME es fehlt das DeltaT

//toes.speed.x = MovingMean(toes.speed.x)
//toes.speed.x = MovingMean(toes.speed.y)

//plot (toes.x, toes.y, 'or');
//plot(toes.speed.x, toes.speed.y);
// plot(knee.x,knee.y,'or'); // Plot x, y, ?#










//savetarget = uiputfile("*.txt*");


//fprintfMat(savetarget, UsS); // Speichern fprintfMat(Zielpfad, Daten)
