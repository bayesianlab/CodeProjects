select *
from Insample
where Country='Australia';

select *
FROM OutSample
where Dt> (select max(Dt)
            from Insample
            where Country='Australia')


