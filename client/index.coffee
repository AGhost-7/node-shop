
angular
.module('node-shop', ['ngRoute'])
.config(['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when('/home',
      templateUrl: '/html/home.tmpl'
      controller: 'homeCtrl'
    )
    .when('/product',
      templateUrl: '/html/products.tmpl'
      controller: 'productCtrl'
    )
    .otherwise(redirectTo: '/home')
])
.controller('homeCtrl', ['$scope', ($scope) ->
  $scope.greet = 'hello from Angular!'
])
.controller('productCtrl', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
  $scope.page = $routeParam.page ? 1

  $scope.search = ->
    $http(method: 'GET', url: '/product', data: { page: $scope.page })
      .success((data) ->
        $scope.items = data
        $scope.digest()
      )

])
