#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "mexico.h"

Field_Value *IP;

FS_CGI_arg FSexpect[] = {
  { "REMOTE_ADDR", &IP, "0123456789"},
  NULL
};

int FSquery()
{
  FS_panel p2;
  int err;

  mexicoHeader("Regions of Mexico",NULL);
  printf("<FORM ACTION=\"%s/mexico1.cgi\">\n", CGI_URL_BASE);
  printf("Select Region: ");
  printf("<SELECT NAME=\"Region\">\n");
  p2 = FSsetPanel(2);
  err = FSfirstRec(p2,1);
  while (err == FS_OK) {
    printf("<OPTION");
    printf(">%s\n",FSfield(p2,1)->field_data);
    err = FSnextRec(p2);
  }
  printf("</SELECT>\n");
  printf("<INPUT TYPE=SUBMIT VALUE=\"Select Region\">\n");
  printf("</FORM>\n");
  mexicoTrailer(10);
  return FS_OK;
}
