#!/bin/bash
LOGFILE="$HOME/Maildir/mailboxes.log"

# if this is set, we shouldn't run. e.g. for muttedit
if [ -f /tmp/muttedit-inhibit ]
then
	rm -f /tmp/muttedit-inhibit >/dev/null 2>&1 
	exit 0
fi

if [ "x$1" = "x"  ]
then
	newMail=$(
			cd $HOME/Maildir ;
			( 
			  find . -not -path '*Drafts*' -name "*:2," -exec dirname '{}' \; ;
			  find . -not -path '*Drafts*' -path "*new*" -type f -name "*.*" -exec dirname '{}' \;
			) | uniq | sort  
		)
else
	newMail=""
fi
if [[ "$newMail" == "" ]]
then
	echo -n "+ " 
	while read REPLY 
	do
		echo -n "+\"$REPLY\" "
	done < ~/Maildir/subscriptions
	cat ~/.mutt/muttrc.imap-sources
else
	echo -e "state1:\n\t$newMail" >> $LOGFILE
	newMail=${newMail//"./cur"/" = "}
	echo -e "state2:\n\t$newMail" >> $LOGFILE
	newMail=${newMail//"./new"/" = "}
	echo -e "state3:\n\t$newMail" >> $LOGFILE
	newMail=${newMail//"/new"}
	echo -e "state4:\n\t$newMail" >> $LOGFILE
	newMail=${newMail//"/cur"}
	echo -e "state5:\n\t$newMail" >> $LOGFILE
	newMail=${newMail//"./"/"="}
	echo -e "final state:\n\t$newMail" >> $LOGFILE
	echo -n $newMail
fi
