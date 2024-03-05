--Buoc 1: Tinh gia tri R-F-M
with customer_rfm as
(select a.customer_id, 
current_date-max(b.order_date) as R,
count(distinct b.order_id) as F,
sum(b.sales) as M
from customer as a
join sales as b on a.customer_id=b.customer_id
group by a.customer_id)

--Buoc 2: Chia cac gia tri thanh khoang tren thang diem 1-5
, rfm_score as
(select customer_id,
ntile(5) over (order by R desc) as r_score,
ntile(5) over (order by F) as f_score,
ntile(5) over (order by M) as m_score
from customer_rfm)

--Buoc 3: Phan nhom theo 125 to hop RFM
, rfm_final as
(select customer_id,
cast(r_score as varchar)||cast(f_score as varchar)||cast(m_score as varchar) as rfm_score
from rfm_score)

select segment, count(*) from
(select rfm_final.customer_id, segment_score.segment
from rfm_final
join segment_score on rfm_final.rfm_score=segment_score.scores) a
group by segment
order by segment

--Buoc 4: Truc quan hoa tren excel, power bi
