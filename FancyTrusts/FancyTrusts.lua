addon.name      = 'FancyTrusts';
addon.author    = 'Arielfy';
addon.version   = '0.3.1';
addon.desc      = 'A fancy UI to manage trusts.';
addon.link      = 'https://github.com/ariel-logos/FancyTrusts';


require('common');
local imgui = require('imgui');
local fonts = require('fonts');
local settings = require('settings');
local ffi = require('ffi');
local prims = require('primitives');

local cfg = T{

	rows = 7,
	cols = 2,
	scale = 1,
	maxTrusts = 3,
	waitTime = 5.6,
	preset = T{false,false,false,false,false},
	presetLists = {T{},T{},T{},T{},T{}},
	isVisible = false,
	slowMode  = T{false},
	selectedMaxTrusts = T{true, false, false},
	presetOnTop = T{false},
	handheldMode = T{false}
}

local ui = {
	currentConfig,
	trustList,
	listIdx = 0,
	listLen = 0,
	width = 0,
	height = 0,
	buttonW = 200,
	buttonH = 40,
	buttonP = 2,
	navH = 50,
	navPadding = 50,
	idxOffset = 0,
	presetBoxW = 70,
	customFont,
	customFont2,
}

local buttonColorStylesNormal = {
	T{ImGuiCol_Text,                 {0.0, 0.0, 0.0, 1.0}},  
	T{ImGuiCol_Button,               {211/255, 223/255, 242/255, 1.0}},              
	T{ImGuiCol_ButtonActive,         {1, 1, 1, 1.0}},              
	T{ImGuiCol_ButtonHovered,        {166/255, 196/255, 255/255, 1.0}},
	T{ImGuiCol_FrameBg, 			 {161/255, 183/255, 192/255, 1.0}},
	T{ImGuiCol_FrameBgHovered, 		 {201/255, 223/255, 232/255, 1.0}},
	T{ImGuiCol_FrameBgActive,		 {1, 1, 1, 1.0}},   
	T{ImGuiCol_Tab,					 {111/255, 123/255, 142/255, 1.0}},
}

local buttonColorStylesPreset = {
	T{ImGuiCol_Text,                 {1.0, 1.0, 1.0, 1.0}},  
	T{ImGuiCol_Button,               {106/255, 74/255, 128/255, 1.0}},              
	T{ImGuiCol_ButtonActive,         {0, 0, 0, 1.0}},              
	T{ImGuiCol_ButtonHovered,        {139/255, 103/255, 163/255, 1.0}},
}

local buttonColorStylesLocked = {
	T{ImGuiCol_Text,                 {1.0, 1.0, 1.0, 1.0}},  
	T{ImGuiCol_Button,               {70/255, 70/255, 70/255, 1.0}},              
	T{ImGuiCol_ButtonActive,         {95/255, 95/255, 95/255, 1.0}},              
	T{ImGuiCol_ButtonHovered,        {90/255, 90/255, 90/255, 1.0}},
}

local buttonVarStyles = {
	
	
}

local previousFrameVisible = false;

local debugMode = false;

local old_list = T{};

local summoning = false;
local summoningTimer = 0;
local summoningIdx = 1;
local summoningTable = 0;
local summoningStart = 0;

local debugtext = ' ';

local function save_settings()
    settings.save('cfg');
end

settings.register('cfg', 'cfg_update', function(s)
    if s ~= nil then ui.currentConfig = s end
    settings.save('cfg');
end)


ashita.events.register('d3d_present', 'present_cb', function()
	if (debugMode == true) then
		imgui.SetNextWindowSize({ 350, 480, });
		imgui.SetNextWindowSizeConstraints({ 350, 480, }, { FLT_MAX, FLT_MAX, });
		imgui.Begin('trusts', true, ImGuiWindowFlags_NoResize);
		if (imgui.BeginTabBar('##trusts_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
			if (imgui.BeginTabItem('Debug', nil)) then
			

				imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, debugtext);
				if (ui.trustList ~= nil ) then
					imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, tostring(summoningTimer));
				end
				
				for i = 1,GetTableLen(ui.currentConfig.presetLists[1]) do 
					imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ui.currentConfig.presetLists[1][i]);
				end
				
				
				--and spell.Skill == 43 and spell.LevelRequired[16 + 1] > 0
				
				
			end
			imgui.EndTabItem();	
		end
		imgui.EndTabBar();
	end
    imgui.End();
	displayUI();
	previousFrameVisible = ui.currentConfig.isVisible;
