# dots-core
This project aims to be a solution to a common problem for people with a lot of different linux rices, and while it should work fairly dynamically it requires you to follow a certain structure that is catered around how my setups work. 
This structure aims to separate the, for a lack of a better word, 'backend' section of a linux rice from the styles, and then uses a script that links everything together into a form that actually works. Most people use the same binds for different configs anyway, so i find it makes no sense to keep it separate and have to update every configuration manually for each little change.

## What it contains
- the 'logical' section of the dotfiles (binds, shared plugins and so on) - the things that i want to keep shared between all of my configs while not having to update each repo individually when making a change
- some shared utility scripts
- dedicated switcher/linker scripts for both the core files and the stylea dedicated 'rice switcher's

## Structure
the correct directory structure looks like this: 
> [!WARNING]
> if you don't uphold this the switcher script will break!!

```
~/dotfiles
├── dots-core    -- here you keep whole app folders with the names you would use in .config (for example nvim, btop) but with the styles removed from here
│   └── switcher -- the switcher scripts live here, this is the only directory that dosen't get linked
└── rices        -- inside of this directory you hold the actual rices (eg. rices/miku-teto/ or rices/inabashell/) inside of which you put the theme files in the corresponding app folders
```

each of the rice directories also needs to contain a manifest.json file that looks like this: 
```json
{
    "services": [
        "service 1",
        "service 2"
    ],
    "one_time": [
        "set wallpaper",
        "copy file"
    ]
}
```
with the placeholders being replaced by actual commands for the switcher to run

## Running the scripts
### first, ensure that you've backed up the data from .config of the programs that will get linked

running the core linker script is as simple as
```sh
./link-core.sh
```

once you've done that, you can move on to the switcher:
```sh
./switch.sh $riceName
```
with `$riceName` being the name of a directory from rices/

if you then run the switcher again just with a different rice, it will update all the styles and refresh the related apps for you

## Child repos
links TBA
