/* drop assignment1 database if they already exisits */
create database if not exists assignment1;
use assignment1;

/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

-- Question #1. Find the titles of all movies directed by Steven Spielberg.

USE assignment1; 
SELECT
	title,
    director
FROM Movie
WHERE director = 'Steven Spielberg'
ORDER BY title;

-- Question #2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

SELECT DISTINCT year
FROM Movie, Rating
WHERE Movie.mID = Rating.mID AND stars IN (4,5)
ORDER BY year;

-- Question #3. Find the titles of all movies that have no ratings

SELECT
	title
FROM Movie
WHERE Movie.mID NOT IN (SELECT mID FROM Rating);

-- Question #4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.

SELECT
	name
FROM Reviewer AS rev
JOIN Rating AS r
WHERE rev.rID = r.rID AND ratingDate IS NULL;

-- Question #5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.

SELECT
	name,
    title,
    stars,
    ratingDate
FROM Movie as m
JOIN Rating as r
	ON m.mID = r.mID
RIGHT JOIN Reviewer AS rev
	ON rev.rID = r.rID
ORDER BY name, title, stars;

-- Question #6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.

SELECT
	name,
    title
FROM Movie as m
RIGHT JOIN Rating r1 USING(mID)
RIGHT JOIN Rating r2 USING(rID)
RIGHT JOIN Reviewer USING(rID)
WHERE r1.mID = r2.mID AND r1.ratingDate < r2.ratingDate and r1.stars < r2.stars;

-- Question #7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

SELECT
	title,
    MAX(stars)
FROM Movie
RIGHT JOIN Rating USING(mID)
GROUP BY mID
ORDER BY title;

-- Question #8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.

SELECT
 	title,
    MAX(stars) - MIN(stars) AS Rating_Spread
FROM Movie
RIGHT JOIN Rating USING(mID)
GROUP BY mID
ORDER BY Rating_Spread DESC, title;

-- Question #9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)

SELECT AVG(Before1980.avg) - AVG(After1980.avg)
FROM (
  SELECT AVG(stars) AS avg
  FROM Movie
  RIGHT JOIN Rating USING(mId)
  WHERE year < 1980
  GROUP BY mId
) AS Before1980, 

(
  SELECT AVG(stars) AS avg
  FROM Movie
  RIGHT JOIN Rating USING(mId)
  WHERE year > 1980
  GROUP BY mId
) AS After1980;

