let test_positive () = Alcotest.(check int) "2 + 3" 5 (App.Calc.add 2 3)

let test_negative () =
  Alcotest.(check int) "-2 + -3" (-5) (App.Calc.add (-2) (-3))

let test_zero () = Alcotest.(check int) "0 + 0" 0 (App.Calc.add 0 0)

let () =
  Alcotest.run "app"
    [
      ( "add",
        [
          Alcotest.test_case "positive" `Quick test_positive;
          Alcotest.test_case "negative" `Quick test_negative;
          Alcotest.test_case "zero" `Quick test_zero;
        ] );
    ]
