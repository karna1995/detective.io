angular.module('detective.service').factory("Common", [ '$resource', '$http', ($resource, $http)->
    $resource '/api/common/v1/:type/:id/', {}, {
        get:
            method : 'GET'
            isArray: no
        put:
            method : 'put'
            isArray: no
        query:
            method : 'GET'
            isArray: yes
            transformResponse: $http.defaults.transformResponse.concat([(data, headersGetter) ->
                data.objects
            ])
        cachedGet:
            method : 'GET'
            isArray: no
            cache  : yes
        cachedQuery:
            method : 'GET'
            isArray: yes
            cache  : yes
            transformResponse: $http.defaults.transformResponse.concat([(data, headersGetter) ->
                data.objects
            ])
    }
])