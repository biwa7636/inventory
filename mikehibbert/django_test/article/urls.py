from django.conf.urls import include, url

urlpatterns = [
    url(r'^all/$',			'article.views.articles'), 
    url(r'^get/(?P<article_id>\d+)/$', 	'article.views.article'),
    url(r'^language/(?P<language>[a-z\-]+)/$', 'article.views.language'),
]
