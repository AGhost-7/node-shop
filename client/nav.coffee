
navCtrl = ($scope, $rootScope, $http) ->

  $scope.logout = ->
    $http
      .post('/user/logout')
      .success( ->
        $rootScope.username = undefined
      )

app.controller('navCtrl', ['$scope', '$rootScope', '$http', navCtrl])
