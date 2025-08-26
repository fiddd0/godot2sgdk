# Godot2SGDK - Getting Started

## Installation
1. Copy the `godot2sgdk` folder to your project's `addons/` directory
2. Enable the plugin in Project Settings → Plugins
3. The Godot2SGDK dock will appear in the editor

## Basic Usage
1. Set up your Mega Drive palettes in the Palette Editor
2. Create your levels using TileMaps and Sprites
3. Use the validation tool to check for issues
4. Export your assets for use with SGDK

## Exporting Assets
1. Click "Validate" to check for compatibility issues
2. Click "Export" to generate SGDK-compatible files
3. Files will be saved to `res://export/` directory
4. Copy these files to your SGDK project

## Tips
- Name collision layers with "collision" in the name
- Keep unique tiles under 1024
- Use 16x16 tiles for best compatibility