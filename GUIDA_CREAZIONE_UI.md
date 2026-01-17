# 🎨 GUIDA COMPLETA CREAZIONE UI

Questa guida ti mostrerà come creare **MenuGUI** e **DonationGUI** in Roblox Studio passo-passo.

---

## 📋 PARTE 1: MENU GUI (Profile + Index)

### Step 1: Crea MenuGUI base
1. In **StarterGui**, click destro → Insert Object → **ScreenGui**
2. Rinomina in **"MenuGUI"**
3. Imposta:
   - `ResetOnSpawn` = false
   - `ZIndexBehavior` = Sibling

### Step 2: Crea MenuButton (pulsante per aprire)
1. In **MenuGUI**, click destro → Insert Object → **ImageButton**
2. Rinomina in **"MenuButton"**
3. Imposta:
   - `Position` = {0.05, 0},{0.15, 0}
   - `Size` = {0, 100},{0, 100}
   - `AnchorPoint` = 0.5, 0.5
   - `BackgroundColor3` = 100, 100, 255 (blu)
   - `Text` = "MENU"
   - `TextScaled` = true
   - `Font` = GothamBold
   - `TextColor3` = 255, 255, 255

### Step 3: Crea MainFrame (frame principale)
1. In **MenuGUI**, click destro → Insert Object → **Frame**
2. Rinomina in **"MainFrame"**
3. Imposta:
   - `Position` = {0.5, 0},{0.5, 0}
   - `Size` = {0, 600},{0, 500}
   - `AnchorPoint` = 0.5, 0.5
   - `BackgroundColor3` = 30, 30, 30 (grigio scuro)
   - `BorderSizePixel` = 2
   - `Visible` = **false** (importante!)

### Step 4: Crea CloseButton
1. In **MainFrame**, click destro → Insert Object → **TextButton**
2. Rinomina in **"CloseButton"**
3. Imposta:
   - `Position` = {1, -40},{0, 10}
   - `Size` = {0, 30},{0, 30}
   - `AnchorPoint` = 0, 0
   - `BackgroundColor3` = 255, 0, 0 (rosso)
   - `Text` = "X"
   - `TextScaled` = true
   - `Font` = GothamBold
   - `TextColor3` = 255, 255, 255

### Step 5: Crea TabButtons
1. In **MainFrame**, click destro → Insert Object → **Frame**
2. Rinomina in **"TabButtons"**
3. Imposta:
   - `Position` = {0, 0},{0, 50}
   - `Size` = {1, 0},{0, 50}
   - `BackgroundColor3` = 50, 50, 50
   - `BorderSizePixel` = 0

4. In **TabButtons**, crea **TextButton** → Rinomina "ProfileTab"
   - `Position` = {0, 10},{0, 5}
   - `Size` = {0.48, -15},{1, -10}
   - `BackgroundColor3` = 80, 80, 255
   - `Text` = "PROFILE"
   - `TextScaled` = true
   - `Font` = GothamBold
   - `TextColor3` = 255, 255, 255

5. In **TabButtons**, crea **TextButton** → Rinomina "IndexTab"
   - `Position` = {0.52, 5},{0, 5}
   - `Size` = {0.48, -15},{1, -10}
   - `BackgroundColor3` = 80, 80, 80
   - `Text` = "INDEX"
   - `TextScaled` = true
   - `Font` = GothamBold
   - `TextColor3` = 255, 255, 255

### Step 6: Crea ProfileFrame
1. In **MainFrame**, click destro → Insert Object → **Frame**
2. Rinomina in **"ProfileFrame"**
3. Imposta:
   - `Position` = {0, 0},{0, 100}
   - `Size` = {1, 0},{1, -100}
   - `BackgroundTransparency` = 1
   - `BorderSizePixel` = 0
   - `Visible` = true

4. In **ProfileFrame**, crea **ScrollingFrame** → Rinomina "Container"
   - `Position` = {0, 10},{0, 10}
   - `Size` = {1, -20},{1, -20}
   - `BackgroundTransparency` = 1
   - `ScrollBarThickness` = 8

