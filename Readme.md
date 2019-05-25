# gceditor
![](https://drive.google.com/uc?id=1Nc74z_4mMUv8VsqA6jK7CBlK9rG3IID-)

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
![](https://drive.google.com/uc?id=1wS3XA9oId6ucexzDAICvmZ3jMZaE9ON2)

![](https://drive.google.com/uc?id=1uZi_lh9pFZ3JAmuoSY3xsZpNz33qaf1r)

![](https://drive.google.com/uc?id=1eOE7Ek1-83OaU-5Ir-gU-bMCBw2XcFLb)

![](https://drive.google.com/uc?id=1CYVdYC_2HCLCFG1wf0C22tIsSjN29IQ7)

![](https://drive.google.com/uc?id=1sBOv8-iN0jmUm2uKWUFFOiHd0bZYyFFx)

### JSON Example
[JSON default](https://drive.google.com/uc?id=1nUc1fe0_dyHphsCbIUKmLuoCKJpxI6PO "JSON default") - Default format including all data and metadata. **Can** be loaded in the application.

[JSON reduced](https://drive.google.com/uc?id=1bOCDCkuvJi2r7bkECmK-NNa_f2fY-szu "JSON reduced") - Reduced format for more convinient representation. **Can not** be loaded in the application. This format is much easier to parse in a game.

### Installation
Execute air/gceditor.air file to install the application. Windows and macOs are supported.