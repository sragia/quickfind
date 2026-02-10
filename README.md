![QuickFind](https://i.imgur.com/UjhgORC.png)

[![Discord Badge](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=fff&style=flat)](https://discord.gg/F8bhZUvQfz) [![GitHub Badge](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=fff&style=flat)](https://github.com/sragia/quickfind)

## **Quickly find actions you want to take**

Currently in very early development in terms of features, but main functionality is working.

![Addon In Action](https://i.imgur.com/WysNyYA.gif "Addon In Action")

### **What the hell is it? And why?**

Created from frustration of having to find dungeon portal in spellbook. Inspired by different IDE quick action functionality.

Esentially what this is, is a quick way to find some kind of action you want to take - Cast a spell, Use a toy or item, but don't want to put them on your action bars, this might help you.

## **Presets**

Currently there are some presets you can use to remove the need to adding everything yourself

To access it type `/qf` and press **Presets** button at top right of the window.

#### Currently available presets

![](https://i.imgur.com/M3vgGVH.png)

- **Mounts** - Shows all of your mounts that you have learned. At the moment, you need to reload/relog to show mounts that you have learned in the current session
- **Instance Portals** - Shows all portals to the dungeons/raids that are available. Currently there's 2 of the Siege of Boralus ones listed (horde/alliance) so just chose currect one or disable one you don't need. Maybe will fix it SoonTM
- **Bosses** - Pulls up boss in your Encounter Journal quickly
- **Interface Panels** - Allows you to open different interface windows quickly. Also works with all of your addons that have been added to Interface - Addons
- **Toys** - All of your learned toys

Presets can be editted or disabled individually too. Like mentioned for instance portals, you can disable portal completely if you don't want to see it. Or if you want to change the name or add some more keywords to search with you can do that.

![](https://i.imgur.com/nSts2hv.gif)

If you disable something that you want back, you can revert all changes for that specific preset or all presets in Presets window.

![](https://i.imgur.com/aJQP0zr.png)

### **How does this thing works?**

Press key combination - `Ctrl + P` (Changeable in Keybindings) and this will open up search input. Type anything in there and any suggestions that match your input will show up. From then on just press Enter to do the action of active suggestion or use arrow keys (or tab) to go between the results. Or just click with your mouse, whichever you prefer.

By default nothing will be here. Use previously mentioned Presets feature to add some or create your own.

![](https://i.imgur.com/JomCIfM.png)

To open setting type `/qf` or `/quickfind`. Here you can manage all your search results.

As of writing this you have these options:

- Type - What kind of action this will be - Spell, Item, Toy, Mount or Lua
- Spell ID - For Spell types only. Spell ID you want to cast when this action is actived
- Mount Name - For Mount types only. Name of the mount you want to summon
- Item ID - For Item and Toy types. Same as spell ID, will use this item when activated
- Name - What name you want to see when suggestion is shown
- Tags - Additional text that is being used for search. Maybe you don't want to start typing long name like Court of Stars, but just want to type "cos", add it here and it will find it
- Icon ID - Icon ID that is shown next to the result. Can be easily found on sites like Wowhead
- Open Editor (Lua only) allows you to write some script that you want to be executed when this suggestion is activated. This currently is not executed in secure environment.

## **Styles**

You can choose between 2 styles currently of how your results will show up. You can switch between them in Settings

### Default

![](https://i.imgur.com/DPltaei.png)

### Compact

![](https://i.imgur.com/SVWMpsb.png)

## API

Other addon developers can add their own results to QuickFind using `QuickFind:RegisterSource` API

Read how to use it [here](https://github.com/sragia/quickfind/wiki/API)