5. In **Container** (ProfileFrame), crea 6 **TextLabel**:

   **a) UsernameLabel:**
   - `Name` = "UsernameLabel"
   - `Position` = {0, 10},{0, 10}
   - `Size` = {1, -20},{0, 40}
   - `BackgroundColor3` = 60, 60, 60
   - `Text` = "Username: ..."
   - `TextScaled` = true
   - `Font` = Gotham
   - `TextColor3` = 255, 255, 255
   - `TextXAlignment` = Left

   **b) FirstJoinLabel:**
   - `Name` = "FirstJoinLabel"
   - `Position` = {0, 10},{0, 60}
   - `Size` = {1, -20},{0, 40}
   - `BackgroundColor3` = 60, 60, 60
   - `Text` = "First Join: ..."
   - `TextScaled` = true
   - `Font` = Gotham
   - `TextColor3` = 255, 255, 255
   - `TextXAlignment` = Left

   **c) CashLabel:**
   - `Name` = "CashLabel"
   - `Position` = {0, 10},{0, 110}
   - `Size` = {1, -20},{0, 40}
   - `BackgroundColor3` = 60, 60, 60
   - `Text` = "Total Cash: ..."
   - `TextScaled` = true
   - `Font` = Gotham
   - `TextColor3` = 255, 255, 0
   - `TextXAlignment` = Left

   **d) AFKTimeLabel:**
   - `Name` = "AFKTimeLabel"
   - `Position` = {0, 10},{0, 160}
   - `Size` = {1, -20},{0, 40}
   - `BackgroundColor3` = 60, 60, 60
   - `Text` = "AFK Time: ..."
   - `TextScaled` = true
   - `Font` = Gotham
   - `TextColor3` = 100, 200, 255
   - `TextXAlignment` = Left

   **e) RankLabel:**
   - `Name` = "RankLabel"
   - `Position` = {0, 10},{0, 210}
   - `Size` = {1, -20},{0, 40}
   - `BackgroundColor3` = 60, 60, 60
   - `Text` = "Rank: ..."
   - `TextScaled` = true
   - `Font` = Gotham
   - `TextColor3` = 255, 100, 255
   - `TextXAlignment` = Left

   **f) RobuxSpentLabel:**
   - `Name` = "RobuxSpentLabel"
   - `Position` = {0, 10},{0, 260}
   - `Size` = {1, -20},{0, 40}
   - `BackgroundColor3` = 60, 60, 60
   - `Text` = "Robux Spent: ..."
   - `TextScaled` = true
   - `Font` = Gotham
   - `TextColor3` = 0, 255, 0
   - `TextXAlignment` = Left

### Step 7: Crea IndexFrame
1. In **MainFrame**, click destro → Insert Object → **Frame**
2. Rinomina in **"IndexFrame"**
3. Imposta:
   - `Position` = {0, 0},{0, 100}
   - `Size` = {1, 0},{1, -100}
   - `BackgroundTransparency` = 1
   - `BorderSizePixel` = 0
   - `Visible` = **false**

4. In **IndexFrame**, crea **ScrollingFrame** → Rinomina "Container"
   - `Position` = {0, 10},{0, 10}
   - `Size` = {1, -20},{1, -20}
   - `BackgroundTransparency` = 1
   - `ScrollBarThickness` = 8

### Step 8: Inserisci lo script MenuGUI_Script
1. In **MenuGUI**, click destro → Insert Object → **LocalScript**
2. Rinomina in **"MenuGUI_Script"**
3. Copia e incolla lo script che ti ho dato prima

---

## 💎 PARTE 2: DONATION GUI

### Step 1: Crea DonationGUI base
1. In **StarterGui**, click destro → Insert Object → **ScreenGui**
2. Rinomina in **"DonationGUI"**
3. Imposta:
   - `ResetOnSpawn` = false
   - `ZIndexBehavior` = Sibling

### Step 2: Crea DonationButton (pulsante per aprire)
1. In **DonationGUI**, click destro → Insert Object → **ImageButton**
2. Rinomina in **"DonationButton"**
3. Imposta:
   - `Image` = "rbxassetid://108762038284828"
   - `Position` = {0.05, 0},{0.3, 0}
   - `Size` = {0, 100},{0, 100}
   - `AnchorPoint` = 0.5, 0.5
   - `BackgroundColor3` = 255, 215, 0 (oro)
   - `Text` = "💎"
   - `TextScaled` = true
   - `Font` = GothamBold
   - `TextColor3` = 0, 0, 0

