
registerCtrl = ($scope, $http, $rootScope, $location) ->

  $scope.register = ->
    if $scope.password != $scope.password2
      $scope.error = 'Passwords do not match'
    else
      $http(
        url: '/user/register'
        method: 'POST'
        data:
          name: $scope.name
          email: $scope.email
          password: $scope.password
          )
        .success((res) ->
          $rootScope.username = res.name
          $location.path('/home')
        )
        .error((res) ->
          $scope.error = res.message
        )

app.controller('registerCtrl',
    ['$scope', '$http', '$rootScope', '$location', registerCtrl])
