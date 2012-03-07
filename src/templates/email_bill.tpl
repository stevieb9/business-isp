
-------------------------------------------------
ISP [%type%] #[%invoice_number%] for ClientID: [%username%]
-------------------------------------------------


Date:	[%date%]

Payment Method:	[%payment_method%]


[% FOREACH item IN items %]
Qty: [%item.quantity%] [%item.item_name%] Un Pr: [%item.amount%] Total: [%item.total_price%]
Description: [%item.comment%]

[% END %]


Tax		[%tax%]
Sub-Total	[%sub_total%]
Total		[%grand_total%]


-------------------------------------------------