end);

function GetTrusts()
	local tmp = T{};
	old_list = ui.trustList;
	ui.listLen = 0;
	for i = 0, 2048 do
		local spell = AshitaCore:GetResourceManager():GetSpellById(i);
		if (spell ~= nil and spell.Skill == 0 and AshitaCore:GetMemoryManager():GetPlayer():HasSpell(i)) then
			ui.listLen = ui.listLen + 1;
			table.insert(tmp, ui.listLen, spell.Name[1]);
			--imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, tostring(spell.Name[1]))					
		end
	end			
	
	ui.trustList = tmp;
	table.sort(ui.trustList);

	local fix = false;
	for i = 1, math.max(GetTableLen(old_list),GetTableLen(ui.trustList)) do
		if  ui.trustList ~= nil and	old_list ~= nil then
			if ui.trustList[i] == nil or old_list[i] == nil or old_list[i] ~= ui.trustList[i] then
				fix = true;
				--print(ui.trustList[i]);
			end
		end
	end
	
	--[[if fix then
		print(fix);
		print(tostring(GetTableLen(ui.trustList)));
		for j = 1, GetTableLen(ui.trustList) do
			print('-'..ui.trustList[j]);
		end
	end]]--
	
	if fix and GetTableLen(ui.trustList) > 0 then
		for p = 1,5 do
			local tmpP = T{};
			if (ui.currentConfig.presetLists[p] ~= nil) then
				for _, t in pairs(ui.currentConfig.presetLists[p]) do
					local toCheck = string.sub(t,6,-7);
					--print(toCheck);
					if FindInTable(ui.trustList,toCheck) then
						--print('found');
						table.insert(tmpP, t);
					end
				end
			end
			ui.currentConfig.presetLists[p] = tmpP;
		end
	save_settings();
	end
end


function displayUI()
	
	SummonTrusts();

