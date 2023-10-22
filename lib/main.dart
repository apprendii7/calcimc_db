import 'package:flutter/material.dart';
import 'package:calcimc/utils.dart' as utils;

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class IMCList {
  String nameValue;
  double weightValue;
  double heightValue;

  IMCList(this.nameValue, this.weightValue, this.heightValue);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _msgRetorno = "";
  List<IMCList> imcRecords = [];

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IMCRecordsScreen(imcRecords)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "Nome",
                    labelStyle: TextStyle(color: Colors.blue)),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, fontSize: 25.0),
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Insira seu nome";
                  }
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Peso (KG)",
                    labelStyle: TextStyle(color: Colors.blue)),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, fontSize: 25.0),
                controller: weightController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Insira seu peso";
                  }
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Altura(cm)",
                    labelStyle: TextStyle(color: Colors.blue)),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, fontSize: 25.0),
                controller: heightController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Insira sua altura";
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Container(
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              try {
                                setState(() {
                                  String nameValue = nameController.text;
                                  double weightValue =
                                      double.parse(weightController.text);
                                  double heightValue =
                                      double.parse(heightController.text);
                                  double imc =
                                      utils.imc(weightValue, heightValue);

                                  IMCList info = IMCList(
                                      nameValue, weightValue, heightValue);
                                  imcRecords.add(info);

                                  _msgRetorno = utils.mensagemImc(imc) +
                                      ': ' +
                                      imc.toStringAsFixed(2);
                                });

                                setState(() {
                                  nameController.text = "";
                                  weightController.text = "";
                                  heightController.text = "";
                                });

                                final snackBar = SnackBar(
                                  content: Text('IMC cadastrado'),
                                  duration: Duration(
                                      seconds:
                                          2), // Tempo que o SnackBar ficará visível
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } catch (erro) {
                                final snackBar = SnackBar(
                                  content: Text(
                                      'Erro, confira os dados e tente novamente'),
                                  duration: Duration(
                                      seconds:
                                          2), // Tempo que o SnackBar ficará visível
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          },
                          child: Text(
                            "Calcular",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _showHistory,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors
                                    .blueGrey), // Defina a cor de fundo desejada
                          ),
                          child: Text('Histórico'),
                        ),
                      ],
                    )),
              ),
              Text('Resultado: ' + _msgRetorno,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue, fontSize: 20.0)),
            ],
          ),
        ),
      ),
    );
  }
}

class IMCRecordsScreen extends StatelessWidget {
  final List<IMCList> imcRecords;

  IMCRecordsScreen(this.imcRecords);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Histórico"),
      ),
      body: ListView.builder(
        itemCount: imcRecords.length,
        itemBuilder: (context, index) {
          IMCList record = imcRecords[index];
          return ListTile(
            title: Text("Nome: ${record.nameValue}"),
            subtitle: Text(
                "Peso: ${record.weightValue}, Altura: ${record.heightValue}"),
          );
        },
      ),
    );
  }
}
