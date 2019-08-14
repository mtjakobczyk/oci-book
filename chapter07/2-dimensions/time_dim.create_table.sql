
create table TIME_DIM (
  day_id          char(6) not null,
  day_date        DATE not null,
  day_name        varchar2(20) not null,
  month_id        char(4) not null,
  month_of_year   number(2) not null,
  month_name      varchar2(20) not null,
  year_id         char(2) not null,
  year_name       char(6) not null,
  constraint pk_time_dim primary key (day_id)
);
