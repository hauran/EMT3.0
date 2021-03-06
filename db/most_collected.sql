select distinct m.mixId, m.mixName, m.code, m.editable, m.length, m.currentLength, u.userName, u.userId, count(*) c
from userMix um, mix m, user u
where um.mixId = m.mixId
and m.public=0
and m.validStatusId = 1
and um.ownerId = u.userId
group by mixId
order by c desc, mixName
{{#select.limit}}
limit {{#row}}{{row}}{{/row}}{{^row}}0{{/row}},{{select.limit}}
{{/select.limit}}	
{{^select.limit}}{{#row}}
limit {{row}},5
{{/row}}{{/select.limit}}