%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VVIQ - with Car Items
% 08/2015 Mackenzie Sunday
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','MATLAB:dispatcher:InexactMatch');
Screen('Preference', 'SkipSyncTests',1);             % Add this line after clear'all' to run on laptop

try
    commandwindow;
    esc_key = KbName('escape'); %this key will kill the script during the experiment
    HideCursor;
    
    %setting up keyboards
    devices = PsychHID('Devices');
    kbs = find([devices(:).usageValue] == 6);
    usethiskeyboard = kbs(end);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get subject information.
    repeat=1;
    while (repeat)
        prompt= {'Subject number','Subject Initials','Age','Sex (m/f)', 'Handedness (r/l/a)'};
        defaultAnswer={'99', 'aaa', '28', 'f', 'r'};
        answer=inputdlg(prompt,'Subject information',1, defaultAnswer);
        [subjno,subjini,age,sex,hand]=deal(answer{:});
        if isempty(str2num(subjno)) || ~isreal(str2num(subjno))
            h=errordlg('Subject Number must be an integers','Input Error');
            repeat=1;
            uiwait(h);
        else
            VVIQfileName=['VVIQ_' subjno '_' subjini '.txt'];
            SR_GenfileName = ['SR_Gen' subjno '_' subjini '.txt'];
            if exist(VVIQfileName)~=0
                button=questdlg(['Overwrite VVIQ_',subjno,'_',subjini,'.txt?']);
                if strcmp(button,'Yes'); repeat=0; end
            else
                repeat=0;
            end
        end
    end
    
    %Open Screens.
    black = [0 0 0];
    white = [255 255 255];
    gray = (black + white)/2;
    AssertOpenGL;
    ScreenNumber=max(Screen('Screens'));
    [w, ScreenRect]=Screen('OpenWindow',ScreenNumber, black, [], 32, 2);
    midWidth=round(RectWidth(ScreenRect)/2);
    midLength=round(RectHeight(ScreenRect)/2);
    Screen('FillRect', w, black);
    Screen('Flip',w);
    
    Screen_X = RectWidth(ScreenRect);
    Screen_Y = RectHeight(ScreenRect);
    cx = round(Screen_X/2);
    cy = round(Screen_Y/2);
    num_items = 48; % number of items eyes open and closed
    num_prompts = 12; % number of prompts with eyes closed and open
    
    ScreenBlank = Screen(w, 'OpenOffScreenWindow', black, ScreenRect);
    [oldFontName, oldFontNumber] = Screen(w, 'TextFont', 'Helvetica' );
    [oldFontName, oldFontNumber] = Screen(ScreenBlank, 'TextFont', 'Helvetica' );
    
    %Open data file and set up keyboard
    VVIQfile = fopen(VVIQfileName,'w');
    
    key1 = KbName('1!'); key2 = KbName('2@'); key3 = KbName('3#');
    key4 = KbName('4$'); key5 = KbName('5%'); key6 = KbName('6^');
    key7 = KbName('7&'); key8 = KbName('8*'); key9 = KbName('9(');
    spaceBar = KbName('space');
    
    fprintf(VVIQfile, ('\n%s\t%s'),...
        subjno,subjini);
    fprintf(VVIQfile,'\nprompt\titem\trt\trating');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %Get self ratings.
     %Open ratings data file.
    SR_Gen=fopen(SR_GenfileName,'w');
    fprintf(SR_Gen, ('\n%s\t%s'),...
        subjno,subjini);
    fprintf(SR_Gen,'\nItem\tRating');
     
    numItems = 4;
    
    item1a = 'Generally speaking, how strong is your interest in classifying objects in their various subcategories'
    item1b = '(such as learning about different kinds of insects, plants, vehicles, tools...)?';
    item2a = 'Generally speaking, how easily do you learn'
    item2b = 'to recognize objects visually?';
    item3a = 'Generally speaking, relative to the average person, how much of your time at WORK or'
    item3b = 'SCHOOL involves recognizing things visually?'
    item4a = 'Generally speaking, relative to the average person,' 
    item4b = 'how much of your FREE TIME involves recognizing things visually?'
    SRGen = 'Generally speaking, how strong is your interest in classifying objects in their various subcategories\(such as learning about different kinds of insects, plants, vehicles, tools...)?\Generally speaking, how easily do you learn\to recognize objects visually?\Generally speaking, relative to the average person, how much of your time at WORK or\SCHOOL involves recognizing things visually?\Generally speaking, relative to the average person,\how much of your FREE TIME involves recognizing things visually?'
    SRGen_str = strsplit(SRGen,'\'); %spilts the string with the deliminater '\' and puts into a cell array
    rnot6 = 'Please use the number keys at the TOP of the keyboard for your responses.';
    scale_Gen = '1      2       3       4       5       6       7       8       9';
    scale_lowhigh = 'very much below average                          very much above average';
    bounds_item1a = Screen('TextBounds', w, item1a); bounds_item1b = Screen('TextBounds', w, item1b);
    bounds_item2a = Screen('TextBounds', w, item2a); bounds_item2b = Screen('TextBounds', w, item2b);
    bounds_item3a = Screen('TextBounds', w, item3a); bounds_item3b = Screen('TextBounds', w, item3b);
    bounds_item4a = Screen('TextBounds', w, item4a); bounds_item4b = Screen('TextBounds', w, item4b);
    bounds_rnot6 = Screen('TextBounds', w, rnot6); bounds_scale_Gen = Screen('TextBounds', w, scale_Gen);
    bounds_scale_lowhigh = Screen('TextBounds', w, scale_lowhigh); 
    
    for i=1:2:(numItems*2)
        Screen('FillRect',w,black);
        % draw the prompt
        Screen('TextSize', w, 30);
        bounds_SR_1 = Screen('TextBounds', w, SRGen_str{1,i});
        bounds_SR_2 = Screen('TextBounds', w, SRGen_str{1,i+1});
        [newX, newY] = Screen('DrawText', w, SRGen_str{1,i}, cx-bounds_SR_1(3)/2, cy-300, gray);
        [newX, newY] = Screen('DrawText', w, SRGen_str{1,i+1}, cx-bounds_SR_2(3)/2, cy-250, gray);
        % draw the things that don't change in a smaller font
        Screen('TextSize', w, 24);
        [newX, newY] = Screen('DrawText', w, rnot6, cx-bounds_rnot6(3)/2, cy-75, gray);
        [newX, newY] = Screen('DrawText', w, scale_lowhigh, cx-bounds_scale_lowhigh(3)/2, cy+250, gray);
        [newX, newY] = Screen('DrawText', w, scale_Gen, cx-bounds_scale_Gen(3)/2, cy+300, gray);
        Screen('Flip', w); WaitSecs(.5);
        touch=0;
        while touch==0
            [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
            if  keyCode(key1)||keyCode(key2)||keyCode(key3)||keyCode(key4)||keyCode(key5)||keyCode(key6)||keyCode(key7)||keyCode(key8)||keyCode(key9);
                break;
            else
                if touch; end;
                touch=0;
            end
        end
        if keyCode(key1); resp = 1;
        elseif keyCode(key2); resp = 2; elseif keyCode(key3); resp = 3;
        elseif keyCode(key4); resp = 4; elseif keyCode(key5); resp = 5;
        elseif keyCode(key6); resp = 6; elseif keyCode(key7); resp = 7;
        elseif keyCode(key8); resp = 8; elseif keyCode(key9); resp = 9;
        elseif touch==0; resp='0';
        end
        fprintf(SR_Gen, ('\n%s\t%d'),...
            SRGen_str{1,i},resp);
        
        FlushEvents('keyDown');
        touch=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Instructions
    instruct1 = 'Visual imagery refers to the ability to visualize, that is, the ability to form mental pictures, or to "see in the mind''s eye".';
    instruct2 = 'Marked individual differences have been found in the strength and clarity of';
    instruct3 = 'reported visual imagery and these differences are of considerable psychological interest.';
    instruct4 = 'The aim of this test is to determine the vividness of your visual imagery.';
    instruct5 = 'The items of the test will possibly bring certain images to your mind.';
    instruct6 = 'You are asked to rate the vividness of each image by reference to the 5-point scale given below.';
    instruct7 = 'For example, if your image is "vague and dim" then give it a rating of 2.';
    instruct8 = 'Press the spacebar to continue';
    instruct9 = 'First, we will ask you to answer these questions with your eyes open, then we will do them again,';
    instruct10 = 'asking you to give your ratings for your eyes closed .';
    instruct11 = 'Try to give your ''eyes closed'' rating independently of the ''eyes open'' rating.';
    instruct12 = 'In general, try to answer each question independent of the other questions,';
    instruct13 = 'only paying attention to the vividness of the current image.';    
    notEnd = 'Thank you for your participation! Please get the experimenter';    
    eyes_open = 'WITH YOUR EYES OPEN'; eyes_closed = 'WITH YOUR EYES CLOSED';
    trials = 'Think of some relative or friend whom you frequently see (but is not with you at present).\The exact contour of face, head, shoulders, and body.\Characteristic poses of head, attitudes of body, etc.\The precise gait, length of step, etc., in walking.\The different colors worn in some familiar clothes.\Visualize a rising sun.\The sun is rising above the horizon into a hazy sky.\The sky clears and surrounds the sun with blueness.\Clouds. A storm blows up, with flashes of lightning.\A rainbow appears.\Think of the front of a shop to which you often go.\The overall appearance of the shop from the opposite side of the road.\A window display including colors, shapes and details of individual items for sale.\You are near the entrance. The color, shape and detail of the door.\You enter the shop and go to the counter. The counter assistant serves you. Money changes hands.\Think of a country scene which involves trees, mountains, and a lake.\ The contours of the landscape.\The color and shape of the trees.\The color and shape of the lake.\A strong wind blows on the trees and on the lake, causing waves.\ Think of a familiar car that is not your own.\ The contours of the car body, tires, and windows.\The color of the car in bright sun. Any scratches or details on the car body.\The car pulling into a driveway and parking.\The car facing you and approaching.\Think of your dream car if you could have any car you wanted.\The car driving on a highway.\The contours of the car body, tires, and windows.\The car being washed.\The car after driving it on a muddy road.';
    trial_str = strsplit(trials,'\'); %spilts the string with the deliminater '\' and puts into a cell array 
    instruct_EC = 'Now please answer the questions visualizing the scene with your eyes closed';
    note1 = 'Consider carefully the picture that comes before your mind''s eye. Then rate the following item:';
    rnot1 = 'No knowledge at all'; rnot2 = 'Vague and dim';
    rnot3 = 'Moderately clear and vivid'; rnot4 = 'Clear and reasonably vivid';
    rnot5 = 'Perfectly clear and vivid';
    scale1 = '''No knowledge at all''  ''Vague and dim''  ''Moderately clear and vivid''  ''Clear and resonably vivid''  ''Perfectly clear and vivid''';
    scale = '1                                        2                                        3                                        4                                        5';
    
    Screen(w, 'TextSize', 24);
    bounds_instruct1 = Screen('TextBounds', w, instruct1); bounds_instruct2 = Screen('TextBounds', w, instruct2);
    bounds_instruct3 = Screen('TextBounds', w, instruct3); bounds_instruct4 = Screen('TextBounds', w, instruct5);
    bounds_instruct5 = Screen('TextBounds', w, instruct2); bounds_instruct6 = Screen('TextBounds', w, instruct6);
    bounds_instruct7 = Screen('TextBounds', w, instruct7); bounds_instruct8 = Screen('TextBounds', w, instruct8);
    bounds_instruct9 = Screen('TextBounds', w, instruct9); bounds_instruct10 = Screen('TextBounds', w, instruct10);
    bounds_instruct11 = Screen('TextBounds', w, instruct11); bounds_instruct12 = Screen('TextBounds', w, instruct12);
    bounds_instruct13 = Screen('TextBounds', w, instruct13); bounds_eyes_open = Screen('TextBounds', w, eyes_open);
    bounds_eyes_closed = Screen('TextBounds', w, eyes_closed); bounds_note1 = Screen('TextBounds', w, note1);
    bounds_rnot6 = Screen('TextBounds', w, rnot6); bounds_scale = Screen('TextBounds', w, scale);
    bounds_scale1 = Screen('TextBounds', w, scale1); bounds_instruct_EC = Screen('TextBounds', w, instruct_EC);
    bounds_notEnd = Screen('TextBounds', w, notEnd);
    
    %first instruction screen
    [newX, newY] = Screen('DrawText', w, instruct1, cx-bounds_instruct1(3)/2, cy-200, gray);
    [newX, newY] = Screen('DrawText', w, instruct2, cx-bounds_instruct2(3)/2, cy-150, gray);
    [newX, newY] = Screen('DrawText', w, instruct3, cx-bounds_instruct3(3)/2, cy-100, gray);
    [newX, newY] = Screen('DrawText', w, instruct4, cx-bounds_instruct4(3)/2, cy-50, gray);
    [newX, newY] = Screen('DrawText', w, instruct5, cx-bounds_instruct5(3)/2, cy+50, gray);
    [newX, newY] = Screen('DrawText', w, instruct6, cx-bounds_instruct6(3)/2, cy+100, gray);
    [newX, newY] = Screen('DrawText', w, instruct7, cx-bounds_instruct7(3)/2, cy+150, gray);
    [newX, newY] = Screen('DrawText', w, instruct8, cx-bounds_instruct8(3)/2, cy+400, gray);
    [newX, newY] = Screen('DrawText', w, rnot6, cx-bounds_rnot6(3)/2, cy+200, gray);
    [newX, newY] = Screen('DrawText', w, scale, cx-bounds_scale(3)/2, cy+250, gray);
    [newX, newY] = Screen('DrawText', w, scale1, cx-bounds_scale1(3)/2, cy+300, gray);
    Screen('Flip', w);
    startexpt = GetSecs;
    
    WaitSecs(.5);
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    FlushEvents('keyDown');
    touch=0;
    
    %second instruction screen
    Screen('FillRect',w,black);
    [newX, newY] = Screen('DrawText', w, instruct9, cx-bounds_instruct9(3)/2, cy-200, gray);
    [newX, newY] = Screen('DrawText', w, instruct10, cx-bounds_instruct10(3)/2, cy-150, gray);
    [newX, newY] = Screen('DrawText', w, instruct11, cx-bounds_instruct11(3)/2, cy-100, gray);
    [newX, newY] = Screen('DrawText', w, instruct12, cx-bounds_instruct12(3)/2, cy-50, gray);
    [newX, newY] = Screen('DrawText', w, instruct13, cx-bounds_instruct13(3)/2, cy, gray);
    [newX, newY] = Screen('DrawText', w, instruct8, cx-bounds_instruct8(3)/2, cy+200, gray);
    Screen('Flip', w);
    
    WaitSecs(.5);
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    FlushEvents('keyDown');
    touch=0;
    startexpt = GetSecs; %to get rough estimate of total time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get VVIQ ratings
    prompt = 1; %initialize prompt variable
    rating = []; %initalize rating vector
    i=1; %initialize i
    while i<=num_items
        if i<= (num_items/2) %eyes open
            while prompt<=length(trial_str)
                for item=1:4 %there are 4 items per prompt
                    Screen('FillRect',w,black);
                    % draw the prompt
                    Screen('TextSize', w, 36);
                    bounds_prompt = Screen('TextBounds', w, trial_str{1,prompt});
                    [newX, newY] = Screen('DrawText', w, trial_str{1,prompt}, cx-bounds_prompt(3)/2, cy-250, gray);
                    % draw the item
                    bounds_item = Screen('TextBounds', w, trial_str{1,prompt+item});
                    [newX, newY] = Screen('DrawText', w, trial_str{1,prompt+item}, cx-bounds_item(3)/2, cy, gray);
                    % draw the things that don't change in a smaller font
                    Screen('TextSize', w, 24);
                    [newX, newY] = Screen('DrawText', w, eyes_open, cx-bounds_eyes_open(3)/2, 100, gray);
                    [newX, newY] = Screen('DrawText', w, note1, cx-bounds_note1(3)/2, cy-75, gray);
                    [newX, newY] = Screen('DrawText', w, scale, cx-bounds_scale(3)/2, cy+250, gray);
                    [newX, newY] = Screen('DrawText', w, scale1, cx-bounds_scale1(3)/2, cy+300, gray);
                    Screen('Flip', w); tstart=GetSecs; 
                    WaitSecs(1); touch=0;
                    while touch==0
                        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
                        rt = (tpress-tstart)*1000;
                        if  keyCode(key1)||keyCode(key2)||keyCode(key3)||keyCode(key4)||keyCode(key5);
                            break;
                        else
                            if touch; end;
                            touch=0;
                        end
                    end
                    if keyCode(key1); resp = 1;
                    elseif keyCode(key2); resp = 2; elseif keyCode(key3); resp = 3;
                    elseif keyCode(key4); resp = 4; elseif keyCode(key5); resp = 5;
                    elseif touch==0; resp='0';
                    end
                    
                    %save response to data file
                    fprintf(VVIQfile, ('\n%s\t%s\t%s\t%u'),trial_str{1,prompt},trial_str{1,prompt+item},rt,resp);
                    %save response to response vector
                    rating = [rating resp];
                    i=i+1; %increment i 
                end
                prompt = prompt+5; % advance prompt by 5 to skip the 4 item strings in the cell array
            end
        else % eyes closed        
            %draw screen to notify subjects they are to close eyes now
            [newX, newY] = Screen('DrawText', w, instruct_EC, cx-bounds_instruct_EC(3)/2, cy, gray);
            [newX, newY] = Screen('DrawText', w, instruct8, cx-bounds_instruct8(3)/2, cy+200, gray);
            Screen('Flip', w);
            WaitSecs(.5);
            touch=0;
            while touch==0
                [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
                if keyCode(spaceBar); break; else touch=0; end
            end; while KbCheck; end  
            
            FlushEvents('keyDown');
            touch=0; prompt = 1; % set prompt back to 1
            while prompt<=length(trial_str)
                for item=1:4
                    Screen('FillRect',w,black);
                    % draw the prompt
                    Screen('TextSize', w, 36);
                    bounds_prompt = Screen('TextBounds', w, trial_str{1,prompt});
                    [newX, newY] = Screen('DrawText', w, trial_str{1,prompt}, cx-bounds_prompt(3)/2, cy-250, gray);
                    % draw the item
                    bounds_item = Screen('TextBounds', w, trial_str{1,prompt+item});
                    [newX, newY] = Screen('DrawText', w, trial_str{1,prompt+item}, cx-bounds_item(3)/2, cy, gray);
                    % draw the things that don't change
                    Screen('TextSize', w, 24);
                    [newX, newY] = Screen('DrawText', w, eyes_closed, cx-bounds_eyes_closed(3)/2, 100, gray);
                    [newX, newY] = Screen('DrawText', w, note1, cx-bounds_note1(3)/2, cy-75, gray);
                    [newX, newY] = Screen('DrawText', w, scale, cx-bounds_scale(3)/2, cy+250, gray);
                    [newX, newY] = Screen('DrawText', w, scale1, cx-bounds_scale1(3)/2, cy+300, gray);
                    Screen('Flip', w); tstart=GetSecs; 
                    WaitSecs(1); touch=0;
                    while touch==0
                        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
                        rt = (tpress-tstart)*1000;
                        if  keyCode(key1)||keyCode(key2)||keyCode(key3)||keyCode(key4)||keyCode(key5);
                            break;
                        else
                            if touch; end;
                            touch=0;
                        end
                    end
                    if keyCode(key1); resp = 1;
                    elseif keyCode(key2); resp = 2; elseif keyCode(key3); resp = 3;
                    elseif keyCode(key4); resp = 4; elseif keyCode(key5); resp = 5;
                    elseif touch==0; resp='0';
                    end
                    
                    %save response to data file
                    fprintf(VVIQfile, ('\n%s\t%s\t%s\t%u'),trial_str{1,prompt},trial_str{1,prompt+item},rt,resp);
                    
                    %save response to response vector
                    rating = [rating resp];
                    i=i+1;
                end
                prompt = prompt+5; % advance prompt
            end
        end
    end
    
    FlushEvents('keyDown');
    touch=0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Close up shop
    fclose('all');
    
    [newX, newY] = Screen('DrawText', w, notEnd, cx-bounds_notEnd(3)/2, cy, gray);
    Screen('Flip', w);
    WaitSecs(.2);
    
    FlushEvents('keyDown');
    pressKey = KbWait;
    
    totalExptTime = (GetSecs - startexpt)/60;
    All_Rating = mean(rating);
    Car_Items = [rating(17:24) rating(41:48)] %to get only car items responses 
    NC_Items = [rating(1:16) rating(25:40)] %to get only not car items responses
    Car_Rating = mean(Car_Items);
    NC_Ratings = mean(NC_Items);
    
    fprintf('\nExperiment time:\t%4f\t minutes',totalExptTime);
    fprintf('\nAverage rating:\t%4f',All_Rating);
    fprintf('\nAverage car rating:\t%4f',Car_Rating);
    fprintf('\nAverage not car rating:\t%4f',NC_Rating);
    
    ShowCursor;
    Screen('CloseAll');
    
catch
    
    ShowCursor;
    Screen('CloseAll');
    rethrow(lasterror);
end