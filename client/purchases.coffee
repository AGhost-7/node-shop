purchasesCtrl = ($scope, $http)->
  $scope.receipts = []
  $http
    .get('/purchase')
    .success((res) ->
      $scope.receipts = res
    )

app.controller('purchasesCtrl', ['$scope', '$http', purchasesCtrl])
