for any search application to fully serve the user, you need to have funtionalities including autocomplete, fuzzy match, and even customized search queries due to the fact
that users might not even know exactly what they want. 

This is an appliation using Django, Haystack and Solr to run a POC project. 

1. To learn more about Solr, [RTFM](http://apache.mirrors.ionfish.org/lucene/solr/ref-guide/apache-solr-ref-guide-5.2.pdf)
2. To learn more about Haystack, [RTFM](http://django-haystack.readthedocs.org/en/v2.4.0/)



Sample data was downloaded from [unitedstateszipcodes.org](http://www.unitedstateszipcodes.org/zip_code_database.csv).  





export SOLR_HOME=/home/datafireball/development/solr-5.2.1
export CORE_HOME=~/Desktop/inventory/search/sampleData
$SOLR_HOME/bin/solr start -s $CORE_HOME -d $SOLR_HOME/server
# you have to copy a bunch of files from 
cp ./server/solr/configsets/basic_configs/conf/* $CORE_HOME/conf/
curl "http://localhost:8983/solr/admin/cores?action=CREATE&name=coreX&instanceDir=$CORE_HOME&config=solrconfig.xml&schema=schema.xml&dataDir=data"
curl http://localhost:8983/solr/coreX/update/csv --data-binary @$CORE_HOME/zip_code_database.csv -H 'Content-type:text/plain; charset=utf-8'
