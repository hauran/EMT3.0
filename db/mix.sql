select distinct m.mixId, m.mixName, m.code, m.editable, m.length, m.currentLength, u.userName, u.userId
from userMix um, mix m, user u
where um.mixId = m.mixId
and m.validStatusId = 1
and um.ownerId = u.userId
and m.mixId = {{id}}