if (ui.currentConfig.isVisible) then
	GetTrusts();
	
	
	local old_scale = ui.customFont.Scale;
	ui.customFont.Scale = ui.customFont.Scale * ui.currentConfig.scale - 0.27+(0.27*ui.currentConfig.scale);
	--debugtext = tostring(ui.customFont.Scale);
	imgui.PushFont(ui.customFont);
	
	PushColorStyles(buttonColorStylesNormal);
	--PushVarStyles(buttonVarStyles);
	imgui.PushStyleVar(ImGuiStyleVar_FrameRounding,		20*ui.currentConfig.scale);
	imgui.PushStyleVar(ImGuiStyleVar_ButtonTextAlign,	{0.5,0});
	
	if(ui.currentConfig.handheldMode[1]) then ui.navPadding = 65; else ui.navPadding = 0; end
	
	ui.width = ui.currentConfig.cols*ui.buttonW*ui.currentConfig.scale+(ui.presetBoxW)*ui.currentConfig.scale+ui.navPadding;
	ui.height = ui.currentConfig.rows*ui.buttonH*ui.currentConfig.scale+ui.navH*ui.currentConfig.scale;
	--ImGuiWindowFlags_NoNav
	--ImGuiWindowFlags_NoBackground,ImGuiWindowFlags_NoFocusOnAppearing
	imgui.SetNextWindowSize({ ui.width, ui.height }, ImGuiCond_Always);
	local windowFlags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_NoResize ,ImGuiWindowFlags_NoBackground, ImGuiWindowFlags_NoBringToFrontOnFocus, ImGuiWindowFlags_NoFocusOnAppearing);
	if (imgui.Begin('TrustsUI', ui.currentConfig.isVisible, windowFlags)) then
	if (imgui.BeginTabBar('##trustsui_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
	if (imgui.BeginTabItem('Trusts', nil)) then
	
	if (not previousFrameVisible and ui.currentConfig.isVisible) then imgui.SetScrollHereY(0); end

	if (ui.currentConfig.handheldMode[1]) then
	
	local offset2 = imgui.GetScrollY()/ui.currentConfig.scale;
		imgui.SetCursorPos({ui.width-(15/ui.currentConfig.scale*0.4)-((ui.navPadding)*ui.currentConfig.scale)+ui.buttonP+15*ui.currentConfig.scale,((ui.navH+ui.buttonP*2)+offset2)*ui.currentConfig.scale});
	
	local prevScale2 = ui.customFont2.Scale;
	ui.customFont2.Scale = ui.customFont2.Scale * ui.currentConfig.scale* ui.currentConfig.scale/(ui.currentConfig.scale*2);
	imgui.PushFont(ui.customFont2);
	imgui.PushStyleVar(ImGuiStyleVar_ButtonTextAlign, {0.5,0.5})
	imgui.PushStyleVar(ImGuiStyleVar_FrameRounding,		10*ui.customFont2.Scale);


	if (imgui.Button('/\\',{44*ui.currentConfig.scale+10-(5*ui.currentConfig.scale),60*ui.currentConfig.scale})) then
		ui.idxOffset = ui.idxOffset -2;
		if (ui.idxOffset < 0) then ui.idxOffset = 0; end
	end
	
	imgui.SetCursorPos({ui.width-(15/ui.currentConfig.scale*0.4)-((ui.navPadding)*ui.currentConfig.scale)+ui.buttonP+15*ui.currentConfig.scale,ui.height-((ui.navH)+25-offset2)*ui.currentConfig.scale});
	
	if (imgui.Button('\\/',{44*ui.currentConfig.scale+10-(5*ui.currentConfig.scale),60*ui.currentConfig.scale})) then
		ui.idxOffset = ui.idxOffset +2;
		if (ui.idxOffset > ui.listLen-13) then ui.idxOffset =ui.idxOffset - 2; end
	end

	--debugtext = tostring(ui.idxOffset);
	
	ui.customFont2.Scale = prevScale2;
	imgui.PopStyleVar();
	imgui.PopStyleVar();
	imgui.PopFont();
	
	end
	
		--imgui.Text('hello');
		
		local buttonSize = {ui.buttonW*ui.currentConfig.scale-ui.buttonP*2, ui.buttonH*ui.currentConfig.scale-ui.buttonP*2};
		
		local idx1 = 1;
		for drawIdx = 1+ui.idxOffset, ui.listLen do
		local isInPreset = false;
		for p = 1,5 do
			if (ui.currentConfig.preset[p] and FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))) then
				isInPreset = true;
			end
		end
		if (isInPreset or not ui.currentConfig.presetOnTop[1]) then
			
			local c = math.fmod(idx1-1,ui.currentConfig.cols);
			local r = math.floor((idx1-1)/2);
			imgui.SetCursorPos({c*ui.buttonW*ui.currentConfig.scale+ui.buttonP+2,r*ui.buttonH*ui.currentConfig.scale+(ui.buttonP+ui.navH)*ui.currentConfig.scale});
			
			local isButtonPreset = false;
			for p = 1,5 do
				if (ui.currentConfig.preset[p] and FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))) then
					isButtonPreset = true;
				end
			end
			
			if (isButtonPreset) then PushColorStyles(buttonColorStylesPreset); end
			if (summoning)  then PushColorStyles(buttonColorStylesLocked); end
			if (imgui.Button(ui.trustList[drawIdx],buttonSize)) then
			if (not summoning) then
				if (not ui.currentConfig.preset[1] and not ui.currentConfig.preset[2] and not ui.currentConfig.preset[3] and not ui.currentConfig.preset[4] and not ui.currentConfig.preset[5]) then
					AshitaCore:GetChatManager():QueueCommand(1, string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]));
				else
					for p = 1,5 do
						if (ui.currentConfig.preset[p] and
							GetTableLen(ui.currentConfig.presetLists[p]) < ui.currentConfig.maxTrusts and
							not FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))
						) then
							--debugtext = tostring(GetTableLen(ui.currentConfig.presetLists[p]));
							table.insert(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]));
						else 
							if (ui.currentConfig.preset[p] and 
							FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))) then
								table.remove(ui.currentConfig.presetLists[p],FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx])));
							end
						end
					end
					save_settings();
				end
		
			end
			end
			if (summoning)  then PopColorStyles(buttonColorStylesLocked); end
			if (isButtonPreset) then PopColorStyles(buttonColorStylesPreset); end
			idx1 = idx1 +1;
		end	
		end
		
		local idx2 = idx1;
		for drawIdx = 1+ui.idxOffset, ui.listLen do
		local isInPreset2 = false;
		for p = 1,5 do
			if (ui.currentConfig.preset[p] and FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))) then
				isInPreset2 = true;
			end
		end
		if (not isInPreset2 and ui.currentConfig.presetOnTop[1]) then
			
			local c = math.fmod(idx2-1,ui.currentConfig.cols);
			local r = math.floor((idx2-1)/2);
			imgui.SetCursorPos({c*ui.buttonW*ui.currentConfig.scale+ui.buttonP+2,r*ui.buttonH*ui.currentConfig.scale+(ui.buttonP+ui.navH)*ui.currentConfig.scale});
			
			local isButtonPreset = false;
			for p = 1,5 do
				if (ui.currentConfig.preset[p] and FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))) then
					isButtonPreset = true;
				end
			end
			
			if (isButtonPreset) then PushColorStyles(buttonColorStylesPreset); end
			if (summoning)  then PushColorStyles(buttonColorStylesLocked); end
			if (imgui.Button(ui.trustList[drawIdx],buttonSize)) then
			if (not summoning) then
				if (not ui.currentConfig.preset[1] and not ui.currentConfig.preset[2] and not ui.currentConfig.preset[3] and not ui.currentConfig.preset[4] and not ui.currentConfig.preset[5]) then
					AshitaCore:GetChatManager():QueueCommand(1, string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]));
				else
					for p = 1,5 do
						if (ui.currentConfig.preset[p] and
							GetTableLen(ui.currentConfig.presetLists[p]) < ui.currentConfig.maxTrusts and
							not FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))
						) then
							--debugtext = tostring(GetTableLen(ui.currentConfig.presetLists[p]));
							table.insert(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]));
						else 
							if (ui.currentConfig.preset[p] and
							FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx]))) then
								table.remove(ui.currentConfig.presetLists[p],FindInTable(ui.currentConfig.presetLists[p],string.format('/ma \"%s\" <me>',ui.trustList[drawIdx])));
							end
						end
					end
					save_settings();
				end			
			end
			end 
			if (summoning)  then PopColorStyles(buttonColorStylesLocked); end
			if (isButtonPreset) then PopColorStyles(buttonColorStylesPreset); end
			idx2 = idx2 +1;
		end	
		end
		
		
	--imgui.Button(ui.trustList[drawIdx].name
	
	
	
	
	local offset = imgui.GetScrollY()/ui.currentConfig.scale;
	
	
	imgui.PushStyleColor(ImGuiCol_Text, {1.0, 1.0, 1.0, 1.0}); 
	imgui.SetCursorPos({ui.width-((ui.presetBoxW-5)*ui.currentConfig.scale)+ui.buttonP*ui.currentConfig.scale-ui.navPadding,((ui.navH+ui.buttonP*2)+offset)*ui.currentConfig.scale});
	for i = 1,5 do
	

		if (imgui.Checkbox(tostring(i),{ui.currentConfig.preset[i]})) then 
			ui.currentConfig.preset[i] = not ui.currentConfig.preset[i];
			local l = T{1,2,3,4,5};
			table.remove(l,i)
			for r = 1,4 do ui.currentConfig.preset[l[r]] = false; end
			save_settings();
		end
		imgui.SetCursorPos({ui.width-((ui.presetBoxW-5)*ui.currentConfig.scale)+ui.buttonP-ui.navPadding,(ui.navH+((i+0.1)*39)+offset)*ui.currentConfig.scale});
	end
	imgui.PopStyleColor();
	
	imgui.SetCursorPos({ui.width-(ui.presetBoxW*ui.currentConfig.scale)+ui.buttonP-ui.navPadding,(ui.navH*5.0+offset)*ui.currentConfig.scale});
	
	
	for p = 1,5 do
		if (ui.currentConfig.preset[p]) then
		
			local prevScale = ui.customFont.Scale;
			ui.customFont.Scale = ui.customFont.Scale * ui.currentConfig.scale/(ui.currentConfig.scale*2);
			imgui.PushFont(ui.customFont);
			imgui.PushStyleVar(ImGuiStyleVar_ButtonTextAlign, {0.5,0.5})
			imgui.PushStyleVar(ImGuiStyleVar_FrameRounding,		10*ui.customFont.Scale);
			local sButtonName = 'Summon';
			if (summoning) then sButtonName = 'Stop'; end
			if (imgui.Button(sButtonName,{56*ui.currentConfig.scale,36*ui.currentConfig.scale})) then
				if (not summoning) then summoningTable = p; summoning = true;
				else
					summoning = false;
					summoningTimer = 0;
					summoningIdx = 1;
					summoningTable = 0;
					summoningStart = 0;
				end
			end
	
			ui.customFont.Scale = prevScale;
			imgui.PopStyleVar();
			imgui.PopStyleVar();
			imgui.PopFont();
		end
	end
	
	imgui.EndTabItem();
	end 
	
	
	-- SETTINGS -- -------------------------

	imgui.Text(' ');
	
	if (imgui.BeginTabItem('Config', nil)) then
	imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, {0, 10*ui.currentConfig.scale});	

	imgui.PushStyleColor(ImGuiCol_Text, {1.0, 1.0, 1.0, 1.0}); 
	
		if (imgui.Checkbox('Slow Mode',{ui.currentConfig.slowMode[1]})) then
			ui.currentConfig.slowMode[1] = not ui.currentConfig.slowMode[1];
			save_settings();
		end
		imgui.SameLine();
		imgui.Text(' ');
		imgui.SameLine();
		if (imgui.Checkbox('Selected On Top',{ui.currentConfig.presetOnTop[1]})) then
			if( not ui.currentConfig.handheldMode[1]) then
				ui.currentConfig.presetOnTop[1] = not ui.currentConfig.presetOnTop[1];
			end
			save_settings();
		end
		--imgui.SameLine();
		--imgui.Text(' ');
		--imgui.SameLine();
		if (imgui.Checkbox('Handheld Mode',{ui.currentConfig.handheldMode[1]})) then
			ui.currentConfig.handheldMode[1] = not ui.currentConfig.handheldMode[1];
			if (ui.currentConfig.handheldMode[1]) then
				imgui.SetScrollHereY(0);
				ui.currentConfig.presetOnTop[1] = false;
			else
				ui.idxOffset = 0;
			end
			save_settings();
		end
		imgui.PopStyleVar(1);
		imgui.Text('Max Trusts');
		if (imgui.Checkbox('3',{ui.currentConfig.selectedMaxTrusts[1]})) then
			ui.currentConfig.maxTrusts = 3;
			ui.currentConfig.selectedMaxTrusts[1]=true;
			ui.currentConfig.selectedMaxTrusts[2]=false;
			ui.currentConfig.selectedMaxTrusts[3]=false;
			for i = 1,5 do
				local length = GetTableLen(ui.currentConfig.presetLists[i]);
				for j = 4,length do
					table.remove(ui.currentConfig.presetLists[i],j);
				end
			end

			save_settings();
		end
		imgui.SameLine();
		if (imgui.Checkbox('4',{ui.currentConfig.selectedMaxTrusts[2]})) then
			ui.currentConfig.maxTrusts = 4;
			ui.currentConfig.selectedMaxTrusts[1]=false;
			ui.currentConfig.selectedMaxTrusts[2]=true;
			ui.currentConfig.selectedMaxTrusts[3]=false;
			for i = 1,5 do
				local length = GetTableLen(ui.currentConfig.presetLists[i]);
				for j = 5,length do
					table.remove(ui.currentConfig.presetLists[i],j);
				end
			end
			save_settings();
		end
		imgui.SameLine();
		imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, {0, 10*ui.currentConfig.scale});	
		if (imgui.Checkbox('5',{ui.currentConfig.selectedMaxTrusts[3]})) then
			ui.currentConfig.maxTrusts = 5;
			ui.currentConfig.selectedMaxTrusts[1]=false;
			ui.currentConfig.selectedMaxTrusts[2]=false;
			ui.currentConfig.selectedMaxTrusts[3]=true;
			for i = 1,5 do
				local length = GetTableLen(ui.currentConfig.presetLists[i]);
				for j = 6,length do
					table.remove(ui.currentConfig.presetLists[i],j);
				end
			end
			save_settings();
		end
		imgui.PopStyleVar(1);
		imgui.Text('UI Scale');
		
		imgui.PushStyleColor(ImGuiCol_FrameBgActive,  {0.8, 0.8, 0.8, 1.0});
		local S = T{ui.currentConfig.scale*2};
		if (imgui.SliderFloat('  ', S, 1, 3, '%0.1f')) then
			ui.currentConfig.scale = S[1]/2;
			save_settings();
		end
		
	imgui.PopStyleColor();	
	imgui.PopStyleColor();
	imgui.EndTabItem();

	end
	
	imgui.EndTabBar();
	end
	
	PopColorStyles(buttonColorStylesNormal);
	;
	--PopVarStyles(buttonVarStyles);
	imgui.PopStyleVar();
	imgui.PopStyleVar();
	
	ui.customFont.Scale = old_scale;
	imgui.PopFont();
	
	imgui.End();
	end
	
