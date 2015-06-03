
productCtrl = ($scope, $routeParams, $http) ->

  $scope.page = $routeParams.page ? 1
  $scope.manufacturers = []
  $scope.categories = []

  watchParams = ['name', 'minprice', 'maxprice', 'manufacturer', 'category', 'order']
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
    $http(
      method: 'POST'
      url: "/cart/#{item.id}/#{amount}"
    )
    .success((data) =>
      item.quantity -= amount
      if item.quantity == 0
        $scope.items = $scope.items.filter((e) -> e.id != item.id)
      else
        # Make it so that the dropdown goes back to its original state
        this.amount = undefined
    )

  $scope.range = (from, to) -> [undefined].concat([from..to])

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
