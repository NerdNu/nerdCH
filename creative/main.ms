export('sharedata.source', 'creative')
export('sharedata.source.color', 'RED')

try(
	export('shared.firstjoin.book', read('firstjoinbook.txt')),
@e,
	console('firstjoinbook.txt does not exist. No default rulebook will be set.')
);

# The maximum length of a LogBlock rollback or redo. Defaults to 21 if unset.
# This number should match both the automatic log expiry query and the time 
# limit on rollbacks set in plugins/LogBlock/config.yml.
export('lb.retention.days', 21)

