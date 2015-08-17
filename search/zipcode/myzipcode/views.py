from django.shortcuts import render

# Create your views here.


def search_zipcodes(request):
    zipcodes = SearchQuerySet().autocomplete(content_auto=request.POST.get('search_text', ''))
    return render_to_response('ajax_search.html', {'zipcodes':zipcodes})
