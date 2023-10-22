import 'package:flutter/material.dart';
import 'package:calcimc/utils.dart' as utils;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class IMCList {
  String nameValue;
  double weightValue;
  int heightValue;

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

  @override
  void initState() {
    super.initState();
    // A função será executada quando o estado for inicializado.
    _dadosInput();
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IMCRecordsScreen(),
        settings: RouteSettings(
            arguments: imcRecords), // Passa a lista imcRecords como argumento
      ),
    );
  }

  void _dadosInput() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final path = '${appDocumentDirectory.path}/my_database.db';

    final database = await openDatabase(
      path,
      version: 1, // Altere a versão conforme necessário
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE registros(
            id INTEGER PRIMARY KEY,
            nameValue TEXT,
            weightValue REAL,
            heightValue INTEGER
          )
        ''');
      },
    );

    String boxName = "dadosinputs";

    final hiveBoxPath = appDocumentDirectory.path;
    var hive = Hive.isBoxOpen(boxName);
    if (!hive) {
      var box = await Hive.openBox(boxName, path: hiveBoxPath);
      setState(() {
        nameController.text = box.get('nameValue') ?? "";
        heightController.text = box.get('heightValue').toString() ?? "";
      });
    } else {
      var box = Hive.box(boxName);
      setState(() {
        nameController.text = box.get('nameValue') ?? "";
        heightController.text = box.get('heightValue').toString() ?? "";
      });
    }
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                String nameValue = "";
                                double weightValue = 0.00;
                                int heightValue = 0;
                                double imc = 0.00;

                                setState(() {
                                  nameValue = nameController.text;
                                  weightValue =
                                      double.parse(weightController.text);
                                  heightValue =
                                      int.parse(heightController.text);
                                  imc = utils.imc(weightValue, heightValue);

                                  IMCList info = IMCList(
                                      nameValue, weightValue, heightValue);
                                  imcRecords.add(info);

                                  _msgRetorno = utils.mensagemImc(imc) +
                                      ': ' +
                                      imc.toStringAsFixed(2);
                                });

                                String boxName = "dadosinputs";
                                final appDocumentDirectory =
                                    await getApplicationDocumentsDirectory();
                                final hiveBoxPath = appDocumentDirectory.path;
                                final path =
                                    '${appDocumentDirectory.path}/my_database.db';

                                var hive = Hive.isBoxOpen(boxName);
                                if (!hive) {
                                  var box = await Hive.openBox(boxName,
                                      path: hiveBoxPath);
                                  await box.put('nameValue', nameValue);
                                  await box.put('weightValue', weightValue);
                                  await box.put('heightValue', heightValue);
                                  await box.close();
                                } else {
                                  var box = Hive.box(boxName);
                                  await box.put('nameValue', nameValue);
                                  await box.put('weightValue', weightValue);
                                  await box.put('heightValue', heightValue);
                                  await box.close();
                                }

                                final database =
                                    await openDatabase(path, version: 1);
                                await database.insert(
                                  'registros', // Nome da tabela
                                  {
                                    'nameValue': nameValue,
                                    'weightValue': weightValue,
                                    'heightValue': heightValue,
                                  },
                                );

                                // Feche o banco de dados
                                await database.close();

                                setState(() {
                                  nameController.text = "";
                                  weightController.text = "";
                                  heightController.text = "";
                                });

                                final snackBar = const SnackBar(
                                  content: Text('IMC cadastrado'),
                                  duration: Duration(
                                      seconds:
                                          2), // Tempo que o SnackBar ficará visível
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } catch (erro) {
                                print("Ocorreu um erro: $erro");
                                final snackBar = SnackBar(
                                  content: Text(
                                      'Erro, confira os dados e tente novamente $erro'),
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

class IMCRecordsScreen extends StatefulWidget {
  @override
  _IMCRecordsScreenState createState() => _IMCRecordsScreenState();
}

class _IMCRecordsScreenState extends State<IMCRecordsScreen> {
  List<Map<String, dynamic>> imcRecords = [];

  @override
  void initState() {
    super.initState();
    fetchIMCRecords();
  }

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
          Map<String, dynamic> record = imcRecords[index];
          return ListTile(
            title: Text("Nome: ${record['nameValue']}"),
            subtitle: Text(
                "Peso: ${record['weightValue']}, Altura: ${record['heightValue']}"),
          );
        },
      ),
    );
  }

  Future<void> fetchIMCRecords() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final path = '${appDocumentDirectory.path}/my_database.db';

    final database = await openDatabase(path, version: 1);
    final records = await database.query('registros');

    setState(() {
      imcRecords = records;
    });

    await database.close();
  }
}
