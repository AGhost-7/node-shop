

cartCtrl = ($scope, $http) ->

  $http
    .get('/cart')
    .success((data) ->
      for key, val of data
        $scope[key] = val
    )

  $scope.remove = (item, index) ->
    $http
      .delete('/cart/' + item.id)
      .success((res) ->
        $scope.items.splice(index, 1)

        $scope.subtotal = res.subtotal
        $scope.tax = res.tax
        $scope.total = res.total
      )

app.controller('cartCtrl', ['$scope', '$http', cartCtrl])
