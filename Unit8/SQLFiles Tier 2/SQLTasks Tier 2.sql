/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name FROM Facilities WHERE membercost <> 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(membercost) FROM Facilities WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost * 5 < monthlymaintenance AND membercost <> 0;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities WHERE facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
    CASE WHEN monthlymaintenance > 100 THEN `expensive`
    ELSE `cheap` END
    AS cost
FROM `Facilities`;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname FROM `Members` WHERE joindate = (SELECT MAX(joindate) AS newest FROM `Members`)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name, CONCAT(m.firstname, ` `, m.surname) AS fullname
FROM `Bookings` AS b
LEFT JOIN `Facilities` AS f
USING (facid)
LEFT JOIN `Members` AS m
USING (memid)
WHERE facid = 0 OR facid = 1
ORDER BY fullname;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, CONCAT(m.firstname, ` `, m.surname) AS fullname,
    CASE WHEN memid = 0 THEN f.guestcost
    ELSE f.memcost END AS cost
FROM `Bookings` AS b
LEFT JOIN `Facilities` AS f
USING (facid)
LEFT JOIN `Members` AS m
USING (memid)
WHERE cost > 30 AND starttime LIKE `2012-09-14%`
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT f.name, CONCAT(m.firstname, ` `, m.surname) AS fullname,
    CASE WHEN memid = 0 THEN f.guestcost
    ELSE f.memcost END AS cost
FROM (SELECT facid, memid, starttime FROM Bookings WHERE starttime LIKE `2012-09-14%`) AS subset
LEFT JOIN `Facilities` AS f
USING (facid)
LEFT JOIN `Members` AS m
USING (memid)
WHERE cost > 30
ORDER BY cost DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

WITH cte AS(
    SELECT name,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid <> 0) * f.membercost AS memrev,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 0) * f.guestcost AS guestrev
    FROM FACILITIES AS f)
SELECT name, (memrev + guestrev) AS totalrev
FROM cte
WHERE totalrev < 1000
ORDER BY totalrev

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.surname AS surname, m1.firstname AS firstname, m2.surname AS recsurname, m2.firstname AS recfirstname
FROM MEMBERS AS m1
INNER JOIN MEMBERS AS m2
ON m1.recommendedby = m2.memid
ORDER BY surname, firstname

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT name,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 1) AS oneuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 2) AS twouse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 3) AS threeuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 4) AS fouruse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 5) AS fiveuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 6) AS sixuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 7) AS sevenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 8) AS eightuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 9) AS nineuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 10) AS tenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 11) AS elevenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 12) AS twelveuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 13) AS thirteenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 14) AS fourteenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 15) AS fifteenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 16) AS sixteenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 17) AS seventeenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 18) AS eighteenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 19) AS nineteenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 20) AS twentyuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 21) AS twentyoneuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 22) AS twentyetwouse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 23) AS twentythreeuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 24) AS twentyfouruse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 25) AS twentyfiveuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 26) AS twentysixuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 27) AS twentysevenuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 28) AS twentyeightuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 29) AS twentynineuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 30) AS thirtyuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 31) AS thirtyoneuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 32) AS thirtyetwouse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 33) AS thirtythreeuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 34) AS thirtyfouruse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 35) AS thirtyfiveuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 36) AS thirtysixuse,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND memid = 37) AS thirtysevenuse
FROM FACILITIES AS f

/* Q13: Find the facilities usage by month, but not guests */

SELECT name,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND starttime LIKE `2012-07%` AND memid <> 0) AS July,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND starttime LIKE `2012-08%` AND memid <> 0) AS August,
    (SELECT COUNT(facid)
        FROM BOOKINGS AS b
        WHERE f.facid = b.facid AND starttime LIKE `2012-09%` AND memid <> 0) AS September
FROM FACILITIES AS f