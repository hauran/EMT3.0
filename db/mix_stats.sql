

select @collected := count(*)
from userMix
where mixId = {{#mixId}}{{mixId}}{{/mixId}}{{^mixId}}{{id}}{{/mixId}}
group by mixId;

select @plays := count(*)
from mixPlays
where mixId = {{#mixId}}{{mixId}}{{/mixId}}{{^mixId}}{{id}}{{/mixId}}
group by mixId;

select @collected 'collected', @plays 'plays';
