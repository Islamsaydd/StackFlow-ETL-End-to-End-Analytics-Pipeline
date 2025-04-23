-------------------------
-- Dimension Tables
-------------------------
 
-- Date Dimension
CREATE TABLE Date_Dim (
	FullDate DATE NOT NULL UNIQUE,
	DateKey INTEGER PRIMARY KEY NOT NULL,
	DayOfMonth INTEGER NOT NULL CHECK (DayOfMonth BETWEEN 1 AND 31),
	Month INTEGER NOT NULL CHECK (Month BETWEEN 1 AND 12),
	Year INTEGER NOT NULL,
	DayOfWeek INTEGER NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
	DayName VARCHAR(9) NOT NULL,
    	WeekOfYear INTEGER NOT NULL CHECK (WeekOfYear BETWEEN 1 AND 53),
	MonthName VARCHAR(9) NOT NULL,
	Quarter INTEGER NOT NULL CHECK (Quarter BETWEEN 1 AND 4),
	FiscalYear INTEGER NOT NULL
);
 
-- Users Dimension
CREATE TABLE Users_Dim (
	CreationDate DATE  ,
	DisplayName VARCHAR(255) NULL,
DownVotes INTEGER NOT NULL DEFAULT 0 CHECK (DownVotes >= 0) ,
	User_BK INTEGER NOT NULL,
	LastAccessDate DATE NULL,
	Reputation INTEGER NOT NULL DEFAULT 0 CHECK (Reputation >= 0),
	UpVotes INTEGER NOT NULL DEFAULT 0 CHECK (UpVotes >= 0),
Views INTEGER NOT NULL DEFAULT 0 CHECK (Views >= 0),	
User_SK INTEGER  PRIMARY KEY NOT NULL
);
 
-- Question Description Dimension
CREATE TABLE Questions_Dim (
	Question_BK INTEGER NOT NULL UNIQUE,
	OwnerUserId INTEGER NULL,
	CreationDate DATE NULL,
AcceptedAnswerId INTEGER NULL,
	Body TEXT NULL,
	Title VARCHAR(255) NULL,
	Question_SK INTEGER  PRIMARY KEY NOT NULL
);
 
-- Answer Description Dimension
CREATE TABLE Answers_Dim (
	Answer_BK VARCHAR(255) NOT NULL,
	ParentId INTEGER NOT NULL,
OwnerUserId INTEGER NOT NULL,
	Body TEXT NULL,
	Answer_SK INT PRIMARY KEY NOT NULL
);
 
-- Tags Dimension
CREATE TABLE Tags_Dim (
	Tag_BK INTEGER NOT NULL UNIQUE,
	TagName VARCHAR(35) NOT NULL,
	Total_Count INTEGER NULL CHECK (Total_Count >= 0),
	TagDesc TEXT NULL,
	Tag_SK INTEGER  PRIMARY KEY NOT NULL
);
 
-- Vote Types Dimension
CREATE TABLE VoteTypes_Dim (
	VoteTypeId INTEGER  PRIMARY KEY NOT NULL,
	VoteTypeName VARCHAR(50) NOT NULL UNIQUE,
	Description TEXT NULL
);
 
-- Badge Description Dimension
CREATE TABLE Badges_Dim (
	Badge_BK INTEGER NOT NULL,
	Name VARCHAR(255) NOT NULL,
	Class VARCHAR(50) NULL,
	Badge_SK INTEGER  PRIMARY KEY NOT NULL
);
 
-------------------------
-- Fact Tables
-------------------------
 
