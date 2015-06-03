

cartCtrl = ($scope, $http) ->
  
  $http
    .get('/cart')
    .success((data) ->
      for key, val of data
        $scope[key] = val
    )

app.controller('cartCtrl', ['$scope', '$http', cartCtrl])
