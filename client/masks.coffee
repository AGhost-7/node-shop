
app
.directive('currencyModel', ->
  restrict: 'A'
  require: 'ngModel'
  link : (scope, el, attrs, ctrl) ->
    last = undefined
    ctrl.$parsers.push((input) -> 
      if !el.val().match(/^[0-9]*[.]{0,1}[0-9]{0,2}$/g)
        ctrl.$setViewValue(last)
        ctrl.$render()
      else
        last = el.val()
    )
)
.directive('intModel', ->
  restrict: 'A'
  require: 'ngModel'
  link: (scope, el, attrs, ctrl) ->
    last = undefined
    ctrl.$parsers.push((input) ->
      if !el.val().match(/^[0-9]*$/g)
        ctrl.$setViewValue(last)
        ctrl.$render()
      else
        last = el.val()
    )
)
