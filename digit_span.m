function [wins, payment, final_length]=digit_span(particNum, DateTime, window, trials, blocks, start_span, max_span, min_span, num_to_change, reward)

global cfg taskTimeStamp

% clear all
% clc

% % DELETE WHEN CONVERTED TO FUNCTION
% compNum=99;
% DateTime = datestr(now,'ddmm-HHMM'); % Get date and time for log file
% insertDate = [datestr(now,'ddmm'), '999'];
% particNum = [insertDate, num2str(compNum)];
% trials = 5;
% blocks = 2; % one forward, one backwards
% num_to_change = 3;
% max_span = 8;
% min_span = 3;
% start_span = 5;
% DELETE SCREEN VARIABLES LABELED BELOW
% COMMENT OUT SCREEN and PTB INITIATION

%% Set Variables
% num_trials= [1:5];
language=1; % 1=Italian, 2=English
win=window;


overall_trial = (1:trials*blocks)';
digit_array = randi(9, max_span, trials, blocks); % construct all possible trials
prompt={'Inserisci i numeri nell''ordine mostrato:', 'Inserisci i numeri nell''ordine inverso:';'Please enter the numbers in the order shown:','Please enter the numbers in reverse order:'};
instructions={'Ora vedrai una sequenza di numeri. \nDovrai ricordarli e poi inserirli nello stesso ordine. \nPremi ''backspace/cancella'' se sbagli. \n\nPremi ''invio'' per iniziare.', ...
    'In questa parte, dovrai ancora ricordarti la sequenza di numeri \nPero'' adesso dovrai reinserirli nell''ordine inverso dall''ultimo al primo. \n\n<color=6E7B8B>Premi ''invio'' per continuare.<color>'; ...
    'Now you will be shown a string of numbers. \n  You have to remember them \n and then type them back in in the same order \n Press "backspace" if you make a mistake. \n\n<color=6E7B8B>Press ''return'' to begin.<color>', ...
    'In this part of the task, again remember the string of numbers \n but now type them back in the opposite order \n\n<color=6E7B8B>Press ''return'' to continue<color>'};
continue_prompt={'Premi ''invio'' ' ;'Press ''return'' '};
% Pre-allocate
block_num = NaN(blocks*trials,1);
digit_span_table = table; % create table to be filled in trial by trial

KbName('UnifyKeyNames');
RestrictKeysForKbCheck(cfg.enabledNumberKeys);
    
% %%Open PTB
% % one-screen setup
% Screen('Preference', 'SkipSyncTests', 0);
% [win,screenrect]=Screen('OpenWindow',0,[255 255 255],[0 0 800 600]); 

% % for two-screen setup
% Screen('Preference', 'SkipSyncTests', 1);
% [win, windowRect] = Screen('OpenWindow', 1,[255 255 255]); 
% 
% % %%%%%%%%%%%DELETE WHEN INCORPORATED INTO UMBRELLA SCRIPT
% [screenXpixels, screenYpixels] = Screen('WindowSize', win);
% cfg.uppTextYpos=screenYpixels * 8/40;
% cfg.fontSize = round(screenYpixels * 1.5/40);
% cfg.fontSizeBig = round(screenYpixels * 2/40);
% cfg.font = 'Courier New';
% 
% %%%%%%%%%%%%%%
% 
%     Screen('TextFont', win, cfg.font);
%     Screen('TextSize', win, cfg.fontSize);
%% initialize event log
Events.types = {};
Events.values = {};
Events.times = [];
Events.exptimes = [];
Events.act_durations = [];
Events.int_durations = [];
Events.info = {};
nbevents = 0;

% Set Logfiles
if ~exist('Logfiles', 'dir')
    mkdir('Logfiles');
end
backupfile = fullfile('Logfiles', strcat('Bckup_Sub',num2str(particNum), '_digit-span_', DateTime, '.mat')); %save under name composed by number of subject and session

%% Instruction
keyName=''; % empty initial value
taskTimeStamp = GetSecs;
time.start = taskTimeStamp;

