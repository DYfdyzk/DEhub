--========================================================
--  Dark Elf Hub  v6.0  | 350×300 | 无Settings，重新排版
--========================================================
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player  = Players.LocalPlayer
local RunSvc  = game:GetService("RunService")

--<<<<<<<<  0. 主题 & 库主体  >>>>>>>>
local DarkElfHub = {
    Theme = {
        WinBg    = Color3.fromRGB(45,45,45),
        Stroke   = Color3.fromRGB(65,65,65),
        TabBg    = Color3.fromRGB(40,40,40),
        TabActive= Color3.fromRGB(65,150,255),
        Text     = Color3.fromRGB(245,245,245)
    },
    Instances = {},
    Tabs      = {},
    CurrentTab= nil,
    BossLocks = {},
    EggLocks  = {}
}

--<<<<<<<<  1. 快速创建  >>>>>>>>
local function new(class,props)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    return o
end

--<<<<<<<<  2. 标签切换  >>>>>>>>
function DarkElfHub:SwitchTab(tab)
    if self.CurrentTab == tab then return end
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        self.CurrentTab.Button.BackgroundColor3 = self.Theme.TabBg
    end
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = self.Theme.TabActive
    self.CurrentTab = tab
end

function DarkElfHub:Tab(name)
    local tab = {}
    tab.Button = new("TextButton",{
        Text = name, Size = UDim2.new(1,0,0,20),
        BackgroundColor3 = self.Theme.TabBg, TextColor3 = self.Theme.Text,
        BorderSizePixel = 0, Parent = self.Instances.TabBar,
        TextSize = 9, Font = Enum.Font.SourceSans
    })
    tab.Content = new("Frame",{
        Size = UDim2.new(1,-90,1,0), Position = UDim2.fromOffset(90,0),
        BackgroundTransparency = 1, Visible = false,
        Parent = self.Instances.Window
    })
    table.insert(self.Tabs, tab)
    if not self.CurrentTab then self:SwitchTab(tab) end
    tab.Button.MouseButton1Click:Connect(function() self:SwitchTab(tab) end)
    return tab.Content
end

--<<<<<<<<  3. 拖拽（顶部栏）  >>>>>>>>
function DarkElfHub:EnableDrag(handle)
    local drag,Input,start,startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; Input = inp; start = inp.Position; startPos = handle.Parent.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if inp == Input and drag then
            local delta = inp.Position - start
            handle.Parent.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                                                startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp == Input then drag = false end
    end)
end

--<<<<<<<<  4. 主窗口 350×300  >>>>>>>>
function DarkElfHub:Init()
    local sg = new("ScreenGui",{Name="DarkElfHub",Parent=CoreGui})
    self.Instances.ScreenGui = sg

    local win = new("Frame",{
        Name = "Window", Parent = sg,
        Size = UDim2.fromOffset(350,300), Position = UDim2.fromOffset(200,80),
        BackgroundColor3 = self.Theme.WinBg,
        BorderSizePixel = 0, ClipsDescendants = true
    })
    new("UICorner",{CornerRadius=UDim.new(0,6),Parent=win})
    new("UIStroke",{Thickness=2,Color=self.Theme.Stroke,Parent=win})
    self.Instances.Window = win

    -- 顶部栏（关闭/最小化）
    local topBar = new("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Parent=win})
    new("TextLabel",{Text="Dark Elf Hub",Size=UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(5,0),BackgroundTransparency=1,TextColor3=self.Theme.Text,TextSize=10,Parent=topBar})
    local close = new("TextButton",{Text="✕",Size=UDim2.fromOffset(18,18),Position=UDim2.new(1,-20,0,2),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=14,Parent=topBar})
    close.MouseButton1Click:Connect(function() sg:Destroy() end)
    local minimize = new("TextButton",{Text="−",Size=UDim2.fromOffset(18,18),Position=UDim2.new(1,-40,0,2),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=16,Parent=topBar})
    local orb = new("ImageButton",{Name="Orb",Parent=sg,Size=UDim2.fromOffset(40,40),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Image="rbxassetid://126648994738185",Visible=false,Active=true,Draggable=true})
    new("UICorner",{CornerRadius=UDim.new(1,0),Parent=orb})
    local isMin=false; minimize.MouseButton1Click:Connect(function() isMin=true; win.Visible=false; orb.Visible=true end)
    orb.MouseButton1Click:Connect(function() isMin=false; win.Visible=true; orb.Visible=false end)

    -- 左侧栏
    local sideBar = new("Frame",{Size=UDim2.new(0,90,1,-20),Position=UDim2.fromOffset(0,20),BackgroundColor3=self.Theme.WinBg,BorderSizePixel=0,Parent=win})
    new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,2),Parent=sideBar})
    local tabBar = new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=sideBar})
    new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,2),Parent=tabBar})
    self.Instances.TabBar = tabBar
    self:EnableDrag(topBar)
