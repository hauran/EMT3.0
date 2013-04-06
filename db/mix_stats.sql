

select @collected := count(*)
from userMix
where mixId = {{mixId}}
group by mixId;

select @plays := count(*)
from mixPlays
where mixId = {{mixId}}
group by mixId;

select @collected 'collected', @plays 'plays';
