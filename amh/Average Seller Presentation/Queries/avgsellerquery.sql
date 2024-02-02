/* 
  Using the same model that encountered problem looks 
*/ 

select *
from MizerTrainOutput 
where ModelId = 79747158

-- Get the same looks this model was trained on 
exec LoadObjId 79335887 
exec LoadObj 'MyMizerTrainOutput.TrainInputId'  
exec Rm #TrainActionCollectionId  
select CollectionId  
into #TrainActionCollectionId  
from MyMizerTrainInput i  
where CollectionId is not null  
union select CollectionId = convert(int, l.Txt)  
from MyMizerTrainInput i  
cross apply List(i.CollectionIdList) l  
  
create unique clustered index cidx on #TrainActionCollectionId (CollectionId)  
  
exec Rm #TrainActionGetLooks  
select   
    l.*,  
    BenchMarginPrice = round(isnull(bmp.BenchMarginPrice, 0), 4),  
    WinBoundaryMarginPrice = coalesce(cd.BoundaryMarginPrice, case when cd.WinBit = 1 then cd.MarginPrice end),  
    LossBoundaryMarginPrice = coalesce(cd.BoundaryMarginPrice, case when cd.WinBit = 0 then cd.MarginPrice end),  
    WinAboveObjectiveWt = 0,  
    WinBelowObjectiveWt = 1,  
    LossAboveObjectiveWt = 1,  
    LossBelowObjectiveWt = case when cd.BoundaryMarginPrice is null then isnull(i.LossBelowObjectiveWt, 0) else 0 end,
	cd.MarginPrice
into #TrainActionGetLooks  
from #TrainActionCollectionId cid  
join MizerCollectionDtl cd  
    on cid.CollectionId = cd.Id  
join MizerLook ml  
    on cd.LookId = ml.LookId  
join EzMizerLookForModel l  
    on cd.LookId = l.LookId  
left join MizerDailyBenchMargin bmp  
    on ml.BidDt = bmp.BidDt  
cross join MyMizerTrainInput i  
where cd.BoundaryMarginPrice is not null  
    or cd.WinBit is not null  
  
create unique clustered index cidx on #TrainActionGetLooks (LookId)  
  
