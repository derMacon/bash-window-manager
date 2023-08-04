# Bash Window Manager

Utility that provides hotkey navigation between opened windows.

## Configuration
- clone repo and copy the complete path of the script
- go to the keyboard settings page and create a new custom shortcut e.g. alt + 1
- in the command section of the setting enter the previously copied script path and provide any unique
  character as the memory slot identifier as a parameter for the script in the command section
- save the settings 

## Usage
- click on the window which should be in the direct access via shortcut
- press the configured shortcut to set the memory slot for the current window
- navigate to any other window and press the shortcut, now the previously configured window should open
- to toggle the view simply press the shortcut again
- to reset the memory slots, configure another custom shortcut that takes in the letter 'r' as its argument

## Todo
- [ ] implement a quick blink animation when window is changed
- [ ] implement a config template where window workspaces can be deposited
- [ ] insert usage demo gif into readme
