function commitHandler(result)
{
	if(result && result.data)
	{
		var divs = [];
		var count = Math.min(result.data.length, 5);
		for(var iter = 0; iter < count; iter++)
		{
			var data = result.data[iter];
			var date = new Date(data.commit.author.date);
			var div = '<div class="commit">' +
				'<a class="date" href="https://github.com/magicalhobo/SWFWire/commit/'+data.sha+'">'+date.toLocaleDateString()+'</a>' +
				'<div class="message">'+data.commit.message+'</div>' +
				'<div class="author"><a href="https://github.com/'+data.author.login+'">'+data.commit.author.name+'</a></div>' +
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
