
homeCtrl = ($scope) ->
    $scope.greet = 'hello from Angular!'


app.controller('homeCtrl', ['$scope', homeCtrl])
