function commitHandler(result)
{
	if(result && result.commits)
	{
		var divs = [];
		var count = Math.min(result.commits.length, 5);
		for(var iter = 0; iter < count; iter++)
		{
			var data = result.commits[iter];
			var date = new Date(data.committed_date);
			var div = '<div class="commit">' +
				'<a class="date" href="http://github.com'+data.url+'">'+date.toLocaleDateString()+'</a>' +
				'<div class="message">'+data.message+'</div>' +
				'</div>';
			divs.push(div);
		}
		$('#commit-log').html(divs.join(''));
	}
}

function tweetHandler(result)
{
	if(result)
	{
		var divs = [];
		var count = Math.min(result.length, 10);
		for(var iter = 0; iter < count; iter++)
		{
			var data = result[iter];
			var date = new Date(data.created_at);
			var div = '<div class="tweet">' +
				'<div class="message">'+data.text+'</div>' +
				'<div class="date">'+date.toLocaleDateString()+'</div>' +
				'</div>';
			divs.push(div);
		}
		$('#tweet-log').html(divs.join(''));
	}
}
