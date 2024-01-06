import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
//import 'package:flutter_redux_hooks/flutter_redux_hooks.dart'
import 'package:redux/redux.dart';
import 'package:math_expressions/math_expressions.dart';

abstract class Action {}

class CalculateExpressionAction extends Action {}

class ClearAction extends Action {}

class InputExpressionAction extends Action {
  final value;
  InputExpressionAction(this.value);
}

class CalculatorState {
  String expression = '';

  CalculatorState.initial();

  @override
  String toString() => 'expression = $expression';
}

class ViewModel {
  final String expression;
  final OnButtonPressed onButtonPressed;
  final OnCalculate onCalculate;
  final OnClear onClear;
  ViewModel({
    required this.expression,
    required this.onClear,
    required this.onButtonPressed,
    required this.onCalculate,
  });
}

class InvalidFormatAction extends Action {}

typedef OnPressed = void Function();
typedef OnClear = void Function();
typedef OnButtonPressed = void Function(String);
typedef OnCalculate = void Function();

CalculatorState reducer(CalculatorState state, dynamic action) {
  if (action is CalculateExpressionAction) {
    try {
      state.expression = (Parser().parse(state.expression)
          .evaluate(EvaluationType.REAL, ContextModel()) as num)
          .toStringAsFixed(0);
    } catch (_) {
      print('Error: Invalid expression!');
    }
  } else if (action is InputExpressionAction) {
    state.expression += action.value;
  } else if (action is ClearAction) {
    state.expression = '';
  }else if (action is InvalidFormatAction) {
    print('Invalid Format!');

  }
  return state;
}

void main() {
  final store = Store<CalculatorState>(
    reducer,
    initialState: CalculatorState.initial(),
  );
  runApp(App(store: store));
}

class App extends StatelessWidget {
  final Store<CalculatorState> store;

  App({required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'Calculator',
        home: Main(),
      ),
    );
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CalculatorInput(),
            Expanded(
              child: CalculatorButtons(),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorInput extends StatefulWidget {
  @override
  _CalculatorInputState createState() => _CalculatorInputState();
}

class _CalculatorInputState extends State<CalculatorInput> {
  final _textStyle = TextStyle(
    color: Colors.yellowAccent,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    fontSize: 30,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: StoreConnector<CalculatorState, ViewModel>(
        converter: (Store<CalculatorState> store) => ViewModel(
          expression: store.state.expression,
          onClear: () => store.dispatch(ClearAction()),
          onButtonPressed: (String ) {  },
          onCalculate: () {  },
        ),
        builder: (BuildContext context, ViewModel viewModel) {
          return GestureDetector(
            onDoubleTap: viewModel.onClear,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Text(
                viewModel.expression,
                style: _textStyle,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalculatorButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: StoreConnector<CalculatorState, ViewModel>(
        converter: (Store<CalculatorState> store) => ViewModel(
          onButtonPressed: (String value) => store.dispatch(InputExpressionAction(value)),
          onCalculate: (){
            if (store.state.expression.endsWith('+')) {
              store.dispatch(InvalidFormatAction());
            } else {
              store.dispatch(CalculateExpressionAction());
            }
          },
          expression: '',
          onClear: () => store.dispatch(ClearAction()),
        ),
        builder: (BuildContext buildContext, ViewModel viewModel) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CalculatorButton(
                    title: '1',
                    onPressed: () => viewModel.onButtonPressed('1'),
                  ),
                  CalculatorButton(
                    title: '2',
                    onPressed: () => viewModel.onButtonPressed('2'),
                  ),
                  CalculatorButton(
                    title: '3',
                    onPressed: () => viewModel.onButtonPressed('3'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CalculatorButton(
                    title: '4',
                    onPressed: () => viewModel.onButtonPressed('4'),
                  ),
                  CalculatorButton(
                    title: '5',
                    onPressed: () => viewModel.onButtonPressed('5'),
                  ),
                  CalculatorButton(
                    title: '6',
                    onPressed: () => viewModel.onButtonPressed('6'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CalculatorButton(
                    title: '7',
                    onPressed: () => viewModel.onButtonPressed('7'),
                  ),
                  CalculatorButton(
                    title: '8',
                    onPressed: () => viewModel.onButtonPressed('8'),
                  ),
                  CalculatorButton(
                    title: '9',
                    onPressed: () => viewModel.onButtonPressed('9'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CalculatorButton(
                    title: '0',
                    onPressed: () => viewModel.onButtonPressed('0'),
                  ),
                  CalculatorButton(
                    title: '+',
                    onPressed: () => viewModel.onButtonPressed('+'),
                  ),
                  CalculatorButton(
                    title: '=',
                    onPressed: viewModel.onCalculate,
                  ),
                ],
              ),
              // Add the Clear button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CalculatorButton(
                    title: 'C',
                    onPressed: viewModel.onClear,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String title;
  final OnPressed onPressed;

  CalculatorButton({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        onPrimary: Colors.white,
        padding: EdgeInsets.all(20),
        side: BorderSide(
          color: Colors.white,
          width: 3,
          style: BorderStyle.solid,
        ),
        shape: CircleBorder(),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
