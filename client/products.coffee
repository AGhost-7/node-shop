
productCtrl = ($scope, $routeParams, $http) ->
  $scope.page = $routeParams.page ? 1
  $scope.manufacturers = []
  $scope.categories = []

  $scope.foo = ['a', 'b', 'c']
  paramNames = ['page', 'minprice', 'maxprice', 'manufacturer', 'category', 'order']
  $scope.$watch('page', -> console.log('page changed'))

  $scope.search = ->
    console.log('search...')
    params = {}
    for name in paramNames
      params[name] = $scope[name]
    $http(method: 'GET', url: '/product', params: params)
      .success((data) ->
        console.log(data)
        $scope.items = data
      )

  $scope.search()

  $scope.purchase = (item, amount) ->
    console.log(item, amount)

  for name in paramNames
    $scope.$watch(name, $scope.search)

  # reapply = ->
  #   if $scope.$$phase
  #     setTimeout(reapply, 300)
  #   else
  #     $scope.$apply()



  $http
    .get('/product/manufacturer')
    .success((data) ->
      $scope.manufacturers = [undefined].concat(data)
    )

  $http
    .get('/product/category')
    .success((data) ->
      $scope.categories = [undefined].concat(data)
    )


app.controller('productCtrl', ['$scope', '$routeParams', '$http', productCtrl])
