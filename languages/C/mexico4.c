#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "mexico.h"

Field_Value *City;
Field_Value *IP;

FS_CGI_arg FSexpect[] = {
  { "City", &City, NULL},
  { "REMOTE_ADDR", &IP, "0123456789"},
  NULL
};

int FSquery()
{
  FS_panel p1, p20;
  int err;
  char title[50];
  Field_Value *comment, *fv;
  int needBR;
  int pictureQ;

  p1 = FSsetPanel(1);
  err = FSequalRec(p1,FSifList(p1,6,City));
  if (err != FS_OK) {
    apologies(1);
  } else {
    CityCodeForLinks = City;
    strcpy(title,FSfield(p1,2)->field_data);
    strcat(title," Restaurants");
    mexicoHeader(title,"#E1E1FF");
    startTable("CCCCFF");
    p20 = FSsetPanel(20);
    err = FSequalRec(p1,FSifList(p1,6,City));
    err = FSsubFirstRec(p20,FSifList(p20,6,FSfield(p1,16),NULL));
    if (err != FS_OK) {
      haveNoListing("Restaurants",FSfield(p1,2)->field_data);
    }
    while (err == FS_OK) {
      pictureQ = hasPicture(FSfield(p20,24),"AA");
      if (pictureQ) {
	printf("<table border=\"0\" width=\"100%%\" cellspacing=\"0\" cellpadding=\"0\">\n");
	printf("<tr>\n");
	printf("<td width=30%% valign=top align=center>\n");
	emitPictureAndCredits(FSfield(p20,24),"AA");
	printf("</td>\n");
	printf("<td width=70%% valign=top>\n");
	printf("<blockquote>\n");
	printf("<font face=\"Arial, Tahoma\">\n");
      }
      printf("%s<br>\n", FSfield(p20,1)->field_data);
      needBR = 0;
      printf("<small>\n");
      if (pictureQ
	  && (strncmp(FSfield(p20,17)->field_data,"http://",7)==0
	  || strncmp(FSfield(p20,17)->field_data,"https://",8)==0)) {
	printf("<A HREF=%s/countr.cgi?Name=URLv%04d&Refer=",
	  CGI_URL_BASE_COUNT,
	  atoi(FSfield(p20,24)->field_data));
	emitURLencoded(FSfield(p20,17)->field_data);
	printf(">%s</A>\n",
	  "Visit their Website");
        printf("<br>\n");
      }
      fv = FSfield(p20,3);
      if (*(fv->field_data) && *(fv->field_data)!=' ') {
	printf("<font color=\"#993333\">Address</font> %s ",
	  fv->field_data);
	needBR = 1;
      }
      fv = FSfield(p20,9);
      if (*(fv->field_data) && *(fv->field_data)!=' ') {
	printf("<font color=\"#993333\">Food Type</font> %s ",
	  fv->field_data);
	needBR = 1;
      }
      fv = FSfield(p20,13);
      if (*(fv->field_data) && *(fv->field_data)!=' ') {
	printf("<font color=\"#993333\">Dress</font> %s ",
	  fv->field_data);
	needBR = 1;
      }
      fv = FSfield(p20,7);
      if (*(fv->field_data) && *(fv->field_data)!=' ') {
	printf("<font color=\"#993333\">Tel</font> %s ",
	  fv->field_data);
	needBR = 1;
      }
      if (needBR) printf("<br>\n");
      comment = FSfield(p20,22);
      if (*(comment->field_data)) {
	printf("<font color=\"#993333\">Comment</font> ");
	emitHTMLencoded(comment->field_data);
	printf("<br>\n");
      }
      printf("</small>\n");
      if (pictureQ) {
	printf("</font>\n");
	printf("</blockquote>\n");
	printf("</td>\n");
	printf("</tr>\n");
	printf("</table>\n");
      }
      printf("<br>\n");
      err = FSsubNextRec(p20);
    }
    endTable();
  }
  mexicoTrailer(5);
  return FS_OK;
}
