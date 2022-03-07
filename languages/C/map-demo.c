#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "mexico.h"

Field_Value *Cities;
Field_Value *MapN;
Field_Value *IP;

FS_CGI_arg FSexpect[] = {
  { "Cities", &Cities, "CUNMEXACA"},
  { "Map", &MapN, "1"},
  { "REMOTE_ADDR", &IP, "0123456789"},
  NULL
};

int FSquery()
{
  FS_panel p5, p67;
  int err;
  Field_Value *city;
  int i;
  int offX, offY, sizX, sizY;
  int dotX, dotY, mapX, mapY;
  char *cities;

  mexicoHeader("Selected Cities in Mexico",NULL);
  printf("<MAP NAME=\"cities\">\n");
  p67 = FSsetPanel(67);
  cities = Cities->field_data;
  for ( i=0; i+3<=strlen(cities); i+=3) {
    city = NewField('0',0,3,&cities[i]);
    printf("<!-- %s -->\n", city->field_data);
    err = FSequalRec(p67,FSifList(p67,1,MapN,city));
    if (err == FS_OK) {
      sizX = atoi(FSfield(p67,3)->field_data);
      sizY = atoi(FSfield(p67,4)->field_data);
      dotX = atoi(FSfield(p67,5)->field_data);
      dotY = atoi(FSfield(p67,6)->field_data);
      mapX = atoi(FSfield(p67,7)->field_data);
      mapY = atoi(FSfield(p67,8)->field_data);
      offX = mapX - dotX; if (offX < 0) offX = 0;
      offY = mapY - dotY; if (offY < 0) offY = 0;
      printf("<area shape=rect coords=\"%d,%d, %d,%d\" ",
	offX, offY, offX+sizX, offY+sizY);
      printf("href=\"http://www.KnowMexico.com/cities/%s/\">\n",
	FSfield(p67,2)->field_data);
    }
  }
  printf("</MAP>\n");
  printf("<H2>Selected Cities in Mexico</H2>\n");
  printf("<CENTER>\n");
  printf("<IMG SRC=\"%s/mx.cgi/Map=%s&City=%s\"",
    CGI_URL_BASE,
    MapN->field_data,
    cities);
  printf(" ALT=\"Selected Cities in Mexico\" ISMAP USEMAP=\"#cities\">\n");
  printf("</CENTER>\n");
  mexicoTrailer(0);
  return FS_OK;
}
