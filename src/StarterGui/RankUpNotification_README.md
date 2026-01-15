# Rank Up Notification UI Setup

## Struttura UI da creare in Roblox Studio

Crea questa struttura in `StarterGui`:

```
StarterGui/
└── RankUpNotification (ScreenGui)
    └── Frame
        ├── RankNameLabel (TextLabel)
        └── TitleLabel (TextLabel) - "RANK UP!"
```

## Layout:

### Frame
- AnchorPoint: Vector2.new(0.5, 0)
- Position: UDim2.new(0.5, 0, -0.2, 0) (inizialmente fuori schermo)
- Size: UDim2.new(0, 400, 0, 150)
- BackgroundColor3: Color3.fromRGB(40, 40, 40)
- BackgroundTransparency: 0.2
- BorderSizePixel: 0
- Visible: false

### TitleLabel
- Position: UDim2.new(0.5, 0, 0.2, 0)
- Size: UDim2.new(0.8, 0, 0.3, 0)
- Text: "RANK UP!"
- Font: GothamBlack
- TextColor3: Color3.fromRGB(255, 215, 0)
- TextScaled: true

### RankNameLabel
- Position: UDim2.new(0.5, 0, 0.55, 0)
- Size: UDim2.new(0.8, 0, 0.35, 0)
- Text: "" (verrà impostato dallo script)
- Font: GothamBold
- TextColor3: Color3.fromRGB(255, 255, 255) (verrà cambiato in base al rank)
- TextScaled: true

## Note:
- Questa UI viene animata automaticamente dal ClientMain.lua quando il player ottiene un nuovo rank
- L'animazione fa apparire il frame dall'alto, resta visibile 3 secondi, poi sparisce
