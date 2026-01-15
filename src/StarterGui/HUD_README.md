# HUD UI Setup

## Struttura UI da creare in Roblox Studio

Crea questa struttura in `StarterGui`:

```
StarterGui/
├── HUD (ScreenGui)
│   ├── CashFrame (Frame)
│   │   ├── CashLabel (TextLabel) - Mostra cash corrente
│   │   └── IncomeLabel (TextLabel) - Mostra income/sec
│   ├── RankFrame (Frame)
│   │   └── RankLabel (TextLabel) - Mostra rank corrente
│   ├── AFKFrame (Frame)
│   │   └── AFKTimeLabel (TextLabel) - Mostra tempo AFK
│   └── BoostFrame (Frame)
│       └── BoostLabel (TextLabel) - Mostra quando boost attivo
```

## Layout suggerito:

### CashFrame
- Position: UDim2.new(0, 20, 0, 20)
- Size: UDim2.new(0, 300, 0, 80)
- BackgroundColor3: Color3.fromRGB(30, 30, 30)
- BackgroundTransparency: 0.3

### RankFrame
- Position: UDim2.new(1, -320, 0, 20)
- Size: UDim2.new(0, 300, 0, 80)
- BackgroundColor3: Color3.fromRGB(30, 30, 30)
- BackgroundTransparency: 0.3

### AFKFrame
- Position: UDim2.new(0, 20, 0, 110)
- Size: UDim2.new(0, 300, 0, 60)
- BackgroundColor3: Color3.fromRGB(30, 30, 30)
- BackgroundTransparency: 0.3

### BoostFrame
- Position: UDim2.new(0.5, -200, 0, 20)
- Size: UDim2.new(0, 400, 0, 50)
- BackgroundColor3: Color3.fromRGB(255, 200, 0)
- BackgroundTransparency: 0.2
- Visible: false (verrà mostrato quando boost attivo)

## Font e stile:
- Font: GothamBold o SourceSansBold
- TextScaled: true per tutti i label
- TextColor3: Color3.fromRGB(255, 255, 255)
