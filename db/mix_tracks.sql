select p.mixId, s.songId, s.title, s.url 'url', s.duration 'dur', s.type 
from song s, playlist p  
where p.mixId = {{mixId}}
and p.songId = s.songId 
and p.flag=0 
and p.validStatusId =1 
and s.validStatusId = 1 
order by p.sort
{{#select.limit}}
	limit {{select.limit}}
{{/select.limit}}