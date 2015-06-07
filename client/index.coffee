
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
    .when('/register'
      templateUrl: 'html/register.tmpl'
      controller: 'registerCtrl'
    )
    .when('/purchases'
      templateUrl: 'html/purchases.tmpl'
      controller: 'purchasesCtrl'
    )
    .otherwise(redirectTo: '/home')

])
.run(['$rootScope', '$http', '$location', ($rootScope, $http, $location) ->
  $rootScope.username = undefined

  $http
    .get('/user')
    .success((data) -> $rootScope.username = data.name)

  permissions =
    logged: ['purchases', 'cart', 'product', 'home']
    notLogged: ['login', 'home', 'product', 'register']

  $rootScope.$on('$locationChangeStart', (ev, newLoc, oldLoc) ->
    loc = newLoc.substring(newLoc.lastIndexOf('/') + 1)
    prevent = false
    if $rootScope.username?
      if !permissions.logged.some((elem) -> loc == elem)
        prevent = true
    else
      # user isn't logged in
      if !permissions.notLogged.some((elem) -> loc == elem)
        prevent = true
        ev.preventDefault()

    if prevent
      ev.preventDefault()
      if newLoc == oldLoc
        $location.path('/home')
  )
])
