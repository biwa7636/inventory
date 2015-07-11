from django.shortcuts import render
from django.http import HttpResponse

def index(request):
    return HttpResponse(request.body)



# Create your views here.