-- Questions Fact
CREATE TABLE Questions_Fact (
Score INTEGER NOT NULL DEFAULT 0,
	ViewCount INTEGER NOT NULL DEFAULT 0 CHECK (ViewCount >= 0),
	AnswerCount INTEGER NOT NULL DEFAULT 0 CHECK (AnswerCount >= 0),
	CommentCount INTEGER NOT NULL DEFAULT 0 CHECK (CommentCount >= 0),
	
Question_FK INT NOT NULL UNIQUE
     	REFERENCES Questions_Dim(Question_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	User_FK INT NOT NULL
     	REFERENCES Users_Dim(User_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	CreationDate_FK INTEGER NOT NULL
     	REFERENCES Date_Dim(DateKey) ON UPDATE CASCADE ON DELETE RESTRICT,
    LastActivityDate_FK INTEGER NOT NULL
     	REFERENCES Date_Dim(DateKey) ON UPDATE CASCADE ON DELETE RESTRICT,
		PRIMARY KEY (Question_FK, User_FK, CreationDate_FK)
);
 
-- Answer Fact
CREATE TABLE Answers_Fact (
	Score INTEGER NOT NULL DEFAULT 0,
	CommentCount INTEGER NOT NULL DEFAULT 0 CHECK (CommentCount >= 0),

	Answer_FK INTEGER NOT NULL
     	REFERENCES Answers_Dim(Answer_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	User_FK INTEGER NOT NULL
     	REFERENCES Users_Dim(User_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	CreationDate_FK INTEGER NOT NULL
     	REFERENCES Date_Dim(DateKey) ON UPDATE CASCADE ON DELETE RESTRICT,
    	LastActivityDate_FK INTEGER NOT NULL
     	REFERENCES Date_Dim(DateKey) ON UPDATE CASCADE ON DELETE RESTRICT,
	ParentQuestion_FK INTEGER NOT NULL
     	REFERENCES Questions_Dim(Question_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
		PRIMARY KEY (Answer_FK, CreationDate_FK , ParentQuestion_FK, User_FK)
);
 
-- Votes Fact
CREATE TABLE Votes_Fact (
	Answer_FK INTEGER NULL
     	REFERENCES Answers_Dim(Answer_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	Question_FK INTEGER NOT NULL
     	REFERENCES Questions_Dim(Question_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	User_FK INTEGER NOT NULL
     	REFERENCES Users_Dim(User_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	CreationDate_FK INTEGER NOT NULL
     	REFERENCES Date_Dim(DateKey) ON UPDATE CASCADE ON DELETE RESTRICT,
	VoteType_FK INTEGER NOT NULL
     	REFERENCES VoteTypes_Dim(VoteTypeId) ON UPDATE CASCADE ON DELETE RESTRICT,
	VoteId INT NOT NULL,
            	PRIMARY KEY(VoteId, Question_FK, Answer_FK, CreationDate_FK, VoteType_FK)
);
 
-- Comment Fact
CREATE TABLE Comments_Fact (
    Score INTEGER NOT NULL DEFAULT 0,
    Text TEXT NULL,
    Answer_FK INTEGER NULL
        REFERENCES Answers_Dim(Answer_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
    Question_FK INTEGER NULL
        REFERENCES Questions_Dim(Question_SK) ON UPDATE CASCADE ON DELETE SET NULL,
    User_FK INTEGER NOT NULL
        REFERENCES Users_Dim(User_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
    CreationDate_FK INTEGER NOT NULL
        REFERENCES Date_Dim(DateKey) ON UPDATE CASCADE ON DELETE RESTRICT,
    CommentId INT NOT NULL,
    
    PRIMARY KEY(Answer_FK, Question_FK, CreationDate_FK, User_FK, CommentId)
);
 
-- Badge Fact
CREATE TABLE Badges_Fact (
	User_FK INTEGER NOT NULL
     	REFERENCES Users_Dim(User_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
	AssignedDate_FK INTEGER NOT NULL
     	REFERENCES Date_Dim(DateKey) ON UPDATE CASCADE ON DELETE RESTRICT,
	Badge_FK INT NOT NULL
 	    REFERENCES Badges_Dim(Badge_SK) ON UPDATE CASCADE ON DELETE RESTRICT,
IsTagBased SMALLINT NULL,
            	PRIMARY KEY(User_FK, AssignedDate_FK, Badge_FK)
);
 
-------------------------
-- Bridge Table
-------------------------
 
-- Question-Tags Bridge
CREATE TABLE Qs_Tags_Bridge (
	Questions_Desc_SK INTEGER NOT NULL
     	REFERENCES Questions_Fact(Question_FK) ON UPDATE CASCADE ON DELETE CASCADE,
	TagID INTEGER NOT NULL
     	REFERENCES Tags_Dim(Tag_BK) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (Questions_Desc_SK, TagID)
);
 
-------------------------
-- Indexes
-------------------------
CREATE INDEX idx_questions_fact_activity ON Questions_Fact(LastActivityDate_FK);
CREATE INDEX idx_answers_fact_parent ON Answers_Fact(ParentQuestion_FK);

-------------------------
-- Plat layer
-------------------------



CREATE TABLE Tags_Over_Time (
    tagname VARCHAR(255) NOT NULL,
    monthly_count INTEGER NOT NULL,
    monthly_cumulative_count INTEGER NOT NULL,
	date DATE NOT NULL              
);

CREATE TABLE DataEng_Tools_analysis (
    month DATE NOT NULL,               
    tool VARCHAR(255) NOT NULL,         
    count INTEGER NOT NULL,             
    Cumulative_count INTEGER NOT NULL  
);

CREATE TABLE Engagement_Badge (
    diff_date INTEGER NOT NULL,          
    engagements INTEGER NOT NULL,        
    class VARCHAR(10) NOT NULL         
);
CREATE TABLE Programming_Languages_analysis (
    month DATE NOT NULL,                
    language VARCHAR(50) NOT NULL,      
    count INTEGER NOT NULL,            
    Cumulative_count INTEGER NOT NULL   
);

SELECT current_user;

