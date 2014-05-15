/*
    Some day of the week utilities - Phil Vasey - 04 Apr 96
    -------------------------------------------------------

    This file contains utilities related to returning the current date in
    a long and short format and for returning the number of the current
    day of the week.
*/

% long_date/4 - returns the current date in long format

long_date( DayName, DateDay, MonthName, Year ):-
  date( DateDay, MonthNumber, Year ),
  day_of_week( DateDay, MonthNumber, Year, DateNumber ),
  day_of_week( DateNumber, _, DayName ),
  month_of_year( MonthNumber, _, MonthName ).

% short_date/4 - returns the current date in short format

short_date( DayName, DateDay, MonthName, Year ):-
  date( DateDay, MonthNumber, Year ),
  day_of_week( DateDay, MonthNumber, Year, DateNumber ),
  day_of_week( DateNumber, DayName, _ ),
  month_of_year( MonthNumber, MonthName, _ ).

% day_of_week/1 - returns the number of the current weekday
%
% where sunday = 1 and saturday = 7

day_of_week( DayNumber ) :-
  date( Day, Month, Year ),
  day_of_week( Day, Month, Year, DayNumber ) .

% day_of_week/4 - returns the day, month, and year and the number of the
%		   current weekday
% the algorithm is based upon January 1st 1900 being a sunday

day_of_week( Day, Month, Year, DayNumber ) :-
  date( Day, Month, Year, DaysSince1600 ),
  DayNumber is ((DaysSince1600 - 2) mod 7) + 1.

% day_of_week/3 - a database of short and a long mnemonics for the
%		   numbered days of the week

day_of_week(    1, sun, 'Sunday'    ).
day_of_week(    2, mon, 'Monday'    ).
day_of_week(    3, tue, 'Tuesday'   ).
day_of_week(    4, wed, 'Wednesday' ).
day_of_week(    5, thu, 'Thursday'  ).
day_of_week(    6, fri, 'Friday'    ).
day_of_week(    7, sat, 'Saturday'  ).

% month_of_year/3 - a database of short and a long mnemonics for the
%		     numbered months of the year

month_of_year(  1, jan, 'January'   ).
month_of_year(  2, feb, 'February'  ).
month_of_year(  3, mar, 'March'     ).
month_of_year(  4, apr, 'April'     ).
month_of_year(  5, may, 'May'       ).
month_of_year(  6, jun, 'June'      ).
month_of_year(  7, jul, 'July'      ).
month_of_year(  8, aug, 'August'    ).
month_of_year(  9, sep, 'September' ).
month_of_year( 10, oct, 'October'   ).
month_of_year( 11, nov, 'November'  ).
month_of_year( 12, dec, 'December'  ).
