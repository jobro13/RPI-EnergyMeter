-- Simple mail lib.
local Mail = {}

-- read config;

Mail.Config = require 'MailConfig';

-- Subject is retrieved from Mail.Config.Subject[SubjectKey];
-- MsgBody is the input necessary to send the mail.
-- SubjectFormat is formatted into the subject
-- This solution is ugly
function Mail:SendMail(MsgBody, SubjectKey, SubjectFormat)
	local Subject = self.Config.Subject[SubjectKey];
	if not Subject then
		error("no subject set for key: " .. tostring(SubjectKey));
	end
	Subject = string.format(Subject, SubjectFormat);
	
	local tmpname = os.tmpname();
	local f = io.open(tmpname, "w+");
	f:write("Content-Type: text/html \r\nSubject: "..Subject.."\r\n\r\n");
	f:write(MsgBody);
	f:flush()
	
	
	local cmd = string.format(self.Config.Command, tmpname, table.concat(Mail.Config.Recipients,", "));
	os.execute(cmd);
	f:close()
	os.remove(tmpname)
end

return Mail