while ~strcmp(keyName,'Return')
    time.start = GetSecs;
    DrawFormattedText(win,char(instructions(language,1)),'center','center',[0 0 0]);
    Screen(win,'flip')
    time.end = GetSecs;
    [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Instructions', time);
    [secs, keyCode]=KbWait([],2);
    keyName{1}=KbName(keyCode);
    time.end = GetSecs;
    [Events, nbevents] = LogEvents(Events, nbevents, 'Button Press', keyName, secs);
    
end
Screen('TextSize', win, cfg.fontSizeBig);

%% Set Trials
task_trial=0; % counter
for block = 1:blocks;
    current_span = start_span;
    most_recent = NaN(1,num_to_change);
    
    for i=1:trials;
        time.start = GetSecs;
        task_trial=task_trial+1; % increases overall trial by 1 each trial, across blocks
%         trial_response=[];
        this_trial = digit_array(1:current_span, i, block);
        DrawFormattedText(win,'+','center','center',[0 0 0]);
        Screen(win,'flip');
        pause(2);
        time.end = GetSecs; 
        [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Fixation Cross', time); 

        %% Display the trial
        for k=1:length(this_trial);
            time.start = GetSecs; 
            DrawFormattedText(win,sprintf('%d',this_trial(k,1)),'center','center',[0 0 0]);
            Screen(win,'flip')
            pause(1)
            time.end = GetSecs; 
            [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Digit', time); 
%             framesSinceLastWait=Screen(win,'WaitBlanking',[1]);
            time.start = GetSecs;
            Screen(win,'flip')
            pause(0.05)
            time.end = GetSecs; 
            [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Gap', time); 
            
        end
        time.start = GetSecs;
        fill_space = repmat({'  _',}, 1, (length(this_trial)-1)); % make spaces indicating digits to be filled
        fill_space = strcat('_', fill_space{:}); 
        offcenter = cfg.screenCenter(1)+(2*cfg.fontSizeBig);
        DrawFormattedText(win,char(prompt(language,block)),'center',cfg.uppTextYpos,[0 0 0]);
        DrawFormattedText(win,char(fill_space),'center',cfg.offmidTextYpos,cfg.instColA);
        Screen(win,'flip')
        time.end = GetSecs; 
        [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Clear', time); 
             
        
        %% Type the number - subejct entry
        Start_trial = GetSecs;
        digit=0; % describes the changing length of entry within one trial
        trial_responseD=[];
%         trial_responseE=[];
        keyName=[];
        while ~strcmp(keyName,'Return')
 
        while digit<length(this_trial)
            RestrictKeysForKbCheck(cfg.limitedNumberKeys);
            
            response=[];
            [secs, keyCode, deltaSecs] = KbWait([],2);
            keyName{1}=KbName(keyCode);
            [Events, nbevents] = LogEvents(Events, nbevents, 'Button Press', keyName, secs); 
            if strcmp(KbName(keyCode), 'DELETE') || strcmp(KbName(keyCode), 'BackSpace')
                %GetEchoStringWhen(win, resp, screenrect(3)/2, screenrect(4)/2)
                if digit ~= 0
                    digit = digit-1;
%                     trial_response(end)=[];% delete final character of response 
                    %                     DrawFormattedText(win,char(trial_response),'center','center',[0 0 0]);
                    trial_responseD(end)=[]; % delete final character of response 
                end
            else 
                digit=digit+1;
                response=KbName(find(keyCode));
%                 responseF{digit,1}=KbName(find(keyCode));
%                 trial_response(digit)=response(1); % I don't know why but using a variable called "this_response" creates some super weird behavior
%                 trial_responseA(digit)=response(1); % I don't know why but using a variable called "this_response" creates some super weird behavior
%                 trial_responseB{digit}=KbName(find(keyCode)); % I don't know why but using a variable called "this_response" creates some super weird behavior
%                 trial_responseC{digit}=response; % I don't know why but using a variable called "this_response" creates some super weird behavior
                trial_responseD=[trial_responseD; str2double(response(1))]; % convert first character of response to a double and add it to the previous
%                 trial_responseE=[trial_responseE, response]; % I don't know why but using a variable called "this_response" creates some super weird behavior
%                 trial_responseF(digit)=responseF{digit,1}(1);
                %GetEchoStringWhen(in, this_response, screenrect(3)/2, screenrect(4)/2)
%                 Screen(win, 'flip')
                
            end
%             DrawFormattedText(win,char(trial_response),'center','center',[0 0 0]);
            time.start = GetSecs;
            DrawFormattedText(win,num2str(trial_responseD'),'center','center',[0 0 0]);
            DrawFormattedText(win,char(prompt(language,block)),'center',cfg.uppTextYpos,[0 0 0]);
            DrawFormattedText(win,char(fill_space),'center',cfg.offmidTextYpos,cfg.instColA);
            
            Screen(win, 'flip')
            time.end = GetSecs; 
            [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Current_response', time); 
            continue
        end
        time.start = GetSecs;
        DrawFormattedText(win,num2str(trial_responseD'),'center','center',[0 0 0]);
        DrawFormattedText(win,char(prompt(language,block)),'center',cfg.uppTextYpos,[0 0 0]);
        DrawFormattedText(win,char(fill_space),'center',cfg.offmidTextYpos,cfg.instColA);
        DrawFormattedText(win,char(continue_prompt(language)),'center',cfg.low1TextYpos,cfg.instColA); % prompt that return now allowed
        Screen(win, 'flip')
        time.end = GetSecs; 
        [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Sufficient_entries', time); 

        RestrictKeysForKbCheck(cfg.enabledNumberKeys); % allow return to be pressed
        
        [secs, keyCode, deltaSecs] = KbWait([],2);
        keyName{1}=KbName(keyCode);
        [Events, nbevents] = LogEvents(Events, nbevents, 'Button Press', keyName, secs);
            if strcmp(KbName(keyCode), 'DELETE') || strcmp(KbName(keyCode), 'BackSpace')
                digit = digit-1;
                trial_responseD(end)=[]; % delete final character of response 
                
                % redraw with backspace
                time.start = GetSecs;
                DrawFormattedText(win,num2str(trial_responseD'),'center','center',[0 0 0]);
                DrawFormattedText(win,char(prompt(language,block)),'center',cfg.uppTextYpos,[0 0 0]);
                DrawFormattedText(win,char(fill_space),'center',cfg.offmidTextYpos,cfg.instColA);
                
                Screen(win, 'flip')
                time.end = GetSecs;
                [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Current_response', time);

                continue % go back to previous while loop
            end
        continue
        end
        End_trial = GetSecs;
        %% Set data matrices
        if block==2
            this_trial = flip(this_trial);
        end
        
        trial_response_num=trial_responseD;
        this_outcome = isequal(this_trial, trial_response_num);
        most_recent = [most_recent(1,2:num_to_change), this_outcome];
        current_span = current_span+(sum(most_recent)==num_to_change)*(current_span<max_span)-(sum(most_recent)==0)*(current_span>min_span);  % if all correct, should sum to num to change, increase current_span by 1
        % if all incorrect, should sm to 0, decrease current_span by 1
        % if current_span goes above maximum, decrease by 1 to maximum
        % if current_span goes below minimum, increase by 1 to minimu
        if sum(most_recent)==num_to_change || sum(most_recent)==0
            most_recent = NaN(1,num_to_change);
        end
        
        trial_duration = (End_trial-Start_trial);
        
%         block_num(overall_trial(i,block)) = block;
%         Block_num(block, i) = block;
%         Length_Span(overall_trial(i,block)) = length(this_trial);
%         Response{overall_trial(i,block)} = this_response;
%         Outcome(overall_trial(i,block)) = this_outcome;
%         Trials{overall_trial(i,block)} = this_trial;
%         Reaction_Time(overall_trial(i,block)) = (End_trial-Start_trial);
%         [array2table(Length_Span'), array2table(Response'), array2table(Outcome'), array2table(Trials'), array2table(Reaction_Time')]
%         [Length_Span', {Response'}], array2table(Outcome'), array2table(Trials'), array2table(Reaction_Time')]
        
        temp_table = [block, i, task_trial, length(this_trial), {this_trial}, {trial_response_num}, this_outcome, trial_duration]; % make temp array of all variables from this trial to add to table
        digit_span_table = [digit_span_table; temp_table]; % add temp array to table
        pause(0.5)
%         block, i, overall_trial, digit_array{blocks, i}, prompt{blocks, i}, response{blocks, i}, outcome(blocks,i), reaction_time
%         block(overall_trial(i,blocks)=blocks, trial(overall_trial(i,blocks))=i, overall_trial(i,blocks)
    end % end trial loop for this block
    %%   Warning for the second block
    if block==1;
        keyName='';
        Screen('TextSize', win, cfg.fontSize);
        while ~strcmp(keyName,'Return')
            time.start = GetSecs; 
            DrawFormattedText(win,char(instructions(language,2)),'center','center',[0 0 0]);
            Screen(win,'flip')
            time.end = GetSecs; 
            [Events, nbevents] = LogEvents(Events, nbevents,  'Picture', 'Instructions Block 2', time); 
            [secs, keyCode]=KbWait([],2);
            keyName{1}=KbName(keyCode);
            [Events, nbevents] = LogEvents(Events, nbevents, 'Button Press', keyName, secs); 
        end

    end
    Screen('TextSize', win, cfg.fontSizeBig);
    final_length(block)=length(this_trial); % record the ending length of the span for each block
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
digit_span_table.Properties.VariableNames={'block', 'trial', 'overall_trial', 'span_length', 'prompt', 'response', 'outcome', 'duration'}; % variable names; must be amended if more variables added to table

%%Payment
wins = sum(digit_span_table.outcome);
payment = sum(wins*reward);

%% Create a table with all the results
% Trial_Span = Length_Span(:)
% Num_trials = [1:trials 1:trials]' 
% Block_num = Block_num(:)
% Block_num = block_num(:);
% Response = Response(:)
% Trials = Trials(:)
% Outcome = Outcome(:)
% Reaction_Time = Reaction_Time(:)
% Main_Data = [array2table(Block_num),array2table(Num_trials),cell2table(Trials),cell2table(Response),array2table(Trial_Span),array2table(Reaction_Time),array2table(Outcome)];

%% Save Variables
% save digit array, this_trial, this_response, this_outcome,% most_recent
digit_span_table.Properties.VariableNames={'block', 'trial', 'overall_trial', 'span_length', 'prompt', 'response', 'outcome', 'duration'}; % variable names; must be amended if more variables added to table

save([ particNum '-' num2str(DateTime) '_4digitspan'], 'particNum','digit_span_table','final_length','wins','payment', 'Events');



% sca;


% save(['sub' num2str(particNum) '-' num2str(DateTime) '_2beauty_contest'], 'particNum', ...
%     'beauty_calc_subResultsTable', 'beauty_contest_subResultsTable');
end
