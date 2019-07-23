/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM country_club.facilities cf WHERE cf.membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT count(name) FROM country_club.facilities cf WHERE cf.membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT cf.facid, cf.name, cf.membercost, cf.monthlymaintenance FROM country_club.facilities cf 
WHERE cf.membercost > 0 
AND cf.membercost < (cf.monthlymaintenance * 0.2);

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * FROM country_club.facilities cf
WHERE cf.facid in (1, 5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT cf.name, cf.monthlymaintenance,
CASE WHEN cf.monthlymaintenance > 100 THEN 'expensive'
       ELSE 'cheap' END AS monthlymaintenance_facilities
FROM country_club.facilities cf;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT cm.firstname, cm.surname
FROM country_club.members cm
WHERE cm.joindate = (
    SELECT MAX(cm.joindate)
    FROM country_club.members cm
);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT cf.name as facility_name, 
CONCAT(cm.firstname , ' ', cm.surname) as member_name
FROM country_club.bookings cb 
INNER JOIN country_club.facilities cf ON cb.facid = cf.facid
INNER JOIN country_club.members cm ON cb.memid = cm.memid AND cb.memid > 0
AND cf.name LIKE 'Tennis Court%'
ORDER BY 2;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT cf.name as facility_name,
       CONCAT(cm.firstname , ' ', cm.surname) as user_name,
       CASE WHEN cb.memid = 0 THEN (cb.slots * cf.guestcost)
            ELSE (cb.slots * cf.membercost)
       END as cost
FROM country_club.bookings cb 
INNER JOIN country_club.facilities cf ON cb.facid = cf.facid AND cb.starttime like '2012-09-14%'
INNER JOIN country_club.members cm ON cb.memid = cm.memid
AND (CASE WHEN cb.memid = 0 THEN (cb.slots * cf.guestcost)
            ELSE (cb.slots * cf.membercost)
       END) > 30
ORDER BY 3 DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT cost_fun.facility_name,
       CONCAT(cm.firstname , ' ', cm.surname) as user_name,
       cost_fun.cost
FROM country_club.members cm
INNER JOIN (
    SELECT cf.name as facility_name,
           cb.memid as memid,
           CASE WHEN cb.memid = 0 THEN (cb.slots * cf.guestcost)
                ELSE (cb.slots * cf.membercost)
           END AS COST
    FROM country_club.bookings cb
    INNER JOIN country_club.facilities cf
    ON cb.facid = cf.facid
    AND cb.starttime like '2012-09-14%'
    ) cost_fun on cm.memid = cost_fun.memid
AND cost_fun.cost > 30
ORDER BY 3 DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT cf.name AS facility_name,
       sub1.total_revenue
FROM country_club.facilities cf
INNER JOIN (
    SELECT cf.facid as facid,
           sum(
               CASE WHEN sub2.client_type = 'guest' THEN sub2.total_slots * cf.guestcost
                    ELSE sub2.total_slots * cf.membercost
               END
           ) AS total_revenue
    FROM country_club.facilities cf
    INNER JOIN (
        SELECT cf.facid AS facid,
               CASE WHEN cb.memid = 0 THEN 'guest' ELSE 'member' END AS client_type,
               sum(cb.slots) AS total_slots
        FROM country_club.bookings cb
        INNER JOIN country_club.facilities cf ON cb.facid = cf.facid
        GROUP BY facid, client_type
    ) sub2 ON cf.facid = sub2.facid
    GROUP BY 1
) sub1 ON cf.facid = sub1.facid
AND sub1.total_revenue < 1000
ORDER BY 2;
