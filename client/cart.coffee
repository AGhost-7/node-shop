

cartCtrl = ($scope, $http) ->
  $scope.methods = ['Paypal', 'Credit']

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
  
  $scope.purchase = (method)->
    $http
      .post('/purchase', method: method)
      .success((res) ->
        $scope.items = []# don't need to update rest...
        $scope.error = undefined
      )
      .error((res) -> $scope.error = res.message)


app.controller('cartCtrl', ['$scope', '$http', cartCtrl])
