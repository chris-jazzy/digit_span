% function [wins, payment, final_length]=digit_span(particNum, DateTime, window, trials, max_span, min_span, num_to_change)

clear all
% clc

% % DELETE WHEN CONVERTED TO FUNCTION
particNum=99;
DateTime=0000;


%% Set Variables
% num_trials= [1:5];
trials = 5;
blocks = 2; % one forward, one backwards
num_to_change = 3;
max_span = 8;
min_span = 3;
start_span = 5;
overall_trial = (1:trials*blocks)';
digit_array = randi(9, max_span, trials, blocks); % construct all possible trials

% Pre-allocate
block_num = NaN(blocks*trials,1);
digit_span_table = table; % create table to be filled in trial by trial

KbName('UnifyKeyNames');
% RestrictKeysForKbCheck([8, 96:105]);
    
%%Open PTB
% one-screen setup
Screen('Preference', 'SkipSyncTests', 0);
[win,screenrect]=Screen('OpenWindow',0,[255 255 255],[0 0 800 600]); 

% % for two-screen setup
% Screen('Preference', 'SkipSyncTests', 1);
% [win, windowRect] = Screen('OpenWindow', 1,[255 255 255]); 

%% Instruction
DrawFormattedText(win,'Now You will be shown a string of numbers. \n  You have to remember them \n and then digit them in the same order \n Press "backspace" if you have understood the task','center','center',[0 0 0]);
Screen(win,'flip')
KbWait;

%% Set Trials
task_trial=0; % counter
for block = 1:blocks;
    current_span = start_span;
    most_recent = NaN(1,num_to_change);
    
    for i=1:trials;
        task_trial=task_trial+1; % increases overall trial by 1 each trial, across blocks
        trial_response=[];
        this_trial = digit_array(1:current_span, i, block);
        DrawFormattedText(win,'+','center','center',[0 0 0]);
        Screen(win,'flip');
        pause(2);
        %% Display the trial
        for k=1:length(this_trial);
            DrawFormattedText(win,sprintf('%d',this_trial(k,1)),'center','center',[0 0 0]);
            Screen(win,'flip')
            pause(1)
%             framesSinceLastWait=Screen(win,'WaitBlanking',[1]);
            Screen(win,'flip')
            pause(0.05)
            
            
        end
        
%         k=1;
%         while k<5
%         [secs, keyCode, deltaSecs] = KbWait([],2);
%         if strcmp(KbName(keyCode), 'BackSpace')
%         k=k-1;
%         else
%         k=k+1;
%         input=KbName(keyCode);
%         trial_input(k)=input(1);
%         end
%         continue
%         end
        
        
        %% Type the number - subejct entry
        Start_trial = GetSecs;
        digit=0; % describes the changing length of entry within one trial
        trial_responseD=[];
        trial_responseE=[];
        while digit<length(this_trial)
            response=[];
            [secs, keyCode, deltaSecs] = KbWait([],2);
            if strcmp(KbName(keyCode), 'Delete')
                %GetEchoStringWhen(win, resp, screenrect(3)/2, screenrect(4)/2)
                if digit == 0
                    %                     digit = 0;
                else
                    digit = digit-1;
                    trial_response(end)=[];
                    DrawFormattedText(win,char(trial_response),'center','center',[0 0 0]);
                    Screen(win, 'flip')
                end
            else 
                digit=digit+1;
                response=KbName(find(keyCode));
                responseF{digit,1}=KbName(find(keyCode));
                trial_response(digit)=response(1); % I don't know why but using a variable called "this_response" creates some super weird behavior
                trial_responseA(digit)=response(1); % I don't know why but using a variable called "this_response" creates some super weird behavior
                trial_responseB{digit}=KbName(find(keyCode)); % I don't know why but using a variable called "this_response" creates some super weird behavior
                trial_responseC{digit}=response; % I don't know why but using a variable called "this_response" creates some super weird behavior
                trial_responseD=[trial_responseD; str2double(response(1))]; % I don't know why but using a variable called "this_response" creates some super weird behavior
                trial_responseE=[trial_responseE, response]; % I don't know why but using a variable called "this_response" creates some super weird behavior
                trial_responseF(digit)=responseF{digit,1}(1);
                DrawFormattedText(win,char(trial_response),'center','center',[0 0 0]);
                %GetEchoStringWhen(in, this_response, screenrect(3)/2, screenrect(4)/2)
                Screen(win, 'flip')
                
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

%         block, i, overall_trial, digit_array{blocks, i}, prompt{blocks, i}, response{blocks, i}, outcome(blocks,i), reaction_time
%         block(overall_trial(i,blocks)=blocks, trial(overall_trial(i,blocks))=i, overall_trial(i,blocks)
    end % end trial loop for this block
    %%   Warning for the second block
    if block==1;
        DrawFormattedText(win,'In this part of the task, remember the string of numbers \n and type them in the opposite order \n\n\n Press ''BackSpace'' when you are ready to continue','center','center',[0 0 0]); 
        Screen(win,'flip')
        pause(4)
        KbWait
    end
    final_length(block)=length(this_trial); % record the ending length of the span for each block
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
digit_span_table.Properties.VariableNames={'block', 'trial', 'overall_trial', 'span_length', 'prompt', 'response', 'outcome', 'duration'}; % variable names; must be amended if more variables added to table

%%Payment
wins = sum(digit_span_table.outcome);
payment = sum(wins*0.50);

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

save([ particNum '-' num2str(DateTime) '_9all'], 'particNum','digit_span_table','final_length','wins','payment');



sca;


% save(['sub' num2str(particNum) '-' num2str(DateTime) '_2beauty_contest'], 'particNum', ...
%     'beauty_calc_subResultsTable', 'beauty_contest_subResultsTable');

