loginCtrl = ($scope, $http, $location, $rootScope) ->

  $scope.login = (n, pw)->
    $http(
      method: 'POST'
      url: '/user/login'
      data:
        name: n
        password: pw
    )
    .success((data) ->
      $rootScope.username = data.name
      $location.path('/home')
    )
    .error((data) ->
      $scope.error = data.message
    )

app.controller('loginCtrl', ['$scope', '$http', '$location', '$rootScope', loginCtrl])
