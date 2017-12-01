clear all
clc
%
%
%
%
% %% Computer number and date to generate participant number
% % compNum = '99';
% % screen_setup = 2; % number of screens
% %
% % % Uncomment INLAB
% % compNum = input('Type the two-digit computer number/Inserisci le due cifre sopra il tuo computer e premi "Invio": ', 's');
% %
% % switch isempty(compNum)
% %     case 1 %deals with both cancel and X presses
% %         compNum = input('Type the two-digit computer number/Inserisci le due cifre sopra il tuo computer e premi "Invio": ', 's');
% %         return
% %     case 0
% %         if length(compNum) ~= 2 || str2num(compNum) <= 0 || str2num(compNum) >= 25
% %             compNum = input('Type the two-digit computer number/Inserisci le due cifre sopra il tuo computer e premi "Invio": ', 's');
% %             return
% %         end
% % % end
% % if isempty(compNum)
% %    disp('Now you have to start over.');
% %    return
% % end
%
% % Automatic date entry
% if str2num(datestr(now,'HHMM')) < 1100
%     insertDate = [datestr(now,'ddmm'), 'amA'];
% elseif str2num(datestr(now,'HHMM')) < 1500
%     insertDate = [datestr(now,'ddmm'), 'pmB'];
% else
%     insertDate = [datestr(now,'ddmm'), 'pmC'];
% end
% particNum = [insertDate, num2str(compNum)];
%
% %% VARIABLES
% DateTime = datestr(now,'ddmm-HHMM'); % Get date and time for log file
%% Set Constant
num_trials= [1:5]
trials = 5;
block = [1 2]; % one forward, one backwards
num_to_change = 3;
max_span = 8;
min_span = 3;
start_span = 5;
digit_array = randi(9, max_span, trials*length(block)); % construct all possible trials
KbName('UnifyKeyNames');RestrictKeysForKbCheck([8, 96:105]);
    
%%Open PTB
Screen('Preference', 'SkipSyncTests', 0);
[win,screenrect]=Screen('OpenWindow',0,[255 255 255],[0 0 800 600]);
%% Instruction
DrawFormattedText(win,'Now You will be shown a string of numbers. \n  You have to remember them \n and then digit them in the same order \n Press "backspace" if you have understood the task','center','center',[0 0 0]);
Screen(win,'flip')
KbWait;

%% Set Trials
for blocks = 1:length(block);
    digit_array = randi(9, max_span, trials*length(block)); % construct all possible trials
    current_span = start_span;
    most_recent = NaN(1,num_to_change);
    for i=1:trials;
        this_response=[];
        this_trial = digit_array(1:current_span, i);
        DrawFormattedText(win,'+','center','center',[0 0 0]);
        Screen(win,'flip');
        pause(2);
        %% Display the trial
        for k= 1:length(this_trial);
            DrawFormattedText(win,sprintf('%d',this_trial(k,1)),'center','center',[0 0 0]);
            Screen(win,'flip')
            pause(1)
            framesSinceLastWait=Screen(win,'WaitBlanking',[1])
            Screen(win,'flip')
            pause(0.1)
            
            
        end
        
        
        %% Type the number
        Start_trial = GetSecs
        digit=0;
        while digit<length(this_trial)
            [secs, keyCode, deltaSecs] = KbWait([],2);
            if ~strcmp(KbName(keyCode), 'BackSpace')
                digit=digit+1;
                resp=KbName(keyCode);
                this_response(digit)=resp(1);
                DrawFormattedText(win,this_response,'center','center',[0 0 0]);
                %GetEchoStringWhen(in, this_response, screenrect(3)/2, screenrect(4)/2)
                Screen(win, 'flip')
            elseif strcmp(KbName(keyCode), 'BackSpace')
                %GetEchoStringWhen(win, resp, screenrect(3)/2, screenrect(4)/2)
                if digit == 0
                    digit = 0
                else
                    digit = digit-1;
                    this_response(end)=[];
                    DrawFormattedText(win,this_response,'center','center',[0 0 0]);
                    Screen(win, 'flip')
                end
            end
        end
        End_trial = GetSecs
        %% Set data matrices
        if blocks==2
            this_trial = flip(this_trial)
        end
        
        this_response=this_response';
        this_outcome = isequal(this_trial, this_response);
        most_recent = [most_recent(1,2:num_to_change), this_outcome];
        current_span = current_span+(sum(most_recent)==num_to_change)*(current_span<max_span)-(sum(most_recent)==0)*(current_span>min_span);  % if all correct, should sum to num to change, increase current_span by 1
        % if all incorrect, should sm to 0, decrease current_span by 1
        % if current_span goes above maximum, decrease by 1 to maximum
        % if current_span goes below minimum, increase by 1 to minimu
        Block_num(blocks, i) = blocks
        Length_Span(blocks, i) = length(this_trial)
        Response{blocks, i} = this_response;
        Outcome{blocks, i} = this_outcome;
        Trials{blocks, i} = this_trial;
        Reaction_Time(blocks, i) = (End_trial-Start_trial)
    end
    %%   Warning for the second block
    if blocks==1;
        DrawFormattedText(win,'now you are entering in the second part of the experiment \n in This part you have to remember the string of number \n and then type them in the opposite order \n\n\n Press BackSpace if you are ready to continue','center','center',[0 0 0]); % end trial loop for this block
        Screen(win,'flip')
        pause(4)
        KbWait
    end
end
sca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Payment
outcome = cell2mat(Outcome(:));
outcome = sum(outcome)
Payment = sum(outcome*0.50);

%% Create a table with all the results
Trial_Span = Length_Span(:)
Num_trials = [1:max(num_trials) 1:max(num_trials)]' 
Block_num = Block_num(:)
Response = Response(:)
Trials = Trials(:)
Outcome = Outcome(:)
Reaction_Time = Reaction_Time(:)
Main_Data = [array2table(Block_num),array2table(Num_trials),cell2table(Trials),cell2table(Response),array2table(Trial_Span),array2table(Reaction_Time),array2table(Outcome)]


%% Save Variables
% save digit array, this_trial, this_response, this_outcome,% most_recent
%save([ particNum '-' num2str(DateTime) '_9all'], 'particNum','Response','Trials','Outcome','Payment');





% save(['sub' num2str(particNum) '-' num2str(DateTime) '_2beauty_contest'], 'particNum', ...
%     'beauty_calc_subResultsTable', 'beauty_contest_subResultsTable');

