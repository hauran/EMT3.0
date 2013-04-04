select distinct m.mixId, m.mixName, m.code, m.editable, m.length, m.currentLength, count(*) c
from mixPlays p, mix m
where p.mixId = m.mixId
and m.public=0
and m.validStatusId = 1
{{#select.today}}
	and playDate > DATE_ADD(now(),INTERVAL -10 DAY)
{{/select.today}}
group by mixId
order by c desc, mixName
{{#select.limit}}
limit {{select.limit}}
{{/select.limit}}	