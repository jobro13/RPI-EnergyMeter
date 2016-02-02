return {
		-- Subject lines
		Subject = {
				Daily = "Energy Monitor: Daily report of %s";
				Weekly = "Energy Monitor: Weekly report of %s";
				Monthly = "Energy Monitor: Monthly report of %s";
				Yearly = "Energy Monitor: Yearly report of %s";
			},
		-- Recipients of the mail
		Recipients = {
				"user1@host.com";
				"user2@host.com";
			},
		-- 
		Command = "cat %s | ssmtp %s";
	}
				
