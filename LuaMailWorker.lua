-- Run this script every day - around midnight

--local MAKE_ALL = true; -- This makes all summaries!! Run once, then disable.

local Mailer = require "MailLib";
local PD = require "PowerLib";
local DataProcessing = require "DataProcessing";

local SummaryFilename = PD:GetFilename("WriteSummary");

-- do the stuff necessary

local Today = os.time();
local TodayTable = os.date("*t", Today);
local DayDelta = 60*60*24;

-- Fix TodayTable to remove all hours and minutes and seconds; set those all to zero for midnight.

TodayTable.hour = 0;
TodayTable.min = 0;
TodayTable.sec = 0;

local Today = os.time(TodayTable);
local Yesterday = Today-DayDelta
local YesterdayTable = os.date("*t", Today-DayDelta);

local Jobs = {};

if TodayTable.yday == 1 then
	-- Generate yearly report!
	table.insert(Jobs, {"Yearly", YesterdayTable.year})
end
if TodayTable.day == 1 then
	-- Generate montly report!
	table.insert(Jobs, {"Monthly", os.date("%B %Y", Yesterday)});
end
if TodayTable.wday == 2 then
	-- It's monday. week report
	-- ugh.. get week number
	local datepipe = io.popen("date +%U");
	local f = datepipe:read();
	wnum = tonumber(f)
	datepipe:close()
	table.insert(Jobs, {"Weekly", "Week " .. wnum .. os.date(" %Y", Yesterday)});
end
table.insert(Jobs, {"Daily", os.date("%d %B %Y", Yesterday)})

-- Handy helper;
function round(r,n) return (math.floor((r*10^n)+0.5)/10^n) end

-- FIRST OF ALL: Write todays summary.



local function GetData(StartTime, EndTime)
	local Delta = EndTime-StartTime;
	return  DataProcessing:CollectData(Delta,EndTime);
end

-- DayTable has fields: day/month/year
-- DayStart is a timestamp
local function GetDayData(DayStart)
	local DayEnd = DayStart+DayDelta;
	return GetData(DayStart, DayEnd)
end

function MakeSummary(DayTimestamp)
	local Table = os.date("*t", DayTimestamp);
	local Identifier = os.date("%d/%m/%Y", DayTimestamp);
--	print(Identifier)
	--os.execute('sleep 10')
	local Data = GetDayData(DayTimestamp);
	if DataProcessing:DataIsEmpty(Data) then
		return false;
	end
	local Costs, SumData = DataProcessing:GetCosts(Data, true);
	for i,v in pairs(SumData) do
		print(i)
		for ind, val in pairs(v) do
			--print("\t", ind, val)
			-- ROUND
			v[ind] = round(val, 3) -- 3 digits round
			print("\t", ind, v[ind])
		end
	end
	PD:WriteSummary(Identifier, SumData, SummaryFilename)
	return true, SumData;
end

MakeSummary(Today);

local CurrentTimestamp = Today;
if MAKE_ALL then
	while true do
		CurrentTimestamp = CurrentTimestamp - DayDelta;
		local Result = MakeSummary(CurrentTimestamp)
		if not Result then
			--break
			os.exit()
		end
	end
end

-- Good, now there is a summary

local EmailBody = [=[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html>
		<body>
			<center>
		]=]

local EmailBody = EmailBody .. "<H1>Raspberry PI Energy Monitor Report ("..os.date("%A %d %B %Y", Yesterday) ..")</H1>\n"

