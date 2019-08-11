
create table ROAD_DIM (
  segment_id          char(6) not null,
  segment_name        varchar2(50) not null,
  segment_type        char(2) not null,
  segment_voivodeship varchar2(50) not null,
  segment_highway     varchar2(50),
  segment_expressway  varchar2(50),
  road_id             varchar2(10) not null,
  road_name           varchar2(10) not null,
  road_lenght         number(5),
  constraint pk_road_dim primary key (segment_id),
  constraint chk_segment_type
  	check ( segment_type in ('A','S','GP','G'))
);
