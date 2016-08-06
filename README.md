# MATLAB_PTB_Questionnaire
Display a questionnaire using psychtoolbox, and get input from keyboard, mouse, or gamepad

### --2016/08/06 update--
Changed:
- Keyboard: Instead of using left and right arrow to select answers, now I use number keys (1 to 9) to do selecting. This idea is from Yaguchi.<br /> Also, the enter (or return) key now used as "go to next question", where up and down arrow are used for quick navigation.
- Gamepad: Now I use left stick for select questions and answers. This idea is from Miyakawa.<br /> Besides that, hold the stick will enable the quick navigation.

### --2016/08/02 update--
Added:
- Support for gamepad

- On my PC, the configuration is done for OS - Ubuntu and gamepad - Logitech Gamepad F310, the configuration file is uploaded too in "etc" folder. Read the >> help GamePad for more details about this file.
- You may need to modify the configuration file to support for gamepad on your PC.

### --2016/07/31 update--
Added:
- Support for mouse

Set which device (mouse or keyboard for now) to use in the Mainloop.m

Also changed how the rects generate a bit to support mouse functions.

- About the memory insufficiency problem, it seems that when there are too many questions, the texture rect gets too big, and that would cause an error.
- I don't know the threshold that would cause this problem; but in later update, I will implement a page function which would contain multiple textures with a proper number of questions to avoid this problem

### --2016/07/30 update--
Added:
- Support for likert survey.

Now it is the 3rd version of the code. The code changed a bit at how the rects for identifying the selection are generated.

The 2nd version generates all rects in advance, which will break when there are too many questions which would cause a memory insufficiency.

In this new version, the rects will be generated real time. Which means the same time you pressed space. **However**, the code that draws the rects becomes very ugly. This need to be rewrote later.

----------------------------------------------

Run a demo by executing Mainloop.m
> the loop will automatically quit after all questions been answered

> however, you need to use sca manually to clean the screen, for now

## Control keys:
#### Keyboard:
1. Arrow keys -- Up, down for quickly navigate question; 
2. Number keys -- Select an answer; 
3. Return -- Go to next question

#### Mouse:
1. Any key click would do.
2. Move mouse to the top edge or bottom edge to scroll. (I use this because that linux don't support GetMouseWheel function ORZ)

### Gamepad:
1. B to make choice
2. Left stick -- hold it to up or down to select questions; hold it left or right to select answers; hold still for quick navigation

## Todo:

1. save selections to a file
2. Is there a way to register key-press instead of the ugly(?) "~~if elseif end~~ swtich".
3. ~~Support for mouse and gamepad~~
4. ~~Rewrote the code that draws rects~~
5. Deal with large file


## License
For personal practice or learning, play with it freely;)

For scientific research or experiment, please reference this using:
> TOSHINAKI et al.. (2016). MATLAB_PTB_Questionnaire: 2016/08/06 first release. Zenodo. 10.5281/zenodo.59760

For other purpose, do contact me!
