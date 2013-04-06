select distinct m.mixId, m.mixName, m.code, m.editable, m.length, m.currentLength, u.userName, u.userId, count(*) c
from mixPlays p, mix m, userMix um, user u
where p.mixId = m.mixId
and m.public=0
and m.validStatusId = 1
and um.mixId = m.mixId
and um.ownerId = u.userId
{{#select.today}}
	and p.playDate > DATE_ADD(now(),INTERVAL -10 DAY)
{{/select.today}}
group by m.mixId
order by c desc, mixName
{{#select.limit}}
limit {{select.limit}}
{{/select.limit}}	