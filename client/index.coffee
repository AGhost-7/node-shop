
app = angular.module('node-shop', ['ngRoute'])

app
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
    .when('/login',
      templateUrl: '/html/login.tmpl'
      controller: 'loginCtrl'
    )
    .when('/cart',
      templateUrl: 'html/cart.tmpl'
      controller: 'cartCtrl'
    )
    .otherwise(redirectTo: '/home')

])
.run(['$rootScope', '$http', ($rootScope, $http) ->
  $rootScope.username = undefined

  $http
    .get('/user')
    .success((data) -> $rootScope.username = data.name)
])
