hadoop streaming won't completely handle the group_by key perfectly for you. 

It will sort all the output from mapper by key and you will face a huge table sorted and you need to write some logic to manually group them. 

I have written some logic in both R and Python. 

Here are a few things that need to be figured out:
(1) delimiter, say your key contains multiple columns or your value contains multiple column. 
The delimiter for your columns inside key, column should be different from the ones that used to delimit key and value. 

For example:
key: firstname, lastname 
value: timestamp, weight, height

Then you need to specifify delimiter1(like '\t') and delimiter2 (like '|')

Eric|Cartman\t2014-11-11|50|3\n

(2) Error handling
Python:
Figure out a way pipe errors into a separate file for later debug.

R: in R, the error handling is not that as straight forward as Python. 
We need to suppress all the warnings.