if exists (select * from MyMizerTrainInputIgnoreFeature)  
begin  
  
    declare @UpdateColSql varchar(max)  
  
    select @UpdateColSql = string_agg(convert(varchar(max),   
    'update #TrainActionGetLooks  
        set ' + ColName + ' = ''''  
        where ' + ColName + ' in (' + ColValList + ')'), '; ')  
    from (  
        select   
            ColName,  
            ColValList = dbo.MakeList('''' + ColVal + '''')  
        from MyMizerTrainInputIgnoreFeature  
        group by ColName) c  
  
    exec(@UpdateColSql)  
  
end  

select * from #TrainActionGetLooks

-- Compute weighted averages for each seller in the trained dataset
select 'SellerName_' + SellerName as SellerName, convert(float, Count(SellerName))/(select count(*) from #TrainActionGetLooks)  as SellerPct
from #TrainActionGetLooks t 
group by SellerName
order by SellerPct desc



-- Load the model id 
exec LoadObj 79747158




-------------------
/*
  The problem looks 
*/ 
-------------------
select l.LookId, l.SellerName, d.S, d.M, d.W 
from MizerResultDtl d
join MizerLook l on l.LookId=d.LookId
where 
  d.LookId in 
  (
  	1878756,1878757,1878759,1878760,1878762,1878764,
  	1878765,1878767,1878768,1878769,1878770,1878771,
  	1878773,1878775
  )
  and 
  Id = 80424759
order by l.LookId desc 
----------------------------------------------
/*
  Run MizerProcess with default name Paramount
*/ 
----------------------------------------------

select ml.*
from MizerCollection c
join MizerCollectionDtl cd
    on c.Id = cd.Id
join MizerLook ml 
    on ml.LookId = cd.LookId
where c.Id = 80424683
order by c.Id desc 

exec CopyObj 72521766
insert MyMizerEvalInput (ModelId, CollectionId, RecreateBit, DefaultSellerName, ScriptPath)
values(79747158,80424683,1,'Paramount', '\\corp.lan\Shares\TradingDesk\Analytics\Cronus\Market\MarginOptimization\Python\2023-12-26\')
exec RunJob MizerEval 

insert MyMizerProcessInput (DescTxt, ModelId, TunerId, ShiftId, RecreateBit, CollectionId) --MizerModel
values('dmv_paramount', 79747158, 72474205,72474206, 1, 80424683)
exec RunJob MizerProcess

select  ml.SellerName, d.S, d.M,  d.W 
from MizerResultDtl d 
join MyMizerProcessOutputDtl p on p.ResultId=d.Id
join MizerLook ml on d.LookId=ml.LookId
where SellerName='PinnacleFinancialPartners' 

----------------------------------------------------
/*
    Run MizerProcess without any default seller name 
*/ 
----------------------------------------------------

exec CopyObj 72521766
insert MyMizerEvalInput (ModelId, CollectionId, RecreateBit, DefaultSellerName, ScriptPath)
values(79747158,80424683,1,'', '\\corp.lan\Shares\TradingDesk\Analytics\Cronus\Market\MarginOptimization\Python\2023-12-26\')
exec RunJob MizerEval 

insert MyMizerProcessInput (DescTxt, ModelId, TunerId, ShiftId, RecreateBit, CollectionId) --MizerModel
values('dmv_no_default', 79747158, 72474205,72474206, 1, 80424683)
exec RunJob MizerProcess

-- Get the output id for this run 
select * from MizerProcessOutput where ProcessInputId in 
(
  select Id from MizerProcessInput where DescTxt='dmv_no_default'
)


select  ml.SellerName, d.S, d.M,  d.W 
from MizerResultDtl d  
join MyMizerProcessOutputDtl p on p.ResultId=d.Id
join MizerLook ml on d.LookId=ml.LookId
where SellerName='PinnacleFinancialPartners' 


------------------------
/*
  Getting looks for test
*/
------------------------

select e.Id, NeededCnt, DefaultSellerName, i.*
from MizerEvalOutput e 
join MizerEvalInput i
	on i.Id=e.EvalInputId
where i.ModelId=79747158 and  e.Id=81407105
order by NeededCnt desc

exec rm #Looks
select e.*, BenchMarginPrice = round(isnull(bmp.BenchMarginPrice, 0), 4),
  r.MarginPrice, r.LockBit as WinBit, uidentifier = row_number() over (partition by ml.LookId order by ml.LookId)
into #Looks
from MizerEvalInputLook eil
join MizerLook ml 
  on ml.LookId = eil. LookId 
left join MizerDailyBenchMargin bmp
  on ml.BidDt = bmp.BidDt
join EzMizerLookForModel e 
  on e.LookId=ml.LookId
join MarginRpt r
  on r.SellerLoanNumTxt=ml.SellerLoanNumTxt 
where eil.Id=81407104 

delete from #Looks where uidentifier>1

select * from #Looks 
where MarginPrice is not null and WinBit is not null
order by LookId 


/*
  Get Looks with Pinnacle and also have MarginPrice and WinBit
*/ 
-- Get the MizerEvalInput to get the looks I need to join
-- winbit and margin price to the table 


exec CopyObj 72521764
select * from MizerEvalInput

exec LoadObj 80424683

update MyMizerEvalInput 
set RecreateBit=1, ModelId=79747158, CollectionId=80424683, 
    BaseModelPath='\\corp.lan\shares\TradingDesk\Analytics\Cronus\Market\MarginOptimization\Model\', 
    ScriptPath='\\corp.lan\shares\TradingDesk\Analytics\Cronus\Market\MarginOptimization\Python\2023-12-26\',
	DefaultSellerName=''

exec RunJob MizerEval


insert MyMizerProcessInput (DescTxt, ModelId, TunerId, ShiftId, RecreateBit, CollectionId) --MizerModel
values('dmv_get_looks', 79747158, 72474205,72474206, 1, 80424683)
exec RunJob MizerProcess





select * from MizerProcessOutputDtl 
where Id=87444495

exec rm #NeededLooks 
select ROW_NUMBER() over (partition by ml.LookId order by mr.MarginPrice) rowid,
    l.*, 
    BenchMarginPrice = round(isnull(bmp.BenchMarginPrice, 0), 4),
	mr.LockBit WinBit, mr.MarginPrice
into #NeededLooks 
from MizerResultDtl rd
join MyMizerProcessOutputDtl pd
  on pd.ResultId=rd.Id
join MizerLook ml
  on ml.LookId=rd.LookId
join EzMizerLookForModel l  
    on ml.LookId = l.LookId 
left join MizerDailyBenchMargin bmp  
    on ml.BidDt = bmp.BidDt
left join MarginRpt mr
  on ml.SellerLoanNumTxt=mr.SellerLoanNumTxt


delete from #NeededLooks
where rowid <> 1


exec rm #uid  
select LookId, count(*)
--ROW_NUMBER() over (order by LookId) rowid, LookId 
--into #uid 
from #NeededLooks
group by LookId

exec rm #temp1
select LookId, count(*) as Cnt
into #temp1
from #NeededLooks
group by LookId

select *
from #temp1
where Cnt > 1

select n.* 
from #uid u
join #NeededLooks n
  on u.rowid=n.rowid



exec Rm #EvalLook  
select l.*, 
--rd.MarginPrice, rd.LockBit WinBit,
    BenchMarginPrice = round(isnull(bmp.BenchMarginPrice, 0), 4),
	uidentifier = row_number() over (partition by ml.LookId order by ml.LookId)
into #EvalLook  
from MyMizerEvalOutputNeededLook nl  
join MizerLook ml  
    on nl.LookId = ml.LookId  
join EzMizerLookForModel l  
    on nl.LookId = l.LookId  
left join MizerDailyBenchMargin bmp  
    on ml.BidDt = bmp.BidDt
join MarginRpt rd
	on rd.SellerLoanNumTxt=ml.SellerLoanNumTxt


 

delete from #EvalLook where uidentifier>1 

exec MizerEvalAction GetLooks, 	87444484	