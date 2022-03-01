/* Airport nearby cities page */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "mexico.h"

Field_Value *City;
Field_Value *Airport;
Field_Value *IP;

FS_CGI_arg FSexpect[] = {
  { "City", &City, "XXX"},
  { "Airport", &Airport, NULL},
  { "REMOTE_ADDR", &IP, "0123456789"},
  NULL
};

int FSquery()
{
  FS_panel p1;
  int err;
  char title[80];

  p1 = FSsetPanel(1);
  if (Airport == NULL) {
    apologies(1);
  } else {
    err = FSsubFirstRec(p1,FSifList(p1,1,City,NULL));
    if (err!=FS_OK || FSrecCount(p1)<=0) {
      apologies(2);
    } else {
      strcpy(title,"Cities near the ");
      strcat(title,Airport->field_data);
      strcat(title," Airport");
      mexicoHeader(title,"#FFFF99");
      err = FSsubFirstRec(p1,FSifList(p1,1,City,NULL));
      printf("<p>\n");
      printf("Select City: ");
      while (err == FS_OK) {
        printf("<a href=\"http://www.knowmexico.com/city/%s/\">",
        FSfield(p1,16)->field_data);
        emitHTMLencoded(FSfield(p1,2)->field_data);
        printf("</a>");
        err = FSsubNextRec(p1);
        if (err == FS_OK) {
          printf(", ");
        } else {
          printf("\n");
        }
      }
      printf("</p>\n");
    }
  }
  mexicoTrailer(0);
  return FS_OK;
}
