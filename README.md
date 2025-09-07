# 🦆 Duck Hunter Game

A modern, feature-rich duck hunting game built with Python and Pygame-CE. Experience the thrill of hunting with multiple game modes, animated targets, and seasonal environments!

## 🎮 Features

### 🎯 **Multiple Game Modes**
- **Easy Mode**: 10 lives, 15 ammo - Perfect for beginners
- **Normal Mode**: 3 lives, 8 ammo - Balanced challenge
- **Hard Mode**: 1 life, 5 ammo - Hardcore difficulty
- **God Mode**: ∞ lives, ∞ ammo - Pure fun mode (5-minute time limit)

### 🦆 **Diverse Targets**
- **Flying Ducks**: Common (100 pts), Rare (500 pts), Golden (1000 pts), Boss (2000 pts)
- **Ground Animals**: 
  - 🐰 Rabbit (150 pts) - Fast and small
  - 🦌 Deer (200 pts) - Medium speed with antlers
  - 🐺 Wolf (600 pts) - Quick and cunning
  - 🐻 Bear (800 pts) - Slow but valuable
  - 🦕 Dinosaur (1000 pts) - Rare and menacing

### 🎨 **Enhanced Graphics**
- **Animated Animals**: Walking cycles and realistic movement
- **Detailed Sprites**: Procedurally generated with proper anatomy
- **Parallax Background**: Multi-layered scrolling environment
- **Particle Effects**: Feather particles on successful hits
- **Professional UI**: FPS counter, timer, and mode display

### 🎮 **Gameplay Features**
- **Enhanced Crosshair**: Larger hit radius for easier targeting
- **Smart Hit Detection**: Distance-based targeting system
- **Weapon System**: Ammo management and reloading
- **Scoring System**: Different point values for different targets
- **Difficulty Scaling**: More rare targets spawn at higher scores

### 🎵 **Audio & Visual**
- **Sound Effects**: Shotgun sounds and hit feedback
- **Visual Feedback**: Crosshair flash on successful hits
- **Smooth Animations**: 60 FPS gameplay with delta-time physics
- **Professional Menus**: Complete navigation system

## 🚀 Installation

### Prerequisites
- Python 3.10.5 or higher
- pip package manager

### Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/lukifer23/RYANFUCH.git
   cd RYANFUCH
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv .venv
   ```

3. **Activate virtual environment**:
   - **Windows**: `.venv\Scripts\activate`
   - **macOS/Linux**: `source .venv/bin/activate`

4. **Install dependencies**:
   ```bash
   pip install pygame-ce==2.5.5 numpy==2.2.6 pymunk==7.0.1 pillow==11.2.1
   ```

5. **Run the game**:
   ```bash
   python duck_hunter/main.py
   ```

## 🎮 Controls

### **In-Game Controls**
- **Mouse**: Aim and shoot
- **Left Click**: Fire weapon
- **R**: Reload weapon
- **P/Space**: Pause game
- **ESC**: Pause (first press) / Quit game (second press)

### **Menu Navigation**
- **Mouse**: Navigate menus
- **Click**: Select options

## 🏗️ Project Structure

```
duck_hunter/
├── main.py                 # Main game entry point
├── game/
│   ├── core/              # Core game systems
│   │   ├── resource_manager.py
│   │   ├── animation.py
│   │   └── audio_manager.py
│   ├── entities/          # Game entities
│   │   ├── duck.py
│   │   ├── ground_animal.py
│   │   ├── player.py
│   │   └── weapon.py
│   ├── systems/           # Game systems
│   │   ├── background.py
│   │   ├── particles.py
│   │   ├── ui.py
│   │   └── menu_system.py
│   └── utils/             # Utilities
│       ├── constants.py
│       ├── helpers.py
│       └── math_utils.py
├── config/                # Configuration files
│   ├── settings.json
│   ├── keybinds.json
│   └── animations.json
└── assets/                # Game assets (placeholder)
    ├── sprites/
    ├── sounds/
    └── fonts/
```

## 🎯 Game Modes Explained

### **Easy Mode**
- **Target**: Beginners and casual players
- **Lives**: 10 (plenty of room for error)
- **Ammo**: 15 rounds (generous ammo supply)
- **Difficulty**: Relaxed and forgiving

### **Normal Mode**
- **Target**: Regular players
- **Lives**: 3 (balanced challenge)
- **Ammo**: 8 rounds (requires strategy)
- **Difficulty**: Standard hunting experience

### **Hard Mode**
- **Target**: Experienced players
- **Lives**: 1 (no room for error)
- **Ammo**: 5 rounds (very limited)
- **Difficulty**: Hardcore challenge

### **God Mode**
- **Target**: Fun and experimentation
- **Lives**: ∞ (infinite)
- **Ammo**: ∞ (unlimited)
- **Time Limit**: 5 minutes
- **Difficulty**: Pure enjoyment

## 🎨 Technical Features

### **Performance Optimizations**
- **Delta-time Physics**: Frame-rate independent gameplay
- **Efficient Sprite Management**: Optimized rendering pipeline
- **Smart Caching**: Resource manager for assets
- **Smooth Animations**: 60 FPS target with interpolation

### **Graphics Engine**
- **Procedural Generation**: Dynamic sprite creation
- **Parallax Scrolling**: Multi-layered backgrounds
- **Particle Systems**: Visual effects for hits
- **Alpha Blending**: Smooth transparency effects

### **Audio System**
- **Graceful Degradation**: Works without audio devices
- **Sound Effects**: Shotgun sounds and feedback
- **Audio Management**: Centralized audio handling

## 🐛 Troubleshooting

### **Common Issues**

1. **Audio Errors**: The game will run without audio if no device is found
2. **Font Issues**: Falls back to default Pygame fonts
3. **Performance**: Ensure you have a dedicated graphics card for best performance

### **System Requirements**
- **OS**: Windows 10+, macOS 10.14+, or Linux
- **Python**: 3.10.5 or higher
- **RAM**: 4GB minimum, 8GB recommended
- **Graphics**: Integrated graphics sufficient, dedicated GPU preferred

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### **Development Setup**
```bash
# Install development dependencies
pip install -r requirements-dev.txt

# Run tests (when available)
python -m pytest

# Format code
black duck_hunter/
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Pygame-CE**: For the excellent game development framework
- **Python Community**: For the amazing ecosystem
- **Open Source**: For inspiring this project

## 🎯 Future Features

- **Seasonal Environments**: Fall, Winter, Summer with weather effects
- **Enhanced Backgrounds**: Rocks, bushes, varied terrain
- **Weather Effects**: Snow, rain, wind
- **High Score System**: Persistent score tracking
- **Customization**: Weapon skins, crosshair styles
- **Multiplayer**: Online leaderboards and competitions

## 📞 Support

If you encounter any issues or have suggestions:

1. **Check the Issues**: Look for existing solutions
2. **Create an Issue**: Describe the problem clearly
3. **Join Discussions**: Share ideas and feedback

---

**Happy Hunting! 🦆🎯**

*Built with ❤️ using Python and Pygame-CE*
