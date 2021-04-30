# :octocat: abkEnv - environment on Mac and Windows :octocat:
Setting up bash or zsh on Mac and PowerShell on Windows


## Screenshot of abkEnv on MacOS
![abkEnv MacOS zsh](docs/abkEnv_MacOS_zsh.jpg?raw=true "abkEnv in terminal")


## MacOS (bash or zsh shell)
After cloning the abkEnv repository, to install execute
```html
    ./install_abkEnv.sh
```


## MacOS Prerequisites
| tool      | description                                                  |
| :-------- | :----------------------------------------------------------- |
| home brew | brew is a command line tool to install apps and tools on Mac |

- to install brew:
```html
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


## MacOS zsh additional tool installations
| tool                | description                                                                                                     |
| :------------------ | :-------------------------------------------------------------------------------------------------------------- |
| oh-my-zsh           | It will be installed automatically in ~/.oh-my-zsh                                                              |
| autosuggestion      | zsh plugin will be installed automatically into the ~/.zsh/custom/plugins/zsh-autosuggestions                   |
| syntax-highlighting | zsh plugin will be installed automatically into the ~/.zsh/custom/plugins/zzsh-syntax-highlighting              |
| Cascadia fonts      | Cascadia fonts needed to display power line symbols. It will be installed, but config needs to be done manually |

## MacOS bash additional tool installations
| tool           | description                                                                                                     |
| :------------- | :-------------------------------------------------------------------------------------------------------------- |
| oh-my-bash     | It will be installed automatically in ~/.oh-my-bash                                                             |
| abk_pl         | powerline custom theme will be installed into custom/themes/abk_pl                                              |
| history        | default config of the the oh-my-bash has a bug it will be corrected in lib/history.sh                           |
| Cascadia fonts | Cascadia fonts needed to display power line symbols. It will be installed, but config needs to be done manually |





## Windows 10 (PowerShell)
After cloning the abkEnv repository, to install execute
```html
    ./install_abkEnv.ps1
```

The installation on Windows has many manual steps, which still needs to be improved. SInce I don't own  a Windows PC it is hard to automate it.
However when I get a Windows computer, I will make it happen in more automatic way. But for now I would recommend the description of 2 following setup descriptions
- [by Christian](https://www.the-digital-life.com/awesome-wsl-wsl2-terminal/)
- [by Scott Hanselmann](https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup)


#### Tested working on:
- [x] MacOS Big Sur
- [x] MacOS Catalina
- [x] Windows 10
- [ ] Linux (not working at the moment)


:checkered_flag:
