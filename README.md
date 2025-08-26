


# 🎮 Godot2SGDK

[![Godot Engine](https://img.shields.io/badge/Godot-4.4%2B-%23478cbf)](https://godotengine.org)
[![SGDK](https://img.shields.io/badge/SGDK-1.80%2B-blue)](https://github.com/Stephane-D/SGDK)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Made with DeepSeek](https://img.shields.io/badge/Made%20with-DeepSeekAI-ff6b35)](https://deepseek.com)

**The ultimate pipeline from Godot Engine to Sega Mega Drive (Genesis)** - Export your Godot assets directly to SGDK-compatible C headers. Created with AI assistance and featuring assets from the amazing retro dev community.

![Godot2SGDK Demo](https://img.shields.io/badge/EXPORT-READY-success)

## ✨ Features

### 🗺️ TileMap Export
- Multi-layer TileMap support
- Automatic atlas processing  
- SGDK-compatible array generation
- Real-time validation

### 🎨 Sprite Export
- Sprite2D and AnimatedSprite2D support
- 16-color Mega Drive palette system
- Automatic color optimization  
- SpriteDefinition struct generation

### 🎯 Professional Workflow
- Built-in editor plugin with dock UI
- Real-time scene validation
- Progress tracking and logging
- Configurable export settings

## 🚀 Quick Start

### 1. Installation
```bash
# Clone into your Godot project
cd your_godot_project/addons/
git clone https://github.com/yourusername/godot2sgdk.git
```

### 2. Enable Plugin
- Open Godot Editor
- Go to **Project → Plugins**  
- Enable **Godot2SGDK**

### 3. Export Assets
1. Create your scene with TileMaps and/or Sprites
2. Click **"Export TileMaps"** or **"Export Sprites"**
3. Find generated headers in `res://export/`

### 4. Use in SGDK
```c
#include "sprites.h"
#include "node2d_tilemap.h"
#include "palette.h"

void main() {
    VDP_setPalette(PAL0, game_palette);
    VDP_setTileMapData(BG_A, tilemap_map, 0, 0, 20, 14);
    SPR_setDefinition(0, &sprite_2d_def);
}
```

## 📁 Project Structure

```
godot2sgdk/
├── addons/godot2sgdk/
│   ├── core/                 # Core exporters
│   │   ├── map_exporter.gd   # TileMap processing
│   │   ├── sprite_exporter.gd # Sprite processing  
│   │   └── palette_manager.gd # Color management
│   ├── ui/                   # Editor interface
│   │   ├── main_dock.gd      # Main plugin UI
│   │   └── palette_editor.gd # Palette editor
│   └── utils/                # Utilities
│       ├── validation_utils.gd # Scene validation
│       └── export_utils.gd   # File management
├── plugin.gd                 # Plugin entry point
└── docs/                     # Documentation
    ├── GETTING_STARTED.md    # Quick start guide
    └── EXAMPLES.md           # Code examples
```

## 🎯 Supported Assets

### ✅ Currently Supported
- **TileMap** (multiple layers, custom tilesets)
- **Sprite2D** (static sprites with textures)  
- **AnimatedSprite2D** (basic frame export)
- **Color Palettes** (16-color Mega Drive format)

### 🔜 Coming Soon
- Advanced animation system
- SpriteSheet automation  
- Collision shape export
- Entity system integration

## ⚙️ Configuration

The plugin automatically creates a config file at:
```
res://addons/godot2sgdk/config.cfg
```

### Key Settings:
```ini
[export]
base_path = "res://export/"
default_palette = "res://addons/godot2sgdk/default_palette.cfg"

[validation]  
max_tiles_per_map = 4096
max_sprite_size = 32
```

## 🛠️ Technical Details

### Export Format
```c
// TileMap output
const unsigned short tilemap_map[] = {
    0x01FE, 0x01FF, 0x0200, //...
};

// Sprite output
const SpriteDefinition sprite_def = {
    16, 16, sprite_data  
};

// Palette output
const unsigned short game_palette[] = {
    0x0000, 0x0EEE, 0x0E00, //...
};
```

### Requirements
- **Godot Engine**: 4.4+
- **SGDK**: 1.80+  
- **Mega Drive Hardware**: Original or emulator

## 🙏 Acknowledgments

This project stands on the shoulders of giants and amazing community resources:

### 🤖 AI Assistance
- [**DeepSeek**](https://deepseek.com) - AI coding assistant that helped architect and implement the entire plugin system
- **AI-Powered Development** - Rapid prototyping and code generation assistance

### 🎨 Asset Credits
- [**Graphixkid**](https://graphixkid.itch.io/) - Amazing assets used for testing and demonstration 
- **Retro Dev Community** - For sharing knowledge and resources freely

### 🛠️ Tools & Frameworks
- **Godot Engine** team for amazing editor extensibility
- **Stephane Dallongeville** for the incredible SGDK framework  
- **Sega** for the legendary Mega Drive/Genesis hardware

### 👥 Community
- **You** for using this tool! 🎮
- The entire retro development community for keeping the Mega Drive alive

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

