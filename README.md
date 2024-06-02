# Minimal bookmarks for mpv 

A minimalist bookmarker script loosely based on [mpv-bookmarker](https://github.com/NurioHin/mpv-bookmarker), rewritten to remove features I personally don't use. For Windows but can be easily modified to support other OSs.


## Installation

Copy `minimal_bookmarks.lua` to the mpv scripts folder, then add the following lines to `input.conf`:

```
b script_message bookmarker-quick-save
ctrl+b script_message bookmarker-quick-load
```

The keys are only a suggestion and can be changed to something else.


## Usage

* *`b`*: Save a new bookmark for the current file. Default save path is `%appdata%/mpv/bookmarks.json`.  
* *`ctrl+b`*: Load the latest bookmark for the current file. If the file path changes, the saved bookmarks won't work anymore unless you also rename the paths in `%appdata%/mpv/bookmarks.json`. 
