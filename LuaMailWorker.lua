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
	return true;
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

local EmailBody = [=[<html>
		<body>
			<H1>Raspberry Pi Energy Monitor Report</H1>
		]=]



-- Finish mail

local EmailEnd = [=[</body></html>]=];

EmailBody = EmailBody .. EmailEnd;

Mailer:SendMail(EmailBody, "Daily", os.date("%A %d %B %Y", Today));


-- check for double keys (not necessary anymore, is now done when writing keys)


