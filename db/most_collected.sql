select distinct m.mixId, m.mixName, m.code, m.editable, m.length, m.currentLength, count(*) c
from userMix um, mix m
where um.mixId = m.mixId
and m.public=0
and m.validStatusId = 1
group by mixId
order by c desc, mixName
{{#select.limit}}
limit {{select.limit}}
{{/select.limit}}	