size: 1000px 500px;
dpi: 200;
#limit-x: 1404278100 1404299700;
limit-y: 1 300;

axes {
  position: bottom left;
  label-format-x: datetime("%H:%M:%S");
  label-placement-x: linear-align(1800);
}

legend {
  position: top right;
  item-flow: on;

  item {
    label: "WAN1->chg#25";
    color: #00f;
  }
  item {
    label: "WAN2->chg#25";
    color: #f00;
  }
  item {
    label: "WAN4->chg#25";
    color: #0f0;
  }
}

grid {
    stroke-color: rgba(0 0 0 0.2);
    stroke-style: dashed;
    tick-placement-x: none;
}

lines {
  data-x: csv("Today-wan1.csv" epoch);
  data-y: csv("Today-wan1.csv" chg);
  color: #00f;
}

lines {
  data-x: csv("Today-wan2.csv" epoch);
  data-y: csv("Today-wan2.csv" chg);
  color: #f00;
}

lines {
  data-x: csv("Today-wan4.csv" epoch);
  data-y: csv("Today-wan4.csv" chg);
  color: #0f0;
}