end

DarkElfHub:Init()

--<<<<<<<<  5. 创建标签（仅 3 个）  >>>>>>>>
local home     = DarkElfHub:Tab("Home")
local awsTab   = DarkElfHub:Tab("AWS Event")
local speedTab = DarkElfHub:Tab("极速传奇")

-- 6. Home 页剩余（Tick + 排版压缩）
local tickLbl=new("TextLabel",{Text="Tick: 0",TextSize=fontSize,Size=UDim2.new(1,0,0,11),Position=UDim2.fromOffset(5,59),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left,Parent=home})
RunSvc.Heartbeat:Connect(function() tickLbl.Text=("Tick: %.1f"):format(workspace.DistributedGameTime) end)

--<<<<<<<<  7. AWS Event 页（水平排版 + Egg下放）  >>>>>>>>
local rowH, gap = 22, 10

-- ① Auto Boss → 整窗子页入口
local autoBossMainBtn = new("TextButton",{
    Text="Auto Boss",Size=UDim2.new(0,80,0,rowH),Position=UDim2.fromOffset(5,5),
    BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=awsTab
})

-- ② Auto Train（水平行1）
local trainBtn = new("TextButton",{
    Text="Auto Train: OFF",Size=UDim2.new(0,90,0,rowH),Position=UDim2.fromOffset(95,5),
    BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=awsTab
})

-- ③ Auto Egg + 蛋选择（行2，蛋下堆放）
local eggY = 5 + rowH + gap
local autoEggBtn=new("TextButton",{Text="Auto Egg: OFF",Size=UDim2.new(0,90,0,rowH),Position=UDim2.fromOffset(5,eggY),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=awsTab})
local eggSelY = eggY + rowH + 4
local eggBtn1=new("TextButton",{Text="Mining",Size=UDim2.new(0,80,0,18),Position=UDim2.fromOffset(5,eggSelY),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=8,Parent=awsTab})
local eggBtn2=new("TextButton",{Text="MiningCrystal",Size=UDim2.new(0,80,0,18),Position=UDim2.fromOffset(90,eggSelY),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=8,Parent=awsTab})

-- Egg 选择逻辑
local currentEgg="Mining"; DarkElfHub.EggLocks={Mining=false,MiningCrystal=false}; DarkElfHub.EggLocks[currentEgg]=true; eggBtn1.BackgroundColor3=Color3.fromRGB(255,80,80)
local function setEggLock(egg) for k in pairs(DarkElfHub.EggLocks) do DarkElfHub.EggLocks[k]=false end; DarkElfHub.EggLocks[egg]=true; currentEgg=egg; eggBtn1.BackgroundColor3=egg=="Mining" and Color3.fromRGB(255,80,80) or Color3.fromRGB(60,60,60); eggBtn2.BackgroundColor3=egg=="MiningCrystal" and Color3.fromRGB(255,80,80) or Color3.fromRGB(60,60,60) end; eggBtn1.MouseButton1Click:Connect(function() setEggLock("Mining") end); eggBtn2.MouseButton1Click:Connect(function() setEggLock("MiningCrystal") end)

-- Auto Egg 开关
local eggConn; local function setAutoEgg(s) if s then autoEggBtn.Text="Auto Egg: ON"; autoEggBtn.BackgroundColor3=Color3.fromRGB(255,80,80); local cnt=0; eggConn=RunSvc.Heartbeat:Connect(function(dt) cnt=cnt+dt; if cnt>=1/3 then cnt=0; if DarkElfHub.EggLocks[currentEgg] then game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(currentEgg,true,false) end end end) else autoEggBtn.Text="Auto Egg: OFF"; autoEggBtn.BackgroundColor3=Color3.fromRGB(60,60,60); if eggConn then eggConn:Disconnect(); eggConn=nil end end end; autoEggBtn.MouseButton1Click:Connect(function() setAutoEgg(autoEggBtn.Text:find("OFF") and true or false) end)

-- ④ Boss 子页（整窗级，完全沿用你原有结构）
local bossSubPage = new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=DarkElfHub.Theme.WinBg,BorderSizePixel=0,Visible=false,Parent=DarkElfHub.Instances.Window}); new("UICorner",{CornerRadius=UDim.new(0,6),Parent=bossSubPage}); new("UIStroke",{Thickness=2,Color=DarkElfHub.Theme.Stroke,Parent=bossSubPage})
local subTitle=new("TextLabel",{Text="Boss 设置",TextSize=10,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Parent=bossSubPage}); local backBtn=new("TextButton",{Text="✕",Size=UDim2.fromOffset(18,18),Position=UDim2.new(1,-20,0,2),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),TextSize=14,Parent=bossSubPage})
autoBossMainBtn.MouseButton1Click:Connect(function() for _,tab in ipairs(DarkElfHub.Tabs) do tab.Content.Visible=false end; DarkElfHub.Instances.TabBar.Parent.Visible=false; bossSubPage.Visible=true end); backBtn.MouseButton1Click:Connect(function() bossSubPage.Visible=false; DarkElfHub.Instances.TabBar.Parent.Visible=true; DarkElfHub:SwitchTab(DarkElfHub.Tabs[2]) end)

