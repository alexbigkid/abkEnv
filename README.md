# ⚠️ DEPRECATED
Further development has moved to [abk_env](https://github.com/alexbigkid/abk_env/) The MacOS/Linux Environment has been renamed to abk_env. <b>It is recommended to run <code>./uninstall.sh</code> script from this repo, before starting to use new environment setup in abk_env.</b>


# :octocat: abkEnv - environment on Mac and Windows :octocat:
Setting up bash or zsh on Mac and PowerShell on Windows


## Screenshot of abkEnv on MacOS
![abkEnv MacOS zsh](docs/abkEnv_MacOS_zsh.jpg?raw=true "abkEnv in terminal")


## MacOS (bash or zsh shell)
After cloning the abkEnv repository, to install execute
```html
./install_abkEnv.sh
```


### MacOS shells supported by abkEnv
- [x] /bin/bash
- [ ] /bin/csh
- [ ] /bin/ksh
- [ ] /bin/sh
- [ ] /bin/tcsh
- [x] /bin/zsh


### MacOS Prerequisites
| tool      | description                                                  |
| :-------- | :----------------------------------------------------------- |
| home brew | brew is a command line tool to install apps and tools on Mac |

- to install brew:
```html
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


### MacOS zsh additional tool installations
| tool                | description                                                                                                     |
| :------------------ | :-------------------------------------------------------------------------------------------------------------- |
| oh-my-zsh           | It will be installed automatically in ~/.oh-my-zsh                                                              |
| autosuggestion      | zsh plugin will be installed automatically into the ~/.zsh/custom/plugins/zsh-autosuggestions                   |
| syntax-highlighting | zsh plugin will be installed automatically into the ~/.zsh/custom/plugins/zzsh-syntax-highlighting              |
| Cascadia fonts      | Cascadia fonts needed to display power line symbols. It will be installed, but config needs to be done manually |


### MacOS bash additional tool installations
| tool           | description                                                                                                     |
| :------------- | :-------------------------------------------------------------------------------------------------------------- |
| oh-my-bash     | It will be installed automatically in ~/.oh-my-bash                                                             |
| abk_pl         | powerline custom theme will be installed into custom/themes/abk_pl                                              |
| history        | default config of the the oh-my-bash has a bug it will be corrected in lib/history.sh                           |
| Cascadia fonts | Cascadia fonts needed to display power line symbols. It will be installed, but config needs to be done manually |


### MacOS default shell config:
- to check which shell your terminal is running: echo $SHELL
- if you want to change to bash: chsh -s /bin/bash
- if you want to change to zsh: chsh -s /bin/zsh


### MacOS Terminal: powerline 10k configuration (supported only by zsh)
- if you changed to zsh shell for first time, you will be automatically requested to configure powerline 10k
- to customize your powerline 10k prompt, execute: p10k configure
- follow the p10k config steps to your liking
- the p10k configuration is saved in the file: ~/.p10k.zsh
- the p10k is initialization is happening in the ~/.zshrc. You will see p10k line added after executing: p10k configure


### MacOS Terminal: custom theme and font configuration
- open terminal app
- Press: <kbd>&#8984;</kbd> + <kbd>,</kbd> or from Menu: Terminal / Preferences
- select Profile tab
- Click on "..." and select Import
- e.g. select one of the predefined terminal themes from this repo. E.g.: macBin/env/themes/abk_pl.terminal
- set the imported theme as default by clicking on "Default"
- Close terminal with: <kbd>&#8984;</kbd> + <kbd>q</kbd> and re-open terminal app

### MacOS Visual Studio Code: Integrated Terminal font configuration
- open vscode app
- Press: <kbd>&#8984;</kbd> + <kbd>,</kbd> or from Menu: Code / Preferences / Settings
- search for: "Font Terminal"
- Set for "Terminal > Integrated: Font Family": 'CaskaydiaCove Nerd Font'

### MacOS Visual Studio Code: Editor font configuration
- open vscode app
- Press: <kbd>&#8984;</kbd> + <kbd>,</kbd> or from Menu: Code / Preferences / Settings
- search for: "Editor: Font Family"
- Make sure that for "Editor: Font Family" entry the font 'Cascadia Code PL' is 1st in the list of comma separated font names


## Windows 10 (PowerShell)
After cloning the abkEnv repository, to install execute
```html
install_abkEnv.ps1
```

The installation on Windows has many manual steps, which still needs to be improved. SInce I don't own  a Windows PC it is hard to automate it.
However when I get a Windows computer, I will make it happen in more automatic way. But for now I would recommend the description of 2 following setup descriptions
- [by Christian](https://www.the-digital-life.com/awesome-wsl-wsl2-terminal/)
- [by Scott Hanselmann](https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup)


#### Tested working on:
- [x] MacOS
- [x] Windows 10
- [x] Linux Debian
- [x] Linux Ubuntu


:checkered_flag:
