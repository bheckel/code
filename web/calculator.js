let calculator = {
  sum() {
    return this.a + this.b;
  },

  mul() {
    return this.a * this.b;
  },

  read() {
    this.a = +prompt('a?', 0);
    this.b = +prompt('b?', 0);
  }
};

calculator.read();
alert( calculator.sum() );
alert( calculator.mul() );


// or

function Calculator() {
  this.read = function() {
    this.a = +prompt('a?', 0);
    this.b = +prompt('b?', 0);
  };

  this.sum = function() {
    return this.a + this.b;
  };

  this.mul = function() {
    return this.a * this.b;
  };
}

let calculator = new Calculator();
calculator.read();

alert( "Sum=" + calculator.sum() );
alert( "Mul=" + calculator.mul() );



// or

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <script src="https://en.js.cx/test/libs.js"></script>
  <script src="test.js"></script>
</head>
<body>

  <script>

    function Calculator() {
    
      let methods = {
        "-": (a, b) => a - b,
        "+": (a, b) => a + b
      };
    
      this.calculate = function(str) {
    
        let split = str.split(' '),
          a = +split[0],
          op = split[1],
          b = +split[2]
    
        if (!methods[op] || isNaN(a) || isNaN(b)) {
          return NaN;
        }
    
        return methods[op](a, b);
      }
    
      this.addMethod = function(name, func) {
        methods[name] = func;
      };
    }

  </script>

</body>
</html>
let powerCalc = new Calculator;
powerCalc.addMethod("*", (a, b) => a * b);
powerCalc.addMethod("/", (a, b) => a / b);
powerCalc.addMethod("**", (a, b) => a ** b);
let result = powerCalc.calculate("2 ** 3");
alert( result ); // 8