-- Boss子页内部（3×3加长按钮，字体6）——完全沿用你原有结构
local currentBoss = "ApprenticeMiner"; local leftBoss=new("Frame",{Size=UDim2.new(0,90,0,120),Position=UDim2.fromOffset(5,25),BackgroundTransparency=1,Parent=bossSubPage}); new("UIListLayout",{Padding=UDim.new(0,6),Parent=leftBoss})
local selectBossBtn=new("TextButton",{Text="选择 Boss",Size=UDim2.new(0,80,0,20),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=leftBoss})
local autoClickBtn=new("TextButton",{Text="Auto Click: OFF",Size=UDim2.new(0,80,0,20),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=leftBoss})
local autoBossBtn=new("TextButton",{Text="Auto Boss: OFF",Size=UDim2.new(0,80,0,20),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=leftBoss})
local expandFrame=new("Frame",{Size=UDim2.fromOffset(3*50+2*4,3*28+2*4),Position=UDim2.fromOffset(105,25),BackgroundTransparency=1,Visible=false,Parent=bossSubPage}); new("UIGridLayout",{CellSize=UDim2.fromOffset(50,28),CellPadding=UDim2.fromOffset(4,4),FillDirection=Enum.FillDirection.Horizontal,StartCorner=Enum.StartCorner.TopLeft,Parent=expandFrame})
local bossList={"ApprenticeMiner","SkeletonMiner","CaveGoblin","ExpertMiner","CaveGolem","AxolotlMiner","GorillaMiner","KingMole"}; for _,boss in ipairs(bossList) do local btn=new("TextButton",{Text=boss,BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=6,Parent=expandFrame}); btn.MouseButton1Click:Connect(function() for k in pairs(DarkElfHub.BossLocks) do DarkElfHub.BossLocks[k]=false end; DarkElfHub.BossLocks[boss]=true; currentBoss=boss; for _,v in ipairs(expandFrame:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3=Color3.fromRGB(60,60,60) end end; btn.BackgroundColor3=Color3.fromRGB(255,80,80); expandFrame.Visible=false; selectBossBtn.Text="已选: "..boss end) end; selectBossBtn.MouseButton1Click:Connect(function() expandFrame.Visible=not expandFrame.Visible end)
local clickConn; local function setAutoClick(s) if s then autoClickBtn.Text="Auto Click: ON"; autoClickBtn.BackgroundColor3=Color3.fromRGB(255,80,80); local cnt=0; clickConn=RunSvc.Heartbeat:Connect(function(dt) cnt=cnt+dt; if cnt>=1/12 then cnt=0; local svc=game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RF; svc.RequestCritHit:InvokeServer(); svc.RequestClick:InvokeServer(true) end end) else autoClickBtn.Text="Auto Click: OFF"; autoClickBtn.BackgroundColor3=Color3.fromRGB(60,60,60); if clickConn then clickConn:Disconnect(); clickConn=nil end end end; autoClickBtn.MouseButton1Click:Connect(function() setAutoClick(autoClickBtn.Text:find("OFF") and true or false) end)
local bossConn; local function setAutoBoss(s) if s then autoBossBtn.Text="Auto Boss: ON"; autoBossBtn.BackgroundColor3=Color3.fromRGB(255,80,80); local cnt=0; bossConn=RunSvc.Heartbeat:Connect(function(dt) cnt=cnt+dt; if cnt>=1/4 then cnt=0; if DarkElfHub.BossLocks[currentBoss] then game:GetService("ReplicatedStorage").Packages.Knit.Services.ArmWrestleService.RF.RequestStartFight:InvokeServer(currentBoss) end end end) else autoBossBtn.Text="Auto Boss: OFF"; autoBossBtn.BackgroundColor3=Color3.fromRGB(60,60,60); if bossConn then bossConn:Disconnect(); bossConn=nil end end end; autoBossBtn.MouseButton1Click:Connect(function() setAutoBoss(autoBossBtn.Text:find("OFF") and true or false) end)

--<<<<<<<<  8. 极速传奇页（心跳计数：200 100 10 4）  >>>>>>>>
local speedTab = DarkElfHub:Tab("极速传奇")
local rowH, gap = 22, 10

-- ① 黄球宠 200/s
local yellowBtn = new("TextButton",{Text="自动黄球宠: OFF",Size=UDim2.new(0,120,0,rowH),Position=UDim2.fromOffset(5,5),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=speedTab})
local yellowConn; local yellowAcc = 0; local function setYellow(s) if s then yellowBtn.Text="自动黄球宠: ON"; yellowBtn.BackgroundColor3=Color3.fromRGB(255,80,80); yellowConn=RunSvc.Heartbeat:Connect(function(dt) yellowAcc=yellowAcc+dt; if yellowAcc>=1/200 then yellowAcc=0; local args={"collectOrb","Yellow Orb","City"}; game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer(unpack(args)) end end) else yellowBtn.Text="自动黄球宠: OFF"; yellowBtn.BackgroundColor3=Color3.fromRGB(60,60,60); if yellowConn then yellowConn:Disconnect(); yellowConn=nil end end end; yellowBtn.MouseButton1Click:Connect(function() setYellow(yellowBtn.Text:find("OFF") and true or false) end)

-- ② 全球钻 100/s
local allOrbBtn = new("TextButton",{Text="自动全球钻: OFF",Size=UDim2.new(0,120,0,rowH),Position=UDim2.fromOffset(5,5+rowH+gap),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=speedTab})
local orbConn; local orbAcc = 0; local orbs={"Yellow Orb","Red Orb","Blue Orb","Orange Orb","Ethereal Orb"}; local areas={"City","Snow","Magma","Legends Highway"}; local function setAllOrb(s) if s then allOrbBtn.Text="自动全球钻: ON"; allOrbBtn.BackgroundColor3=Color3.fromRGB(255,80,80); orbConn=RunSvc.Heartbeat:Connect(function(dt) orbAcc=orbAcc+dt; if orbAcc>=1/100 then orbAcc=0; for _,orb in ipairs(orbs) do for _,area in ipairs(areas) do local args={"collectOrb",orb,area"}; game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer(unpack(args)) end end end end) else allOrbBtn.Text="自动全球钻: OFF"; allOrbBtn.BackgroundColor3=Color3.fromRGB(60,60,60); if orbConn then orbConn:Disconnect(); orbConn=nil end end end; allOrbBtn.MouseButton1Click:Connect(function() setAllOrb(allOrbBtn.Text:find("OFF") and true or false) end)

-- ③ 买武士 10/s
local buySamBtn = new("TextButton",{Text="自动买武士: OFF",Size=UDim2.new(0,120,0,rowH),Position=UDim2.fromOffset(5,5+(rowH+gap)*2),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=speedTab})
local buyConn; local buyAcc = 0; local function setBuySam(s) if s then buySamBtn.Text="自动买武士: ON"; buySamBtn.BackgroundColor3=Color3.fromRGB(255,80,80); buyConn=RunSvc.Heartbeat:Connect(function(dt) buyAcc=buyAcc+dt; if buyAcc>=1/10 then buyAcc=0; local args={game:GetService("ReplicatedStorage").cPetShopFolder.Swift Samurai"}; game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(unpack(args)) end end) else buySamBtn.Text="自动买武士: OFF"; buySamBtn.BackgroundColor3=Color3.fromRGB(60,60,60); if buyConn then buyConn:Disconnect(); buyConn=nil end end end; buySamBtn.MouseButton1Click:Connect(function() setBuySam(buySamBtn.Text:find("OFF") and true or false) end)

-- ④ 进阶武士 4/s
local evolveBtn = new("TextButton",{Text="自动进阶武士: OFF",Size=UDim2.new(0,120,0,rowH),Position=UDim2.fromOffset(5,5+(rowH+gap)*3),BackgroundColor3=Color3.fromRGB(60,60,60),TextColor3=Color3.new(1,1,1),BorderSizePixel=0,TextSize=9,Parent=speedTab})
local evolveConn; local evolveAcc = 0; local function setEvolve(s) if s then evolveBtn.Text="自动进阶武士: ON"; evolveBtn.BackgroundColor3=Color3.fromRGB(255,80,80); evolveConn=RunSvc.Heartbeat:Connect(function(dt) evolveAcc=evolveAcc+dt; if evolveAcc>=1/4 then evolveAcc=0; local args={"evolvePet","Swift Samurai"}; game:GetService("ReplicatedStorage").rEvents.petEvolveEvent:FireServer(unpack(args)) end end) else evolveBtn.Text="自动进阶武士: OFF"; evolveBtn.BackgroundColor3=Color3.fromRGB(60,60,60); if evolveConn then evolveConn:Disconnect(); evolveConn=nil end end end; evolveBtn.MouseButton1Click:Connect(function() setEvolve(evolveBtn.Text:find("OFF") and true or false) end)

print("[Dark Elf Hub] v6.0 350×300 已加载（无Settings，重新排版）")
>


