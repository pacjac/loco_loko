//huibutton = uicontrol(main_handle,...
//    "Position",[110 100 100 20],... 
//    "style","pushbutton", ...
//    "String","Compute", ...
//    "BackgroundColor",[.9 .9 .9],...
//    "fontsize",14);
//        
//sync = uicontrol(main_handle, ...
//    "Position"               , [320 100 100 10], ...
//    "Style"                  , "pushbutton", ...
//    "String"                 , "Sync", ...
//    "Fontsize"               , 10, ...
//    "BackgroundColor"        , [0.9 0.9 0.9], ...
//    "Visible"                , "on",...
//    "Enable"                 , "on",...
//    "tag"                    , "sync");
//    
//scale = uicontrol(main_handle, ...
//    "position"          , [170 20 50 20], ...
//    "Style"             , "edit", ...
//    "Fontsize"          , 10,...
//    "HorizontalAlignment", "center",...
//    "String"            , "1.000", ...
//    "Visible"           , "on",...
//    "BackgroundColor"   , [1 1 1], ...
//    "tag"               , "scale");  
    
// Adding model parameters

//// ordered list of labels
//labels1 = ["Tau", "s", "q", "smax", "a", "b", "g", "delta"]; // ordered list of default values
//values1 = [5e4, 0.61, 3.443, 0.1, 0.163, 0.024, 0.062, 0.291]; // positioning
//l1 = 40; l2 = 100; l3 = 110;
guih1 = 300;
guih1o = 240;
for k=1:size(body, 1)
    uicontrol(main_handle,... 
        "style"             ,"Checkbox",...
        "string"            ,body(k).name,...
        "position"          ,[l1, guih1-k*20+guih1o, l2, 20], ...
        "horizontalalignment","left",...
        "fontsize"          ,14, ...
        "background"        ,[1 1 1]);
end        
//    guientry1(k) = uicontrol(main_handle,... 
//        "style"             ,"edit", ...
//        "string"            ,string(values1(k)),...
//        "position"          ,[l3, guih1-k*20+guih1o, 60, 20],...
//        "horizontalalignment","left",...
//        "fontsize"          ,14, ...
//        "background"        ,[1 1 1]);


        
sleep(500);