end
end



function SummonTrusts()
	if (summoning) then
		if GetTableLen(ui.trustList) <= 0 then
			summoning = false;
			summoningTimer = 0;
			summoningIdx = 1;
			summoningTable = 0;
			summoningStart = 0;
			return;
		end
		if (ui.currentConfig.slowMode[1]) then slowExtra = 2.6; else slowExtra = 0; end
		if (summoningTimer >= ui.currentConfig.waitTime+slowExtra) then
			AshitaCore:GetChatManager():QueueCommand(1, ui.currentConfig.presetLists[summoningTable][summoningIdx]);
			summoningTimer = 0;
			summoningIdx = summoningIdx +1;
			summoningStart = os.clock();
		else
			summoningTimer = (os.clock()-summoningStart);
		end
		if (summoningIdx > GetTableLen(ui.currentConfig.presetLists[summoningTable])) then
			summoning = false;
			summoningTimer = 0;
			summoningIdx = 1;
			summoningTable = 0;
			summoningStart = 0;
		end
	end
end	

ashita.events.register('load', 'load_cb', function ()

	ui.currentConfig = settings.load(cfg, 'cfg');
	ui.customFont = imgui.AddFontFromFileTTF(addon.path..'/fonts/CarroisGothicSC-Regular.ttf',30);
	ui.customFont2 = imgui.AddFontFromFileTTF(addon.path..'/fonts/calibri.ttf',30);
	
	
end);

