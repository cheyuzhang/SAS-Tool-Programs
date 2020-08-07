dm log "clear";
dm odsresults "clear";
libname acc "/folders/myshortcuts/Box/ZZZ-Data Related files/ACCLAIM/SAS/";

proc sql;
create table work.summm as
select country, sex, n8, n3, n11, n51, nn41,nn42, nn43, nn44, 
		nn45, nn46, nn47, nn48, nn49, nn50, print
	from work.summ;
quit;

%macro cname(a);
%do b=1 %to 3;
	%do c=0 %to 1;
		use summm;
		do data; read all var {print} into ca&a&b&c where(n&a^=. & country=&b & sex=&c);end;
		do data; read all var {n&a} into cb&a&b&c where(n&a^=. & country=&b & sex=&c);end;
		create c&a&b&c var {"ca&a&b&c" "cb&a&b&c"}; append; close c&a&b&c;
	%end;
%end;
%mend cname;

%let names=8 3 11 51 n41 n42 n43 n44 n45 n46 n47 n48 n49 n50;

%macro cc(a,b);
	select coalesce (cb&a&b.0,cb&a&b.1) as value,ca&a&b.0,ca&a&b.1
		from work.c&a&b.0 full join work.c&a&b.1
		on cb&a&b.0=cb&a&b.1
%mend cc;

%macro chart(a);
create table work.ccn&a as
	select coalesce (dd.value,cc.value)as value,ca&a.10 as a10, 
				ca&a.11 as a11, ca&a.20 as a20, ca&a.21 as a21, ca&a.30 as a30, ca&a.31 as a31
		from (%cc(&a,1)) as dd full join 
			(select coalesce (aa.value,bb.value)as value, ca&a.20, ca&a.21, ca&a.30, ca&a.31
				from (%cc(&a,2)) as aa full join (%cc(&a,3))as bb
				on aa.value=bb.value
			)as cc
		on dd.value=cc.value;
%mend chart;

%macro imls;
proc iml; %do i=1 %to 14; %cname(%scan(&names,&i)); %end;quit;
proc sql;%do i=1 %to 14; %chart(%scan(&names,&i));%end;quit;
proc sql; %do i=1 %to 13; select * from ccn%scan(&names,&i) union all %end; 
		select * from ccn%scan(&names,14);run;
%mend imls;
%imls;
