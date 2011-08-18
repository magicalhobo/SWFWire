function commitHandler(result)
{
	if(result && result.commits)
	{
		var divs = [];
		for(var iter = 0; iter < 5; iter++)
		{
			var data = result.commits[iter];
			var date = new Date(data.committed_date);
			var div = '<div class="commit">' +
				'<div class="date"><a class="id" href="http://github.com'+data.url+'">'+date.toLocaleDateString()+' by '+data.author.login+'</a></div>' +
				'<div class="message">'+data.message+'</div>' +
				'</div>';
			divs.push(div);
		}
		$('#commit-log').html(divs.join(''));
	}
}