ashita.events.register('unload', 'unload_cb', function ()
    if (ui.font ~= nil) then
        ui.font:destroy();
        ui.font = nil;
    end
end);

ashita.events.register('command', 'command_cb', function (e)

    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/trusts')) then
        return;
    end

    e.blocked = true;

    if (#args == 1) then
        ui.currentConfig.isVisible = not ui.currentConfig.isVisible;
		save_settings();
        return;
    end
	
	for p = 1,5 do
		if (#args == 2 and args[2]:any(string.format('p%s', p))) then
			if (not summoning) then summoningTable = p; summoning = true; end
			return;
		end
    end
	
	for p = 1,5 do
		if (#args == 3 and args[2]:any('reset') and args[3]:any(string.format('p%s', p))) then
			if (not summoning) then
				ui.currentConfig.presetLists[p] = T{};
				save_settings();
			end
			return;
		end
    end
	
	return;
end);

function dec2Hex(decimal)
    return string.format("%x", decimal)
end

function PushColorStyles(styles)
	for _, s in pairs(styles) do
		imgui.PushStyleColor(s[1], s[2]);
	end
end

function PopColorStyles(styles)
    for _ in pairs(styles) do
		imgui.PopStyleColor();
	end
end

function PushVarStyles(styles)
	for _, s in pairs(styles) do
		imgui.PushStyleVar(s[1], s[2]);
	end
end

function PopVarStyles(styles)
    for _ in pairs(styles) do
		imgui.PopStyleVar();
	end
end

function GetTableLen(sometable)
	local count = 0;
	if (sometable ~= nil) then
		for _ in pairs(sometable) do count = count + 1 end		
	end
	return count;
end

function FindInTable(sometable, f)
	local idx = 0;
	if (sometable ~= nil) then
		for _, t in pairs(sometable) do
			idx=idx+1;
			if (t == f) then return idx end
		end
	end
	return false
end