---- HELPER FUNCTION
-- Data should be full data, so summed already;
-- Data is a list of fields: {
-- [1] = {Field1, Field2, Field3}
local function GetTableStr(Data)
	str = "";
	local function add(s) str=str..s end;
	add("<table border=\"1\">")
	--add("<tr>")
	for index, value in pairs(Data) do
		add("<tr>")
		print(index,value)
		for _, FieldText in pairs(value) do
			add("<td>"..FieldText.."</td>")
		end
		add("</tr>")
	end
	add("</table>")
	return str;
end		

function GetDayStr(Time)
	return os.date("%A %d %B %Y", Time)
end

function CollectDayData(Days)
	local DataOut = {}
	local AdditionalData = {} -- Still daily data
	local AdditionalStats = {}
	local Time = Today;
	local TotalC, TotalK=0,0; 
	local function mk(Time)
--		Time = Time - DayDelta;
		local DateIdent = os.date("%d/%m/%Y", Time)
		local Data = PD:GetSummary(DateIdent, SummaryFilename);
		if Data then
			local DayIdent = GetDayStr(Time);
			local TabMain = {DayIdent, Data};
			local TotalKWH, TotalCosts =0,0;
			for PriceClass, Value in pairs(Data) do
				TotalKWH = TotalKWH + Value.KWH;
				TotalCosts = TotalCosts + Value.Costs;
			end
			TotalC = TotalC + TotalCosts;
			TotalK = TotalK + TotalKWH;
			local TabOther = {DayIdent, {TotalKWH = TotalKWH, TotalCosts = TotalCosts}}
			table.insert(DataOut, 1, TabMain)
			table.insert(AdditionalData, 1, TabOther)
		else
			-- Something is off with data. Maybe it's not available. Skip.
		end
		
	end

	if type(Days) == "number" then
		for i = 1, Days do
			Time = Time - DayDelta
			mk(Time)
		end
	elseif type(Days) == "function" then
		while true do
			Time = Time - DayDelta;
			if Days(Time) then
				break
			else
				mk(Time)	
			end
		end
	end
	AdditionalStats.TotalCosts = TotalC;
	AdditionalStats.TotalKWH = TotalK;
	return DataOut, AdditionalData, AdditionalStats
end




--fu-nction Daily(EmailSubject)
	




--EmailBody = EmailBody .. "- - - - - + + + + + +\n"
--EmailBody = EmailBody .. "Totals: "..TotalKWH .. " kWh, " .. TotalCosts.. " euro\n"



-- Finish mail

local EmailEnd =[=[</center></body></html>]=];

--EmailBody = EmailBody .. EmailEnd;

-- Returns daily stuff
local function ConvtMainTable(Main)
	local Sampl = Main[1][2];
	local PList = {}
	for PriceClass in pairs(Sampl) do
		table.insert(PList, PriceClass);
		--PList[PriceClass] = #PList;
	end
		
	local Out = {}
	local Row1 = {"Day"}
	for i,v in ipairs(PList) do
		table.insert(Row1, "Rate " .. v .. " consumption (kWh)");
		table.insert(Row1, "Rate " .. v .. " costs (euro)");
	end
	table.insert(Out, Row1)
	for i, d in pairs(Main) do
		local Title = d[1];
		local Data = d[2];
--		print(Title)
--		for ind,val in pairs(Data) do print(ind,val) end
		local Row = {Title}
		for i,PriceClass in pairs(PList) do
			if Data[PriceClass] then
				table.insert(Row, Data[PriceClass].KWH);
				table.insert(Row, Data[PriceClass].Costs);
			else
				table.insert(Row, '-')
				table.insert(Row, '-')
			end
		end
		table.insert(Out, Row)
	end
	return Out
end
	

function Daily(Subject)
	local Main, Additional, Stats = CollectDayData(1);
--	print("data")
--	for i,v in pairs(Main) do
--		print(i,v)
--	end
	
	Email = GetEmail(Main, Additional, Stats);
	
	Mailer:SendMail(Email, "Daily", Subject)	
end

function Weekly(Subject)
	local Main, Additional, Stats = CollectDayData(7);
        Email = GetEmail(Main, Additional, Stats);

        Mailer:SendMail(Email, "Weekly", Subject)
end

function Monthly(Subject)
        local Main, Additional, Stats = CollectDayData(function(Timestamp) if os.date("*t", Timestamp).month ~= YesterdayTable.month then return true end end);
        Email = GetEmail(Main, Additional, Stats);

        Mailer:SendMail(Email, "Monthly", Subject)
end

function Yearly(Subject)
        local Main, Additional, Stats = CollectDayData(function(Timestamp) if os.date("*t", Timestamp).year ~= YesterdayTable.year then return true end end);
        Email = GetEmail(Main, Additional, Stats);

        Mailer:SendMail(Email, "Yearly", Subject)
end

-- Returns email body str;
function GetEmail(Main, Additional, Stats)
	
	-- Now start building the actual tables;
	local ActMain = ConvtMainTable(Main);
	local TabStr = GetTableStr(ActMain);
	local Email = EmailBody;
--	Email = Email .. "<H1>Raspberry Pi Energy Monitor Report of " .. GetDayStr(Today);
	Email = Email.."<br></br>"
	Email = Email..TabStr

	local StatTable = {{"", "Consumption (kWh)", "Costs"}}
	StatTable[2] = {"Totals" , Stats.TotalKWH, Stats.TotalCosts}
	Email = Email .. "<br></br>"
	Email = Email .. GetTableStr(StatTable)	

	Email = Email..EmailEnd;

	return Email
end
	
	
	
	


--Mailer:SendMail(EmailBody, "Daily", os.date("%A %d %B %Y", Yesterday));

-- TODO: make week/month/year reports.


--function Daily(Subject)
	--print("do daily job")
	
	
--end

for i,v in pairs(Jobs) do
	getfenv()[v[1]](v[2]) -- call str;
end

--[[Weekly('test')
Monthly('test')
Yearly('test')
--]]
-- check for double keys (not necessary anymore, is now done when writing keys)


