
create table EVENT_DIM (
  event_id        char(7) not null,
  event_name      varchar2(50) not null,
  category_id     char(4) not null,
  category_name   varchar2(50) not null,
  class_id        char(1) not null,
  class_name      varchar2(50) not null,
  constraint pk_event_dim primary key (event_id)
);
