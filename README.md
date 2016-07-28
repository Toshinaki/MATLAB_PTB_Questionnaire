# MATLAB_PTB_Questionnaire
Display a questionnaire using psychtoolbox, and get input from keyboard, mouse, or gamepad

It is a new version. The code itself didn't change too much; I just arranged the code to make it easier to integrate with other PTB experiments.

The code in folder oldVer can be executed individually.

**Make sure the oldVer folder is not at same path with Mainloop.m.** Some functions of old and new have same name, and this may cause some unanticipated error.

Run a demo by executing Mainloop.m
> the loop will automatically quit after all questions been answered
> however, you need to use sca manually to clean the screen, for now

## Control keys:

1. Arrow keys -- up, down for question; left, right for answer
2. Space key -- select current answer (somehow the enter key can't be detected during the loop)

## Todo:

1. save selections to a file
2. Is there a way to register key-press instead of the ugly "if elseif end".
3. Support for mouse and gamepad