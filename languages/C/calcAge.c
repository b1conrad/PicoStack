#include <stdio.h>
#include <stdlib.h>

int calcAge(int);

int main()
{
  /* this is the main program */
  int year;
  int age;
  char name[80];
  char pause[80];

  printf("Enter your name: ");
  scanf("%s", name);

  printf("Enter the year of your birth.");
  scanf("%d",&year);

  age = calcAge(year);
  printf("%s, your age is %d.\n",name, age);
  scanf("Press any key to continue. %s",pause);

  return 0;
} /* end of main */

int calcAge(int birthYear)
{
  int diff;

  printf("year passed = %d\n", birthYear);
  diff = 2003 - birthYear;

  return diff;
}
