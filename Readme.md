# gceditor
![](https://lh3.googleusercontent.com/SMTg3mBfDII93jpm2JGY_hIREmpwtiH7ds9XZHayvUb76m4ynBAoX6ecBMd9O7zTy4O5imbD1CPdjUB4rOcx=w2560-h1297)

### Description
The application allows you to create and edit json-formatted config file in a table-like way. It is designed to solve common game configuring tasks like adding entities, references to entities, parameters, localization; advanced search, integrity validation.

Written in Actionscript 3.0. Requires Adobe Air to launch.

### Features
- simple to install and use standalone app;
- produces VCS-friendly JSON: it is easy to find changed values in every version;
- table configuration can be easily changed at any time;
- it is easy to refer to any existing entity by its Id;
- a lot of usable preset cell types:
  - integer;
  - float;
  - string;
  - multiline string;
  - boolean;
  - text pattern (for localization);
  - reference (to refer other entities by Id);
  - date;
  - path to file (with images preview);
  - inner table (to create minor tables inside major table cells);
- editor-integrated localization solution;
- popup windows for quick editing and exploring of referenced values;
- advanced search including references search;
- integrity validation, missing values notification;
- commands history with undo-redo for every action;
- it is possible export to few variations of json format (beautified, ordered, minimized);
- it is easy to integrate custom serializer using source code;

### Screenshots
![](https://lh5.googleusercontent.com/TQQmnbYF2L4TuYI82iYaov0beD89MVUqWu4HcEnK3CW2udiwmYGAXezdmDHF1e5Es_5S7MhZT04x_O3kjJD-=w2560-h1297-rw)

![](https://lh4.googleusercontent.com/GI2HhCTmhS05xs6ppQNq7Rd3rWvpB4yW2zEFQIM8HStv40qNU_dxr0qUkhpKzlDlfwFJBJcIeDTaEouVMLxI=w2560-h1297-rw)

![](https://lh3.googleusercontent.com/07fnURMsFPJt7hAHBcNCLu15M-23upBk9FBhvrZLO1NBN_OTtUBiGo52AChCPeTgxu_t4T7mQ-Fys1skIsAz=w2560-h1297-rw)

![](https://lh4.googleusercontent.com/W36N81WEyISGTexa_8hZlpNbj3eN-sXRZ--A9YVXXIb8YYacs495KNaIczvYrRstAXjoPUZNA_NF02jEu5au=w2560-h1297-rw)

![](https://lh3.googleusercontent.com/slKNAValPy-i3CgTl3QJ1xzB_7ieCfiQdCCBCyMEKHoEgEq16gAXj1A7mSZPMtO2JulQGLVp_rSSRjdZWumN=w2560-h1297-rw)

### JSON Example
[JSON default](https://pastebin.com/SRJSFrTS "JSON default") - Default format including all data and metadata. **Can** be loaded in the application.

[JSON reduced](https://pastebin.com/KpFwXRws "JSON reduced") - Reduced format for more convinient representation. **Can not** be loaded in the application. This format is much easier to parse in a game.

### Installation
Execute air/gceditor.air file to install the application. Windows and macOs are supported.