
app = angular.module('node-shop', ['ngRoute'])
console.log('hello world')


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
    .otherwise(redirectTo: '/home')
])
