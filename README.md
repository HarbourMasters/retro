![Retro Logo](https://user-images.githubusercontent.com/60364512/228030301-f2139d22-48da-412b-9862-8f72e471e89c.png#gh-dark-mode-only) 

![Retro Logo](https://user-images.githubusercontent.com/60364512/228030177-6b7a51f2-fe24-4ce4-8235-8d35f2526250.png#gh-light-mode-only)
An OTR generation tool.

## What is Retro?

Retro is a modding tool for games using the OTR file format. Currently only [Ship of Harkinian](https://github.com/HarbourMasters/Shipwright) uses this format.

All game assets are contained within an OTR file, the system can also recognize patch OTRs, placed in a `mods/` folder, which will replace any assets with the ones found in the patch OTR.

You can download the latest build from [here](https://github.com/HarbourMasters64/retro/releases/latest).

## Custom Textures

- Select `Create OTR`
- Select `Replace Textures`
- Follow the in-app instructions for getting set up.

Once you have your textures extracted, enter that folder, find the textures you want to replace, and replace them. Do not worry about the textures you don't want to change, Retro only puts the modified assets into the patch OTR.

Once you've modified your desired textures, go back into Retro and now that you have a texture replacement folder, select the `OOT` folder inside of it.

Make sure to enable the `Prepend 'alt/'` option, this will allow quick switching between modified assets and vanilla assets with the ingame checkbox.

Please give it a few minutes to parse all of your textures, with larger packs with a lot of high resolution textures this may take a while. Once it has completed, click `Stage Textures`, then `Finalize OTR`, then `Generate OTR`. Again, with very large packs this can take a long time, even on powerful systems.

It will prompt you to name your OTR file, and you can now place it inside the mods folder for your game.

## Custom Sequences

We support importing custom [Seq64](https://github.com/sauraen/seq64) files to replace the in game music and fanfares (Sound effect and instrument replacement is currently not supported).

First you will need to prepare a folder with the desired sequences. Every sequence requires two files with the same name and different extensions - a `.seq` Seq64 file and a `.meta` plaintext file. These files can be categorically nested in folders if desired, - Retro will recursively search each subfolder it finds.

The `.meta` file requires two lines - the first line is the name that will be displayed in the SFX editor, and the second line is the instrument set number in `base16` format. For example, if there is a sequence file `Foo.seq` then you need a meta file `Foo.meta` that could contain:
```
Awesome Name
C
```

- Select Create OTR
- Select `Custom Sequences`
- `Stage Files`
- `Finalize OTR`
- Place the OTR file this generates inside of your `mods/` folder.

### i18n localization rules

When adding any text to retro, be sure to make it localizable by doing the following
- Make sure that `import 'package:flutter_gen/gen_l10n/app_localizations.dart';` is properly imported in the file you're adding any kind of text.
- Make sure to also have this `final AppLocalizations i18n = AppLocalizations.of(context)!;`present in the override.
- When it's the time for you to add your text, follow this naming convention:
    - When you're adding a key in a **component**, use this: `i18n.components_myFile_keyName`
    - When you're adding a key somewhere else, use this: `i18n.myFile_keyName`
    - Add the corresponding keys in both `app_en.arb` which will contain your text.
    - When you're adding new text, please notify it so we can translate your new keys as fast as we can.