### Step 3: Crea MainFrame (frame principale)
1. In **DonationGUI**, click destro → Insert Object → **Frame**
2. Rinomina in **"MainFrame"**
3. Imposta:
   - `Position` = {0.5, 0},{0.5, 0}
   - `Size` = {0, 400},{0, 600}
   - `AnchorPoint` = 0.5, 0.5
   - `BackgroundColor3` = 30, 30, 30 (grigio scuro)
   - `BorderSizePixel` = 2
   - `Visible` = **false** (importante!)

### Step 4: Crea CloseButton
1. In **MainFrame**, click destro → Insert Object → **TextButton**
2. Rinomina in **"CloseButton"**
3. Imposta:
   - `Position` = {1, -40},{0, 10}
   - `Size` = {0, 30},{0, 30}
   - `BackgroundColor3` = 255, 0, 0 (rosso)
   - `Text` = "X"
   - `TextScaled` = true
   - `Font` = GothamBold
   - `TextColor3` = 255, 255, 255

### Step 5: Crea Title Label
1. In **MainFrame**, click destro → Insert Object → **TextLabel**
2. Rinomina in **"TitleLabel"**
3. Imposta:
   - `Position` = {0, 0},{0, 10}
   - `Size` = {1, -40},{0, 50}
   - `BackgroundColor3` = 50, 50, 50
   - `Text` = "💎 DONATE 💎"
   - `TextScaled` = true
   - `Font` = GothamBlack
   - `TextColor3` = 255, 215, 0

### Step 6: Crea DonationContainer
1. In **MainFrame**, click destro → Insert Object → **ScrollingFrame**
2. Rinomina in **"DonationContainer"**
3. Imposta:
   - `Position` = {0, 10},{0, 70}
   - `Size` = {1, -20},{1, -80}
   - `BackgroundTransparency` = 1
   - `BorderSizePixel` = 0
   - `ScrollBarThickness` = 8

### Step 7: Inserisci lo script DonationGUI_Script
1. In **DonationGUI**, click destro → Insert Object → **LocalScript**
2. Rinomina in **"DonationGUI_Script"**
3. Copia e incolla lo script che ti ho dato prima

---

## ✅ VERIFICA FINALE

Dopo aver creato tutto, la struttura dovrebbe essere:

```
StarterGui
├── MenuGUI (ScreenGui)
│   ├── MenuButton (ImageButton)
│   ├── MainFrame (Frame)
│   │   ├── CloseButton (TextButton)
│   │   ├── TabButtons (Frame)
│   │   │   ├── ProfileTab (TextButton)
│   │   │   └── IndexTab (TextButton)
│   │   ├── ProfileFrame (Frame)
│   │   │   └── Container (ScrollingFrame)
│   │   │       ├── UsernameLabel (TextLabel)
│   │   │       ├── FirstJoinLabel (TextLabel)
│   │   │       ├── CashLabel (TextLabel)
│   │   │       ├── AFKTimeLabel (TextLabel)
│   │   │       ├── RankLabel (TextLabel)
│   │   │       └── RobuxSpentLabel (TextLabel)
│   │   └── IndexFrame (Frame)
│   │       └── Container (ScrollingFrame)
│   └── MenuGUI_Script (LocalScript)
│
└── DonationGUI (ScreenGui)
    ├── DonationButton (ImageButton)
    ├── MainFrame (Frame)
    │   ├── CloseButton (TextButton)
    │   ├── TitleLabel (TextLabel)
    │   └── DonationContainer (ScrollingFrame)
    └── DonationGUI_Script (LocalScript)
```

---

## 🎮 TEST

1. Avvia il gioco in Roblox Studio (F5)
2. Dovresti vedere i pulsanti MENU e 💎 sulla sinistra dello schermo
3. Clicca su MENU → dovrebbe aprire il menu con Profile tab
4. Clicca su 💎 → dovrebbe aprire la donation GUI con 5 bottoni dorati ordinati

Se non funziona, controlla che:
- I nomi siano **ESATTI** (maiuscole/minuscole contano!)
- Gli script siano **LocalScript** (non Script normale)
- MainFrame.Visible sia impostato su **false** inizialmente
