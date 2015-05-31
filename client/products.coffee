
productCtrl = ($scope, $routeParams, $http) ->

  $scope.page = $routeParams.page ? 1
  $scope.manufacturers = []
  $scope.categories = []

  $scope.foo = ['a', 'b', 'c']
  watchParams = ['minprice', 'maxprice', 'manufacturer', 'category', 'order']
  paramNames = watchParams.concat('page')

  search = ->
    params = {}
    for name in paramNames
      if $scope[name]? && $scope[name] != ''
        params[name] = $scope[name]
    $http(method: 'GET', url: '/product', params: params)
      .success((data) ->
        $scope.items = data
      )

  for name in watchParams
    $scope.$watch(name, (n, o)->
      if n != o
        $scope.page = 1
        search()
    )
    $scope.$watch('page', search)

  $scope.purchase = (item, amount) ->
    console.log(item, amount)





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

  $scope.changePage = (i) ->
    if $scope.page + i > 0 then $scope.page += i



app.controller('productCtrl', ['$scope', '$routeParams', '$http', productCtrl])
