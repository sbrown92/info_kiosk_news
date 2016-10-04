#! /bin/bash
# Author: Samuel Brown. 
# Class: UNIX Systems
# Description: This was an assignment to build a web scraper that would be part
#			   of an information kiosk. The kiosk would have three columns, each 
#			   with a different top story from the World News section of the 
#			   Washington Times website. The window must be atleast 149X25px. 
clear

# Download the source from the website.
wget -qO- www.washingtontimes.com/news/national > output.txt

if [ -s output.txt ]
then
																	  
	grep -o '<a href="/news/[^"]*" title="[^"]*' output.txt |		        # Search the source code for the anchor tag 
	sed "s/&#[1-9]*;/\'/g" | sed 's/<a href="[^"]*" title="//g' > titles.txt	# containing the title, then scrape the 
				                                                        # article title from the title tag. 
																																		


	grep -o '</div><p>[^<]*' output.txt | sed "s|&#[1-9]*;|\'|g"| 	                # Do the same for the <p> tag that contains
	sed 's|&mdash;|-|g' | sed 's;</div><p>;;g' | sed 's;^[\t]*;;g' > stories.txt	# the body of the article. 
	
	
	
	i=0
	while read line;		# Loop through the file that the titles
	do			        # are stored in and populate an array 					
		titles[$i]=$line        # with each line. 
		i=$((i+1))
	done < titles.txt
	rm -f titles.txt # Delete titles.txt
	
	i=0
	while read line;		# Do the same with the file that the 
	do 			        # stories are stored in. 
		if [ ${#line} -gt 100 ]
		then
			stories[$i]=$line
			i=$((i+1))
		fi
	done < stories.txt
	rm -f stories.txt # Delete stories.txt
	
	
	WIDTH=0
	numStories=0
	while [ $numStories -le 5 ];	# Loop through the first 6 positions of 
	do 				# the titles and stories array. 
		
		str=""
		
		str+="${titles[$numStories]}."			 
		str+="\n\n"				# Format the title and story entries
		str+="${stories[$numStories]}"
		numStories=$((numStories+1))
		
		echo -e $str | fold -sw 35 > temp.txt	# Fold is used to create text-wrapping to 
							# ensure that the story will fit in the column,
							# before being stored in a temporary text file.  
		numLine=0
		if [ -s temp.txt ]
		then
			while read line;		  # The temporary file is looped through line by line, 
			do 			          # using tput to move the curser and create the columns. 
				tput cup $numLine $WIDTH		
				printf  '%-40s'  "$line"
	
				numLine=$((numLine+1))
			done < temp.txt
			rm -f temp.txt
			
			while [ $numLine -le 19 ];
			do
				tput cup $numLine $WIDTH;
				echo "                                       "
				numLine=$((numLine+1))
				
			done
		fi
		
	
		
		if [ $WIDTH -eq 0 ]
		then
			WIDTH=52 
		else 
			if [ $WIDTH -eq 52 ]		# After printing each column, shift the WIDTH position
			then 				# to the
				WIDTH=103
			else
				if [ $WIDTH -eq 103 ]
				then
					WIDTH=0
					sleep 2
				fi
			fi
		fi
		
			
		
	done
	

fi
