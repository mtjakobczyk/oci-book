
create table ROADEVENTS_FACT (
  time_dim_id     char(6) not null,
  road_dim_id     char(6) not null,
  event_dim_id    char(7) not null,
  occurrence      number(10) not null,
  injured         number(10) not null,
  killed          number(10) not null,
  constraint pk_roadevents_fact
    primary key (time_dim_id, road_dim_id, event_dim_id),
  constraint fk_road_dim
    foreign key (road_dim_id)
      references ROAD_DIM(segment_id),
  constraint fk_event_dim
    foreign key (event_dim_id)
      references EVENT_DIM(event_id),
  constraint fk_time_dim
    foreign key (time_dim_id)
      references TIME_DIM(day_id)
);
